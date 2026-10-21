#!/usr/bin/env python3
"""Microphone volume for Waybar.

Sits beside the speaker chip. The icon is a few pixels larger than the
14px bar text. The readout turns red while the dictation model is off
the GPU.
"""

from __future__ import annotations

import json
import os
import select
import subprocess
import sys
from pathlib import Path

# 14336 is 14pt, about 18px. The bar text is 14px.
ICON = "<span size='14336'>{}</span>"
MIC = "\uf130"
MUTED = "\uf131"
FLAG = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")) / "hyprwhspr" / "model_unloaded"


def volume() -> tuple[int | None, bool]:
    try:
        out = subprocess.check_output(
            ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return None, False
    muted = "MUTED" in out
    parts = out.split()
    try:
        pct = round(float(parts[1]) * 100)
    except (IndexError, ValueError):
        return None, muted
    return pct, muted


def line() -> str:
    pct, muted = volume()
    off = FLAG.exists()
    if pct is None:
        text = "—"
        tip = "No microphone"
    elif muted:
        text = ICON.format(MUTED)
        tip = "Microphone muted"
    else:
        text = f"{pct}% {ICON.format(MIC)}"
        tip = f"Microphone {pct}%"
    tip += "\nDictation model is off the GPU" if off else "\nDictation model is on the GPU"
    payload: dict[str, str] = {"text": text, "tooltip": tip}
    if off:
        payload["class"] = "unloaded"
    return json.dumps(payload, ensure_ascii=False)


def main() -> None:
    sys.stdout.reconfigure(line_buffering=True)
    proc = subprocess.Popen(
        ["pactl", "subscribe"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    assert proc.stdout is not None
    fd = proc.stdout.fileno()
    last = None
    while proc.poll() is None:
        select.select([fd], [], [], 0.4)
        while True:
            ready, _, _ = select.select([fd], [], [], 0)
            if not ready:
                break
            if not proc.stdout.readline():
                return
        current = line()
        if current != last:
            print(current, flush=True)
            last = current


if __name__ == "__main__":
    main()
