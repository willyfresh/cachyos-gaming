#!/usr/bin/env python3
"""CPU percent and temperature, flanking the chip icon."""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from waybar_level import digits, level

ICON = "\uf2db"
CPU = Path("/sys/devices/pci0000:00/0000:00:18.3/hwmon")
SAMPLE = Path.home() / ".cache" / "novalis" / "cpu-sample"


def cpu_percent() -> int:
    parts = Path("/proc/stat").read_text().splitlines()[0].split()
    nums = [int(n) for n in parts[1:]]
    idle = nums[3] + nums[4]
    total = sum(nums)
    percent = 0
    try:
        prev_idle, prev_total = (int(n) for n in SAMPLE.read_text().split())
        delta = total - prev_total
        if delta > 0:
            percent = round(100 * (delta - (idle - prev_idle)) / delta)
            percent = max(0, min(100, percent))
    except (OSError, ValueError):
        pass
    SAMPLE.parent.mkdir(parents=True, exist_ok=True)
    SAMPLE.write_text(f"{idle} {total}")
    return percent


def cpu_temp_f() -> int | None:
    for path in sorted(CPU.glob("hwmon*/temp1_input")):
        try:
            celsius = int(path.read_text().strip()) / 1000
        except (OSError, ValueError):
            continue
        return round(celsius * 9 / 5 + 32)
    return None


def main() -> None:
    percent = cpu_percent()
    temp = cpu_temp_f()
    print(json.dumps({
        "text": f"{digits(percent, '%')} {ICON} {digits(temp, '°')}",
        "tooltip": "CPU",
        "class": level(temp, percent),
    }, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
