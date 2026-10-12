#!/usr/bin/env python3
"""Pending pacman updates for Waybar. Hidden when there are none.

checkupdates is slow, so the bar runs this every half hour and a click
shows the saved list in Fuzzel.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

CACHE = Path.home() / ".cache" / "novalis" / "waybar-updates.txt"
ICON = "\uf019"


def names(lines: list[str]) -> list[str]:
    return [line.split()[0] for line in lines if line.strip()]


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


def detail() -> None:
    lines = read_cache()
    if lines is None:
        lines = fetch() or []
    body = "\n".join(lines) if lines else "No pending updates"
    subprocess.run(
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
        check=False,
    )


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
