"""Color for a Waybar meter.

Temperature wins. Cold is green, warm is yellow-green, hot is red.
A percent near 100 is red even when the part is cold.
"""

from __future__ import annotations

HOT_F = 175
WARM_F = 140
HOT_PERCENT = 90
WARM_PERCENT = 70


# The device list still pads to three cells so the columns line up.
# The bar uses bare() and does not reserve that width.


def digits(value: int | None, suffix: str, width: int = 3) -> str:
    body = f"{'—':>{width}}" if value is None else f"{value:{width}d}"
    return f"{body}{suffix}"


def bare(value: int | None, suffix: str) -> str:
    """Bar text. No reserved columns, so the chip is only as wide as the number."""
    body = "—" if value is None else str(value)
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


def face(temp_f: int | None, percent: int | None) -> tuple[int | None, str]:
    """Bar number. Degrees replace the percent only when the part is hot."""
    if temp_f is not None and temp_f >= HOT_F:
        return temp_f, "°"
    return percent, "%"
