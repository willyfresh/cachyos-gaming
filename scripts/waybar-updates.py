#!/usr/bin/env python3
"""Pending repo and AUR updates for Waybar. Hidden when there are none.

checkupdates and paru -Qua are slow, so the bar runs this every half
hour. A click lists the saved packages in Fuzzel. The first line
upgrades every package. Any other line upgrades that one package. A
row ends in "reboot *" when that package is unused until the next
boot. An AUR row ends in "aur" before that. The first line says
reboot when any row does.
"""

from __future__ import annotations

import json
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


def names(entries: list[tuple[str, str]]) -> list[str]:
    return [name for _, line in entries if (name := package_of(line))]


def needs_reboot(name: str) -> bool:
    if name in REBOOT_NAMES:
        return True
    return name.startswith("linux-firmware") and name != "linux-firmware-whence"


def show_line(kind: str, line: str) -> str:
    shown = line
    if kind == "aur":
        shown += AUR_MARK
    name = package_of(line)
    if name and needs_reboot(name):
        shown += REBOOT_MARK
    return shown


def strip_marks(chosen: str) -> str:
    return chosen.removesuffix(REBOOT_MARK).removesuffix(AUR_MARK)


def parse_cached(line: str) -> tuple[str, str] | None:
    # Older caches are plain checkupdates lines, all from the repos.
    if line.startswith(("aur\t", "repo\t")):
        kind, rest = line.split("\t", 1)
        rest = rest.strip()
    else:
        kind, rest = "repo", line.strip()
    if rest and package_of(rest):
        return kind, rest
    return None


def read_cache() -> list[tuple[str, str]] | None:
    try:
        text = CACHE.read_text()
    except OSError:
        return None
    return [entry for line in text.splitlines() if (entry := parse_cached(line))]


def write_cache(entries: list[tuple[str, str]]) -> None:
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    body = "\n".join(f"{kind}\t{line}" for kind, line in entries)
    tmp = CACHE.with_suffix(".txt.tmp")
    tmp.write_text(body + ("\n" if body else ""))
    tmp.replace(CACHE)


def fetch() -> list[tuple[str, str]] | None:
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
        aur = [line for kind, line in previous if kind == "aur"]

    entries: list[tuple[str, str]] = []
    seen: set[str] = set()
    for kind, line in [("repo", line) for line in repo] + [("aur", line) for line in aur]:
        name = package_of(line)
        if not name or name in seen:
            continue
        seen.add(name)
        entries.append((kind, line))
    write_cache(entries)
    return entries


def emit(entries: list[tuple[str, str]]) -> None:
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


def update_label(count: int, *, reboot: bool = False) -> str:
    noun = "package" if count == 1 else "packages"
    label = f"→  Update all {count} {noun}"
    if reboot:
        label += REBOOT_MARK
    return label


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


def detail() -> None:
    entries = read_cache()
    if entries is None:
        entries = fetch() or []
    reboot = any(needs_reboot(name) for name in names(entries))
    label = update_label(len(names(entries)), reboot=reboot) if entries else ""
    if entries:
        body = label + "\n" + "\n".join(show_line(kind, line) for kind, line in entries)
    else:
        body = "No pending updates"
    chosen = subprocess.run(
        [
            "fuzzel",
            "--dmenu",
            "--prompt",
            "Updates  ",
            "--width",
            "80",
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
    if chosen == label:
        command = upgrade_command("repo", None)
        if command:
            launch(command, "Update")
        return
    raw = strip_marks(chosen)
    match = next(((kind, line) for kind, line in entries if line == raw), None)
    if match is None:
        return
    kind, line = match
    name = package_of(line)
    command = upgrade_command(kind, name)
    if command and name:
        launch(command, f"Update {name}")


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
