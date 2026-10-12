#!/usr/bin/env python3
"""RTX temperature and busy percent for Waybar."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from waybar_level import digits, level

# \u takes four hex digits, so \uf08ae was a heart plus "e".
ICON = "<span size='16384'>\U000f08ae</span>"
# The card glyph paints past its cell, so the temperature gets two spaces.


def main() -> None:
    raw = subprocess.check_output(
        [
            "nvidia-smi",
            "--query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total",
            "--format=csv,noheader,nounits",
        ],
        text=True,
    ).strip().splitlines()[0]
    name, temp_s, util_s, used_s, total_s = [part.strip() for part in raw.split(",")]
    temp = round(float(temp_s) * 9 / 5 + 32)
    util = round(float(util_s))
    print(json.dumps({
        "text": f"{digits(util, '%')} {ICON}  {digits(temp, '°')}",
        "tooltip": f"{name}\n{used_s} MB / {total_s} MB",
        "class": level(temp, util),
    }, ensure_ascii=False), flush=True)


if __name__ == "__main__":
    main()
