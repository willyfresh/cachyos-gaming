#!/usr/bin/env python3
"""Pending repo and AUR updates for Waybar. Hidden when there are none.

checkupdates and paru -Qua are slow, so the bar runs this every half
hour. A click lists the saved packages in Fuzzel. The first line
upgrades every package. When some of those wait until the next boot,
the next line upgrades the rest. Any other line upgrades that one
package. Each row shows the download size when it is known. A row
ends in "reboot *" when that package is unused until the next boot.
An AUR row ends in "aur" before that. The first line says reboot
when any row does.
"""

from __future__ import annotations

import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

NAME = re.compile(r"[A-Za-z0-9@._+-]+")

CACHE = Path.home() / ".cache" / "novalis" / "waybar-updates.txt"
ICON = "\uf019"
# Waybar custom/updates "signal": this number. SIGRTMIN+N refreshes the chip.
SIGNAL = 2
# Appended in the Fuzzel list. The chip stays the count and the download icon.
REBOOT_MARK = "  reboot *"
AUR_MARK = "  aur"
# The new package is not in use until the next boot. Headers, the Limine
# hook, and linux-firmware-whence (the license list) are not in this set.
REBOOT_NAMES = {
    "linux-cachyos",
    "linux-cachyos-lts",
    "linux-cachyos-nvidia-open",
    "linux-cachyos-lts-nvidia-open",
    "nvidia-utils",
    "lib32-nvidia-utils",
    "amd-ucode",
    "intel-ucode",
    "limine",
}
# Match rows under the prompt. 40 is enough on these 1080px panels.
MENU_LINES = "40"


def package_of(line: str) -> str | None:
    part = line.split()[0] if line.strip() else ""
    if NAME.fullmatch(part):
        return part
    return None


def names(entries: list[tuple[str, str, int | None]]) -> list[str]:
    return [name for _, line, _size in entries if (name := package_of(line))]


def needs_reboot(name: str) -> bool:
    if name in REBOOT_NAMES:
        return True
    return name.startswith("linux-firmware") and name != "linux-firmware-whence"


def format_size(nbytes: int) -> str:
    size = float(nbytes)
    for unit in ("B", "KiB", "MiB", "GiB"):
        if unit == "B":
            if size < 1024:
                return f"{int(size)} B"
        elif size < 1024 or unit == "GiB":
            return f"{size:.2f} {unit}"
        size /= 1024
    return f"{size:.2f} GiB"


def show_line(kind: str, line: str, size: int | None) -> str:
    shown = line
    if size is not None:
        shown += "   " + format_size(size)
    if kind == "aur":
        shown += AUR_MARK
    name = package_of(line)
    if name and needs_reboot(name):
        shown += REBOOT_MARK
    return shown


def parse_cached(line: str) -> tuple[str, str, int | None] | None:
    # Older caches are plain checkupdates lines, all from the repos.
    # The saved form is kind, download size in bytes, then the line.
    size: int | None = None
    if line.startswith(("aur\t", "repo\t")):
        parts = line.split("\t")
        kind = parts[0]
        if len(parts) >= 3:
            if parts[1].isdigit():
                size = int(parts[1])
            rest = parts[2].strip()
        else:
            rest = parts[1].strip()
    else:
        kind, rest = "repo", line.strip()
    if rest and package_of(rest):
        return kind, rest, size
    return None


def read_cache() -> list[tuple[str, str, int | None]] | None:
    try:
        text = CACHE.read_text()
    except OSError:
        return None
    return [entry for line in text.splitlines() if (entry := parse_cached(line))]


def write_cache(entries: list[tuple[str, str, int | None]]) -> None:
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    for kind, line, size in entries:
        size_field = "" if size is None else str(size)
        rows.append(f"{kind}\t{size_field}\t{line}")
    body = "\n".join(rows)
    tmp = CACHE.with_suffix(".txt.tmp")
    tmp.write_text(body + ("\n" if body else ""))
    tmp.replace(CACHE)


def checkup_db() -> Path:
    custom = os.environ.get("CHECKUPDATES_DB")
    if custom:
        return Path(custom)
    tmp = os.environ.get("TMPDIR", "/tmp")
    return Path(tmp) / f"checkup-db-{os.getuid()}"


def repo_download_sizes(package_names: list[str]) -> dict[str, int]:
    # checkupdates syncs a temporary db and leaves the system db alone.
    # %s is that package's download size in bytes.
    db = checkup_db()
    if not package_names or not (db / "sync").is_dir():
        return {}
    proc = subprocess.run(
        [
            "pacman",
            "--dbpath",
            str(db),
            "-Sp",
            "--print-format",
            "%n %s",
            "--",
            *package_names,
        ],
        text=True,
        capture_output=True,
        timeout=30,
        check=False,
    )
    found: dict[str, int] = {}
    if proc.returncode != 0:
        return found
    for row in proc.stdout.splitlines():
        part = row.split()
        if len(part) == 2 and part[1].isdigit():
            found[part[0]] = int(part[1])
    return found


def attach_sizes(
    entries: list[tuple[str, str, int | None]],
) -> list[tuple[str, str, int | None]]:
    missing = [
        name
        for kind, line, size in entries
        if kind == "repo" and size is None and (name := package_of(line))
    ]
    if not missing:
        return entries
    found = repo_download_sizes(missing)
    if not found:
        return entries
    updated: list[tuple[str, str, int | None]] = []
    for kind, line, size in entries:
        name = package_of(line)
        if size is None and name in found:
            size = found[name]
        updated.append((kind, line, size))
    return updated


def fetch() -> list[tuple[str, str, int | None]] | None:
    # The two queries both talk to the network. Overlap them.
    repo_proc = subprocess.Popen(
        ["checkupdates", "--nocolor"],
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    aur_proc = None
    if shutil.which("paru"):
        aur_proc = subprocess.Popen(
            ["paru", "-Qua", "--color", "never"],
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    repo_out, _ = repo_proc.communicate()
    if repo_proc.returncode == 2:
        repo: list[str] | None = []
    elif repo_proc.returncode != 0:
        repo = None
    else:
        repo = [line.strip() for line in repo_out.splitlines() if line.strip()]

    if aur_proc is None:
        aur: list[str] | None = []
    else:
        aur_out, aur_err = aur_proc.communicate()
        aur_lines = [line.strip() for line in aur_out.splitlines() if line.strip()]
        if aur_proc.returncode == 0:
            aur = aur_lines
        elif aur_proc.returncode == 1 and not aur_err.strip() and not aur_lines:
            aur = []
        else:
            aur = None

    if repo is None:
        return None
    if aur is None:
        previous = read_cache() or []
        aur = [line for kind, line, _size in previous if kind == "aur"]

    entries: list[tuple[str, str, int | None]] = []
    seen: set[str] = set()
    for kind, line in [("repo", line) for line in repo] + [("aur", line) for line in aur]:
        name = package_of(line)
        if not name or name in seen:
            continue
        seen.add(name)
        entries.append((kind, line, None))
    entries = attach_sizes(entries)
    write_cache(entries)
    return entries


def emit(entries: list[tuple[str, str, int | None]]) -> None:
    if not entries:
        print(json.dumps({"text": "", "tooltip": "No pending updates"}), flush=True)
        return
    pkgs = names(entries)
    tip = pkgs[:24]
    if len(pkgs) > 24:
        tip.append(f"{len(pkgs) - 24} more")
    print(json.dumps({
        "text": f"{len(pkgs)} {ICON}",
        "tooltip": "\n".join(tip),
    }, ensure_ascii=False), flush=True)


def update_label(
    count: int,
    size: int | None,
    *,
    reboot: bool = False,
    no_reboot: bool = False,
) -> str:
    noun = "package" if count == 1 else "packages"
    if no_reboot:
        label = f"→  Update all {count} {noun}, no reboot"
    else:
        label = f"→  Update all {count} {noun}"
    if size is not None:
        label += "   " + format_size(size)
    if reboot and not no_reboot:
        label += REBOOT_MARK
    return label


def known_size(rows: list[tuple[str, str, int | None]]) -> int | None:
    sizes = [size for _kind, _line, size in rows if size is not None]
    if not sizes:
        return None
    return sum(sizes)


def launch(command: str, title: str) -> None:
    # No --noconfirm: the upgrade asks before changing the system, and
    # sudo asks for the password in this terminal. paru calls sudo
    # itself. --skipreview matches pkg-add, so a PKGBUILD pager does
    # not sit in front of that question.
    script = f"""{command}
status=$?
echo
if [ "$status" -eq 0 ]; then
  echo "Update finished."
  pkill -RTMIN+{SIGNAL} -x waybar || true
else
  echo "Update exited $status."
fi
echo
read -r -p "Press Enter to close. "
"""
    subprocess.Popen(
        ["kitty", "--class", "update", "--title", title, "-e", "bash", "-lc", script],
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def upgrade_command(kind: str, name: str | None) -> str | None:
    if name is None:
        if shutil.which("paru"):
            return "paru -Syu --skipreview --removemake --sudoloop"
        return "sudo pacman -Syu"
    if kind == "aur":
        return f"paru -S --skipreview --removemake --sudoloop -- {shlex.quote(name)}"
    # -Sy refreshes the databases. checkupdates does not update the
    # system copy, then this upgrades the package and its dependencies.
    return f"sudo pacman -Sy -- {shlex.quote(name)}"


def upgrade_safe(entries: list[tuple[str, str, int | None]]) -> str | None:
    # Leave out packages that are unused until the next boot, and do
    # not let one of them arrive as a dependency of the rest.
    keep: list[tuple[str, str]] = []
    ignore = set(REBOOT_NAMES)
    for _kind, line, _size in entries:
        name = package_of(line)
        if not name:
            continue
        if needs_reboot(name):
            ignore.add(name)
            continue
        keep.append((_kind, name))
    if not keep:
        return None
    quoted = " ".join(shlex.quote(name) for _kind, name in keep)
    ignore_flags = " ".join(f"--ignore {shlex.quote(name)}" for name in sorted(ignore))
    if any(kind == "aur" for kind, _name in keep):
        return f"paru -S --skipreview --removemake --sudoloop {ignore_flags} -- {quoted}"
    return f"sudo pacman -Sy {ignore_flags} -- {quoted}"


def menu_lines(
    entries: list[tuple[str, str, int | None]],
) -> tuple[list[str], dict[str, tuple]]:
    safe = [
        row
        for row in entries
        if (name := package_of(row[1])) and not needs_reboot(name)
    ]
    reboot = any(needs_reboot(name) for name in names(entries))
    lines: list[str] = []
    actions: dict[str, tuple] = {}
    if entries:
        all_label = update_label(len(names(entries)), known_size(entries), reboot=reboot)
        lines.append(all_label)
        actions[all_label] = ("all",)
        if safe and len(safe) < len(entries):
            safe_label = update_label(len(safe), known_size(safe), no_reboot=True)
            lines.append(safe_label)
            actions[safe_label] = ("safe",)
    for kind, line, size in entries:
        shown = show_line(kind, line, size)
        lines.append(shown)
        actions[shown] = ("one", kind, line)
    return lines, actions


def detail() -> None:
    entries = read_cache()
    if entries is None:
        entries = fetch() or []
    else:
        sized = attach_sizes(entries)
        if sized != entries:
            entries = sized
            write_cache(entries)
    lines, actions = menu_lines(entries)
    body = "\n".join(lines) if lines else "No pending updates"
    chosen = subprocess.run(
        [
            "fuzzel",
            "--dmenu",
            "--prompt",
            "Updates  ",
            "--width",
            "96",
            "--lines",
            MENU_LINES,
        ],
        input=body + "\n",
        text=True,
        capture_output=True,
        check=False,
    ).stdout.strip()
    if not entries or not chosen:
        return
    action = actions.get(chosen)
    if action is None:
        return
    if action[0] == "all":
        command = upgrade_command("repo", None)
        title = "Update"
    elif action[0] == "safe":
        command = upgrade_safe(entries)
        title = "Update"
    else:
        _tag, kind, line = action
        name = package_of(line)
        command = upgrade_command(kind, name)
        title = f"Update {name}" if name else "Update"
    if command:
        launch(command, title)


def main() -> None:
    if len(sys.argv) > 1 and sys.argv[1] == "detail":
        detail()
        return
    entries = fetch()
    if entries is None:
        emit(read_cache() or [])
        return
    emit(entries)


if __name__ == "__main__":
    main()
