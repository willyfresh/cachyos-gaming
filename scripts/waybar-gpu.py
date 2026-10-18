#!/usr/bin/env python3
"""RTX busy percent for Waybar. Degrees replace it when the card is hot."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from waybar_level import bare, face, level

# \u takes four hex digits, so \uf08ae was a heart plus "e".
ICON = "<span size='16384'>\U000f08ae</span>"


def read_gpu() -> dict[str, str | int]:
    raw = subprocess.check_output(
        [
            "nvidia-smi",
            "--query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total",
            "--format=csv,noheader,nounits",
        ],
        text=True,
    ).strip().splitlines()[0]
    name, temp_s, util_s, used_s, total_s = [part.strip() for part in raw.split(",")]
    return {
        "name": name,
        "temp": round(float(temp_s) * 9 / 5 + 32),
        "util": round(float(util_s)),
        "used": used_s,
        "total": total_s,
    }


def main() -> None:
    gpu = read_gpu()
    temp = int(gpu["temp"])
    util = int(gpu["util"])
    value, suffix = face(temp, util)
    print(json.dumps({
        "text": f"{bare(value, suffix)} {ICON}",
        "tooltip": (
            f"{gpu['name']}\n"
            f"{bare(util, '%')}\n"
            f"{bare(temp, '°')}\n"
            f"{gpu['used']} MB / {gpu['total']} MB"
        ),
        "class": level(temp, util),
    }, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
