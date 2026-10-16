#!/usr/bin/env python3
"""Six-month calendar in Fuzzel. Bound to a click on the date chip.

Shows the previous month, the current month, and the next four.
Three months per row so the window stays on a 1080p screen.
"""

from __future__ import annotations

import calendar
import subprocess
from datetime import date

GRID = calendar.TextCalendar(firstweekday=6)
GAP = "   "
COLUMNS = 3
# One previous month, then the current month, then four ahead.
OFFSETS = (-1, 0, 1, 2, 3, 4)


def shift_month(year: int, month: int, delta: int) -> tuple[int, int]:
    index = year * 12 + (month - 1) + delta
    return index // 12, index % 12 + 1


def month_lines(year: int, month: int) -> list[str]:
    return [line.rstrip() for line in GRID.formatmonth(year, month).splitlines()]


def row_lines(blocks: list[list[str]]) -> list[str]:
    widths = [max(len(line) for line in block) for block in blocks]
    height = max(len(block) for block in blocks)
    lines = []
    for index in range(height):
        cells = []
        for block, width in zip(blocks, widths):
            text = block[index] if index < len(block) else ""
            cells.append(text.ljust(width))
        lines.append(GAP.join(cells).rstrip())
    return lines


def calendar_lines(today: date) -> list[str]:
    blocks = []
    for delta in OFFSETS:
        year, month = shift_month(today.year, today.month, delta)
        blocks.append(month_lines(year, month))
    lines: list[str] = []
    for start in range(0, len(blocks), COLUMNS):
        if lines:
            lines.append("")
        lines.extend(row_lines(blocks[start : start + COLUMNS]))
    return lines


def main() -> None:
    lines = calendar_lines(date.today())
    width = max(len(line) for line in lines)
    subprocess.run(
        [
            "fuzzel",
            "--dmenu",
            "--prompt",
            "Calendar  ",
            "--width",
            str(width),
            "--horizontal-pad",
            "12",
            "--lines",
            str(len(lines)),
        ],
        input="\n".join(lines) + "\n",
        text=True,
        check=False,
    )


if __name__ == "__main__":
    main()
