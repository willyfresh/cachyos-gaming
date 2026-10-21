#!/usr/bin/env python3
"""Pending repo and AUR updates for Waybar. Hidden when there are none.

checkupdates and paru -Qua are slow, so the bar runs this every half
hour. A click, or the Keychron triangle, lists the saved packages in
Fuzzel. The first line
upgrades every package. When some of those wait until the next boot,
the next line upgrades the rest. Any other line upgrades that one
package. Each row shows the download size when it is known. A row
ends in "reboot *" when that package is unused until the next boot.
An AUR row ends in "aur" before that. A row ends in "restart *" when
a running service has one of its libraries loaded. The first line
says reboot when any row does, or restart when a service needs it.
After the upgrade, the terminal asks before a reboot or a service
restart. Enter means yes. A reboot is refused when the Limine menu
names a missing or mismatched file.
"""

from __future__ import annotations

import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

NAME = re.compile(r"[A-Za-z0-9@._+-]+")

CACHE = Path.home() / ".cache" / "novalis" / "waybar-updates.txt"
ICON = "\uf019"
# Waybar custom/updates "signal": this number. SIGRTMIN+N refreshes the chip.
SIGNAL = 2
# Appended in the Fuzzel list. The chip stays the count and the download icon.
REBOOT_MARK = "  reboot *"
RESTART_MARK = "  restart *"
AUR_MARK = "  aur"
# Restarting these takes the session down. An old library in one of
# them is a reboot, not a service restart.
SKIP_SERVICES = {
    "dbus.service",
    "dbus-broker.service",
    "systemd-logind.service",
}
PACMAN_LOG = Path("/var/log/pacman.log")
LIMINE_CHECK = Path("/usr/local/bin/check-limine-boot.sh")
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
# Cap for a long list on these 1080px panels. --minimal-lines shrinks
# a short list to its rows.
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


def is_shared_object(path: str) -> bool:
    name = path.rsplit("/", 1)[-1]
    return ".so" in name and name != "ld.so.cache"


def is_c_library(path: str) -> bool:
    name = path.rsplit("/", 1)[-1]
    return name in {"libc.so.6", "ld-linux-x86-64.so.2"}


def service_libraries(
    *, deleted: bool
) -> tuple[dict[str, set[tuple[str, str]]], set[str], bool]:
    """Libraries mapped by a restartable service, and dangerous units.

    The map is a library path to (unit, scope) pairs. Scope is "user"
    or "system". The set is session units that still have an old
    library. Those are not restarted in place. The bool is true when
    a deleted C library was seen. Passing deleted=False looks at the
    libraries programs are using now, which is what the list marks.
    """
    held: dict[str, set[tuple[str, str]]] = {}
    dangerous: set[str] = set()
    old_c_library = False
    proc = Path("/proc")
    for entry in proc.iterdir():
        if not entry.name.isdigit():
            continue
        try:
            maps = (entry / "maps").read_text(errors="replace")
            cgroup = (entry / "cgroup").read_text(errors="replace")
        except OSError:
            continue
        units: list[str] = []
        user = False
        for row in cgroup.splitlines():
            path = row.split(":", 2)[-1]
            for bit in path.split("/"):
                if not bit.endswith(".service"):
                    continue
                units.append(bit)
                if bit.startswith("user@"):
                    user = True
        scope = "user" if user else "system"
        for row in maps.splitlines():
            bits = row.split(None, 5)
            if len(bits) < 6:
                continue
            path = bits[5]
            old = path.endswith(" (deleted)")
            if old != deleted:
                continue
            if old:
                path = path[: -len(" (deleted)")]
            if not path.startswith("/") or not is_shared_object(path):
                continue
            if deleted and is_c_library(path):
                old_c_library = True
            for unit in units:
                if unit.startswith("user@"):
                    continue
                if unit in SKIP_SERVICES:
                    if deleted:
                        dangerous.add(unit.removesuffix(".service"))
                    continue
                held.setdefault(path, set()).add((unit, scope))
    return held, dangerous, old_c_library


def package_shared_objects(pkgs: list[str]) -> dict[str, set[str]]:
    owned = {name: set() for name in pkgs}
    if not pkgs:
        return owned
    proc = subprocess.run(
        ["pacman", "-Ql", *pkgs],
        text=True,
        capture_output=True,
        check=False,
    )
    for row in proc.stdout.splitlines():
        part = row.split(None, 1)
        if len(part) != 2 or part[0] not in owned:
            continue
        if is_shared_object(part[1]):
            owned[part[0]].add(part[1])
    return owned


def packages_needing_restart(entries: list[tuple[str, str, int | None]]) -> set[str]:
    pkgs = [name for name in names(entries) if not needs_reboot(name)]
    owned = package_shared_objects(pkgs)
    used, _dangerous, _old_c = service_libraries(deleted=False)
    found: set[str] = set()
    for name, paths in owned.items():
        if any(path in used for path in paths):
            found.add(name)
    return found


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


def show_line(kind: str, line: str, size: int | None, *, restart: bool = False) -> str:
    shown = line
    if size is not None:
        shown += "   " + format_size(size)
    if kind == "aur":
        shown += AUR_MARK
    name = package_of(line)
    if name and needs_reboot(name):
        shown += REBOOT_MARK
    elif restart:
        shown += RESTART_MARK
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
    restart: bool = False,
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
    elif restart:
        label += RESTART_MARK
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
    # not sit in front of that question. finish asks about a reboot or
    # a service restart after a successful upgrade. Enter means yes.
    started = int(datetime.now().timestamp())
    script = f"""{command}
status=$?
echo
if [ "$status" -eq 0 ]; then
  echo "Update finished."
  {shlex.quote(sys.argv[0])} finish {started}
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
    pkg_names = names(entries)
    reboot = any(needs_reboot(name) for name in pkg_names)
    restarting = packages_needing_restart(entries)
    safe_restart = any(
        (name := package_of(line)) in restarting for _kind, line, _size in safe
    )
    lines: list[str] = []
    actions: dict[str, tuple] = {}
    if entries:
        all_label = update_label(
            len(pkg_names),
            known_size(entries),
            reboot=reboot,
            restart=bool(restarting),
        )
        lines.append(all_label)
        actions[all_label] = ("all",)
        if safe and len(safe) < len(entries):
            safe_label = update_label(
                len(safe),
                known_size(safe),
                no_reboot=True,
                restart=safe_restart,
            )
            lines.append(safe_label)
            actions[safe_label] = ("safe",)
    for kind, line, size in entries:
        name = package_of(line)
        shown = show_line(kind, line, size, restart=bool(name and name in restarting))
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
            "--minimal-lines",
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


def upgraded_since(started: float) -> list[str]:
    try:
        text = PACMAN_LOG.read_text(errors="replace")
    except OSError:
        return []
    found: list[str] = []
    for line in text.splitlines():
        if "] upgraded " not in line and "] installed " not in line:
            continue
        stamp = line.split("]", 1)[0].removeprefix("[").strip()
        try:
            when = datetime.fromisoformat(stamp).timestamp()
        except ValueError:
            continue
        if when < started:
            continue
        match = re.search(r"\] (?:upgraded|installed) ([A-Za-z0-9@._+-]+)", line)
        if match:
            found.append(match.group(1))
    return found


def boot_menu_ready() -> bool:
    """True when every file the Limine menu names is on /boot."""
    script = LIMINE_CHECK
    if not script.is_file():
        script = Path(__file__).resolve().parent / "check-limine-boot.sh"
    if not script.is_file():
        print("The Limine boot check is not installed. Not rebooting.")
        return False
    proc = subprocess.run(
        [str(script)],
        text=True,
        capture_output=True,
        check=False,
    )
    if proc.returncode != 0:
        message = (proc.stderr or proc.stdout).strip()
        if message:
            print(message)
        print("The boot menu is not ready. Not rebooting.")
        return False
    ready = proc.stdout.strip()
    if ready:
        print(ready)
    return True


def ask(prompt: str) -> bool:
    # Enter means yes. A closed terminal means no, so a reboot is never
    # started from a script that is not looking at the user.
    if not sys.stdin.isatty():
        print(prompt + "skipped")
        return False
    try:
        answer = input(prompt)
    except EOFError:
        return False
    return answer.strip().lower() not in {"n", "no"}


def restart_services(units: set[tuple[str, str]]) -> None:
    user = sorted(name for name, scope in units if scope == "user")
    system = sorted(name for name, scope in units if scope == "system")
    if system:
        subprocess.run(["sudo", "systemctl", "restart", *system], check=False)
    if user:
        subprocess.run(["systemctl", "--user", "restart", *user], check=False)


def finish(started: float) -> None:
    upgraded = upgraded_since(started)
    held, dangerous, old_c_library = service_libraries(deleted=True)
    reboot_package = any(needs_reboot(name) for name in upgraded)
    if reboot_package or old_c_library or dangerous:
        if old_c_library:
            reason = "The C library is still the old one."
        elif dangerous and not reboot_package:
            listed = ", ".join(sorted(dangerous))
            reason = f"{listed} still has an old library."
        else:
            reason = "This update is unused until the next boot."
        print(reason)
        if not boot_menu_ready():
            return
        if ask("Reboot now? [Y/n] "):
            subprocess.run(["sudo", "systemctl", "reboot"], check=False)
        return
    by_unit: dict[tuple[str, str], list[str]] = {}
    for path, owners in held.items():
        label = path.rsplit("/", 1)[-1]
        for owner in owners:
            by_unit.setdefault(owner, []).append(label)
    if not by_unit:
        return
    ordered = sorted(by_unit)
    if len(ordered) == 1:
        short = ordered[0][0].removesuffix(".service")
        libs = ", ".join(sorted(by_unit[ordered[0]]))
        print(f"{short} is still using old {libs}.")
        prompt = "Restart it? [Y/n] "
    else:
        print("These are still using an old library:")
        for owner in ordered:
            short = owner[0].removesuffix(".service")
            libs = ", ".join(sorted(by_unit[owner]))
            print(f"  {short} ({libs})")
        prompt = "Restart them? [Y/n] "
    if ask(prompt):
        restart_services(set(ordered))


def main() -> None:
    if len(sys.argv) > 1 and sys.argv[1] == "detail":
        detail()
        return
    if len(sys.argv) > 1 and sys.argv[1] == "finish":
        started = float(sys.argv[2]) if len(sys.argv) > 2 else 0
        finish(started)
        return
    entries = fetch()
    if entries is None:
        emit(read_cache() or [])
        return
    emit(entries)


if __name__ == "__main__":
    main()
