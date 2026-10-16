#!/usr/bin/env python3
"""CPU percent for Waybar. Degrees replace it when the chip is hot."""

from __future__ import annotations

import json
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from waybar_level import bare, face, level

ICON = "\uf2db"
CPU = Path("/sys/devices/pci0000:00/0000:00:18.3/hwmon")
SAMPLE = Path.home() / ".cache" / "novalis" / "cpu-sample"
# The other screen's chip runs a few milliseconds later. Reuse the
# percent this one just stored instead of measuring that gap.
MIN_GAP = 0.5


def cpu_percent(*, store: bool = True) -> int:
    parts = Path("/proc/stat").read_text().splitlines()[0].split()
    nums = [int(n) for n in parts[1:]]
    idle = nums[3] + nums[4]
    total = sum(nums)
    now = time.monotonic()
    percent = 0
    prev = None
    prev_percent = None
    prev_stamp = None
    try:
        # The saved line is idle, total, last percent, then a timestamp.
        # Only the first two are counters.
        fields = SAMPLE.read_text().split()
        prev = (int(fields[0]), int(fields[1]))
        if len(fields) >= 3:
            prev_percent = int(fields[2])
        if len(fields) >= 4:
            prev_stamp = float(fields[3])
    except (OSError, ValueError, IndexError):
        prev = None
    if (
        store
        and prev_stamp is not None
        and prev_percent is not None
        and now - prev_stamp < MIN_GAP
    ):
        return prev_percent
    if prev is not None:
        prev_idle, prev_total = prev
        delta = total - prev_total
        if delta > 0:
            percent = round(100 * (delta - (idle - prev_idle)) / delta)
            percent = max(0, min(100, percent))
    # The device list peeks without storing, so the bar's next sample
    # still covers the whole interval.
    if store:
        SAMPLE.parent.mkdir(parents=True, exist_ok=True)
        SAMPLE.write_text(f"{idle} {total} {percent} {now:.3f}")
    return percent


def cpu_percent_shown() -> int | None:
    """The percent last drawn on the bar, not a new short sample."""
    try:
        parts = SAMPLE.read_text().split()
        if len(parts) >= 3:
            return int(parts[2])
    except (OSError, ValueError):
        return None
    return None


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
    value, suffix = face(temp, percent)
    print(json.dumps({
        "text": f"{bare(value, suffix)} {ICON}",
        "tooltip": f"CPU\n{bare(percent, '%')}\n{bare(temp, '°')}",
        "class": level(temp, percent),
    }, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
