#!/usr/bin/env python3
"""Pending pacman updates for Waybar. Hidden when there are none.

checkupdates is slow, so the bar runs this every half hour. A click
lists the saved packages in Fuzzel. The first line upgrades every
repo package. Any other line upgrades that one package.
"""

from __future__ import annotations

import json
import re
import shlex
import subprocess
import sys
from pathlib import Path

NAME = re.compile(r"[A-Za-z0-9@._+-]+")

CACHE = Path.home() / ".cache" / "novalis" / "waybar-updates.txt"
ICON = "\uf019"
# Waybar custom/updates "signal": this number. SIGRTMIN+N refreshes the chip.
SIGNAL = 2


def package_of(line: str) -> str | None:
    part = line.split()[0] if line.strip() else ""
    if NAME.fullmatch(part):
        return part
    return None


def names(lines: list[str]) -> list[str]:
    return [name for line in lines if (name := package_of(line))]


def read_cache() -> list[str] | None:
    try:
        text = CACHE.read_text()
    except OSError:
        return None
    return [line for line in text.splitlines() if line.strip()]


def fetch() -> list[str] | None:
    proc = subprocess.run(["checkupdates"], text=True, capture_output=True)
    if proc.returncode == 2:
        lines: list[str] = []
    elif proc.returncode != 0:
        return None
    else:
        lines = [line.strip() for line in proc.stdout.splitlines() if line.strip()]
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    tmp = CACHE.with_suffix(".txt.tmp")
    tmp.write_text("\n".join(lines) + ("\n" if lines else ""))
    tmp.replace(CACHE)
    return lines


def emit(lines: list[str]) -> None:
    if not lines:
        print(json.dumps({"text": "", "tooltip": "No pending updates"}), flush=True)
        return
    pkgs = names(lines)
    tip = pkgs[:24]
    if len(pkgs) > 24:
        tip.append(f"{len(pkgs) - 24} more")
    print(json.dumps({
        "text": f"{len(pkgs)} {ICON}",
        "tooltip": "\n".join(tip),
    }, ensure_ascii=False), flush=True)


def update_label(count: int) -> str:
    noun = "package" if count == 1 else "packages"
    return f"→  Update all {count} {noun}"


def launch(pacman_cmd: str, title: str) -> None:
    # No --noconfirm: pacman asks before changing the system, and sudo
    # asks for the password in this terminal.
    command = f"""{pacman_cmd}
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
        ["alacritty", "--class", "update", "--title", title, "-e", "bash", "-lc", command],
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def detail() -> None:
    lines = read_cache()
    if lines is None:
        lines = fetch() or []
    if lines:
        body = update_label(len(names(lines))) + "\n" + "\n".join(lines)
    else:
        body = "No pending updates"
    chosen = subprocess.run(
        [
            "fuzzel",
            "--dmenu",
            "--prompt",
            "Updates  ",
            "--width",
            "72",
            "--lines",
            "20",
        ],
        input=body + "\n",
        text=True,
        capture_output=True,
        check=False,
    ).stdout.strip()
    if not lines or not chosen:
        return
    if chosen == update_label(len(names(lines))):
        launch("sudo pacman -Syu", "Update")
        return
    # The menu line has to be one we printed. -Sy refreshes the
    # databases, because checkupdates does not update the system copy,
    # then upgrades this package and its dependencies.
    name = package_of(chosen) if chosen in lines else None
    if name:
        launch(f"sudo pacman -Sy -- {shlex.quote(name)}", f"Update {name}")


def main() -> None:
    if len(sys.argv) > 1 and sys.argv[1] == "detail":
        detail()
        return
    lines = fetch()
    if lines is None:
        cached = read_cache()
        emit(cached or [])
        return
    emit(lines)


if __name__ == "__main__":
    main()
