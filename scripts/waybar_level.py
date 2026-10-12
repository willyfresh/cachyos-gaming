"""Color for a Waybar meter.

Temperature wins. Cold is green, warm is yellow-green, hot is red.
A percent near 100 is red even when the part is cold.
"""

from __future__ import annotations

HOT_F = 175
WARM_F = 140
HOT_PERCENT = 90
WARM_PERCENT = 70


# Three cells covers a percent (0–100) and a Fahrenheit reading.
# Normal peaks stay under 999. The bar face is monospace, so a 1
# stays as wide as an 8 without a second font.


def digits(value: int | None, suffix: str, width: int = 3) -> str:
    body = f"{'—':>{width}}" if value is None else f"{value:{width}d}"
    return f"{body}{suffix}"


def level(temp_f: int | None, percent: int | None) -> str:
    if percent is not None and percent >= HOT_PERCENT:
        return "hot"
    if temp_f is not None:
        if temp_f >= HOT_F:
            return "hot"
        if temp_f >= WARM_F:
            return "warm"
        return "cold"
    if percent is not None and percent >= WARM_PERCENT:
        return "warm"
    return "cold"
