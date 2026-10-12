#!/usr/bin/env python3
"""Now playing from playerctl. Click pauses or resumes that player."""

from __future__ import annotations

import json
import subprocess
import sys


def run(args: list[str]) -> str:
    return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL).strip()


def players() -> list[tuple[str, str]]:
    try:
        names = [line for line in run(["playerctl", "-l"]).splitlines() if line]
    except (OSError, subprocess.CalledProcessError):
        return []
    found: list[tuple[str, str]] = []
    for name in names:
        try:
            status = run(["playerctl", "-p", name, "status"])
        except (OSError, subprocess.CalledProcessError):
            continue
        found.append((name, status))
    playing = [item for item in found if item[1] == "Playing"]
    return playing or found


def meta(player: str, key: str) -> str:
    try:
        return run(["playerctl", "-p", player, "metadata", key])
    except (OSError, subprocess.CalledProcessError):
        return ""


def pango(text: str) -> str:
    # Titles are markup. An ampersand or a bracket otherwise eats the rest
    # of the line, which is what made some song names look blank.
    kept = "".join(ch for ch in text if ch == "\n" or ord(ch) >= 32)
    return kept.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def main() -> None:
    found = players()
    if not found:
        print(json.dumps({"text": "", "tooltip": ""}), flush=True)
        return
    player, status = found[0]
    if len(sys.argv) > 1 and sys.argv[1] == "toggle":
        subprocess.run(["playerctl", "-p", player, "play-pause"], check=False)
        return
    title = meta(player, "xesam:title") or "Unknown"
    artist = meta(player, "xesam:artist")
    mark = "▶" if status == "Playing" else "❚❚"
    tip = title if not artist else f"{artist}\n{title}"
    print(json.dumps({
        "text": f"{mark} {pango(title)}",
        "tooltip": pango(tip),
        "class": "paused" if status != "Playing" else "playing",
    }, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
