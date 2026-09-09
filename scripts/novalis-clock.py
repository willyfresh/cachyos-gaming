#!/usr/bin/env python3
"""Print a live Novalis countdown card (stdout). Dates are local-today."""

from __future__ import annotations

import random
import sys
from datetime import date

BORN = date(1984, 11, 20)
BEX_BORN = date(2017, 11, 7)
BEX_18 = date(BEX_BORN.year + 18, BEX_BORN.month, BEX_BORN.day)
MILESTONE_AGES = (65, 90)


def add_years(d: date, years: int) -> date:
    try:
        return d.replace(year=d.year + years)
    except ValueError:
        return d.replace(year=d.year + years, day=28)


YEAR_DAYS = 365.25
SEPARATORS = ("|", "/", "\\", "·", "–", ":", "+")


def age_on(born: date, today: date) -> int:
    years = today.year - born.year
    if (today.month, today.day) < (born.month, born.day):
        years -= 1
    return years


def decade_label_and_end(born: date, today: date) -> tuple[str, date]:
    age = max(0, age_on(born, today))
    decade = (age // 10) * 10
    if decade < 40:
        decade = 40
    return f"{decade}s", add_years(born, decade + 10)


def unit(n: int, word: str) -> str:
    return f"{n} {word}" + ("" if n == 1 else "S")


def span_phrase(start: date, end: date) -> str:
    days = max(0, (end - start).days)
    years = round(days / YEAR_DAYS)
    weeks = round(days / 7)
    a, b = random.choice(SEPARATORS), random.choice(SEPARATORS)
    return f"{unit(years, 'YEAR')} {a} {unit(weeks, 'WEEK')} {b} {unit(days, 'DAY')}"


def facts(today: date | None = None) -> list[str]:
    today = today or date.today()
    lines: list[str] = []

    label, decade_end = decade_label_and_end(BORN, today)
    decade = label.upper()
    if today < decade_end:
        lines.append(f"YOUR {decade}: {span_phrase(today, decade_end)}")
    else:
        lines.append(f"YOUR {decade} ARE BEHIND YOU")

    for age in MILESTONE_AGES:
        target = add_years(BORN, age)
        if today < target:
            lines.append(f"UNTIL {age}: {span_phrase(today, target)}")
        else:
            lines.append(f"{age} IS BEHIND YOU")

    if today < BEX_18:
        lines.append(f"UNTIL BEX IS 18: {span_phrase(today, BEX_18)}")
    else:
        lines.append("BEX IS 18")

    return [ln.upper() for ln in lines]


def main() -> int:
    sys.stdout.write("\n".join(facts()) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
