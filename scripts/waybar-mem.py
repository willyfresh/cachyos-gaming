#!/usr/bin/env python3
"""Memory percent. These modules do not expose a temperature."""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from waybar_level import digits, level

# fa-memory is a RAM stick. md-memory draws as a chip, same idea as the CPU.
ICON = "\uefc5"


def mem_percent() -> int:
    info: dict[str, int] = {}
    for line in Path("/proc/meminfo").read_text().splitlines():
        key, val = line.split(":", 1)
        info[key] = int(val.strip().split()[0])
    total = info["MemTotal"]
    avail = info["MemAvailable"]
    return round(100 * (total - avail) / total)


def main() -> None:
    percent = mem_percent()
    print(json.dumps({
        "text": f"{digits(percent, '%')} {ICON}",
        "tooltip": "Memory\nNo temperature sensor on these modules",
        "class": level(None, percent),
    }, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
