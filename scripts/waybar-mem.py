#!/usr/bin/env python3
"""Memory percent. These modules do not expose a temperature."""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from waybar_level import bare, face, level

# fa-memory is a RAM stick. md-memory draws as a chip, same idea as the CPU.
ICON = "\uefc5"


def mem_bytes() -> tuple[int, int]:
    """Used and total, in bytes. These modules do not expose a temperature."""
    info: dict[str, int] = {}
    for line in Path("/proc/meminfo").read_text().splitlines():
        key, val = line.split(":", 1)
        info[key] = int(val.strip().split()[0])
    total = info["MemTotal"] * 1024
    used = (info["MemTotal"] - info["MemAvailable"]) * 1024
    return used, total


def mem_percent() -> int:
    used, total = mem_bytes()
    return round(100 * used / total) if total else 0


def gb(n: int) -> str:
    return f"{n / (1024 ** 3):.0f}G"


def main() -> None:
    percent = mem_percent()
    used, total = mem_bytes()
    value, suffix = face(None, percent)
    print(json.dumps({
        "text": f"{bare(value, suffix)} {ICON}",
        "tooltip": f"Memory\n{gb(used)} / {gb(total)}",
        "class": level(None, percent),
    }, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
