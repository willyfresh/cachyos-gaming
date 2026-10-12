#!/usr/bin/env python3
"""Month calendar in Fuzzel. Bound to a click on the clock."""

from __future__ import annotations

import calendar
import subprocess
from datetime import date


def month_lines(today: date) -> list[str]:
    grid = calendar.TextCalendar(firstweekday=6)
    lines = grid.formatmonth(today.year, today.month).rstrip().splitlines()
    token = str(today.day)
    marked = False
    for index, line in enumerate(lines):
        if index < 2:
            continue
        if token in line.split():
            lines[index] = line.rstrip() + "   today"
            marked = True
            break
    if not marked:
        lines.append(today.strftime("today  %A, %B %-d"))
    return lines


def main() -> None:
    lines = month_lines(date.today())
    subprocess.run(
        [
            "fuzzel",
            "--dmenu",
            "--prompt",
            "Calendar  ",
            "--width",
            "32",
            "--lines",
            str(len(lines)),
        ],
        input="\n".join(lines) + "\n",
        text=True,
        check=False,
    )


if __name__ == "__main__":
    main()
