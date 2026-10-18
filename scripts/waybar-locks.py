#!/usr/bin/env python3
"""Caps Lock and Num Lock for Waybar.

Reads the keyboard Hyprland calls main. On this machine that is the
keyd virtual keyboard, so the input group is not required.
The chip is hidden when both locks are off.
"""

from __future__ import annotations

import json
import os
import subprocess


def main_keyboard() -> dict | None:
    env = os.environ.copy()
    raw = subprocess.check_output(["hyprctl", "devices", "-j"], text=True, env=env)
    boards = json.loads(raw).get("keyboards") or []
    for board in boards:
        if board.get("main"):
            return board
    for board in boards:
        if "keyd" in (board.get("name") or ""):
            return board
    return boards[0] if boards else None


# Meslo has no Num Lock key. md-numeric is the # mark, md-caps_lock is
# the caps key. Both are in the bar font.
NUM = "\U000f03a0"
CAPS = "\U000f0a9b"
# 16384 is 16pt, about 21px, against 15px text.
BIG = "<span size='16384'>{}</span>"


def main() -> None:
    board = main_keyboard()
    caps = bool(board and board.get("capsLock"))
    num = bool(board and board.get("numLock"))
    shown = []
    if num:
        shown.append(BIG.format(NUM))
    if caps:
        shown.append(BIG.format(CAPS))
    print(json.dumps({
        "text": "  ".join(shown),
        "tooltip": f"Num Lock {'on' if num else 'off'}\nCaps Lock {'on' if caps else 'off'}",
    }, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
