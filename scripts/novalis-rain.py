#!/usr/bin/env python3
"""Matrix rain that never stops. A cell scrambles for a few rain-head
hits, then locks white. After the hold, locked glyphs dissolve downward
into the rain. Cycle: fact -> NOVALIS -> next fact -> ...
"""

from __future__ import annotations

import importlib.util
import random
import shutil
import sys
import time
from pathlib import Path

HEAD = (232, 255, 232)
GREEN = (92, 255, 107)
MID = (40, 140, 50)
DIM = (0, 59, 20)
WHITE = (255, 255, 255)
KATA = (
    "2", "5", "9", "8", "Z", "*", ")", ":", ".", "=", "+", "-", "|", "_",
    "ｦ", "ｱ", "ｳ", "ｴ", "ｵ", "ｶ", "ｷ", "ｹ", "ｺ", "ｻ", "ｼ", "ｽ", "ｾ", "ｿ",
    "ﾀ", "ﾂ", "ﾃ", "ﾅ", "ﾆ", "ﾇ", "ﾈ", "ﾊ", "ﾋ", "ﾎ", "ﾏ", "ﾐ", "ﾑ", "ﾒ",
    "ﾓ", "ﾔ", "ﾕ", "ﾗ", "ﾘ", "ﾜ",
)
FACT_HOLD = 12.0
LOGO_HOLD = 8.0
HITS_NEEDED = (4, 7)
FPS = 30
DIGITS = "0123456789"
LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


def rgb(c: tuple[int, int, int], s: str) -> str:
    r, g, b = c
    return f"\033[38;2;{r};{g};{b}m{s}\033[0m"


def load_facts() -> list[str]:
    path = Path(__file__).resolve().parent / "novalis-clock.py"
    spec = importlib.util.spec_from_file_location("novalis_clock", path)
    if spec is None or spec.loader is None:
        return []
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return [ln for ln in mod.facts() if ln.strip()]


def lerp_color(a: tuple[int, int, int], b: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    t = max(0.0, min(1.0, t))
    return (
        int(a[0] + (b[0] - a[0]) * t),
        int(a[1] + (b[1] - a[1]) * t),
        int(a[2] + (b[2] - a[2]) * t),
    )


def trail_color(i: int, length: int) -> tuple[int, int, int]:
    if i == 0:
        return HEAD
    t = i / max(length - 1, 1)
    if t < 0.35:
        return lerp_color(GREEN, MID, t / 0.35)
    return lerp_color(MID, DIM, (t - 0.35) / 0.65)


class Scene:
    def __init__(self, logo: str, seed: int | None = None) -> None:
        if seed is not None:
            random.seed(seed)
        size = shutil.get_terminal_size((120, 40))
        self.w = max(40, size.columns)
        self.h = max(20, size.lines)
        self.logo = [ln.rstrip("\n") for ln in logo.splitlines()]
        self.columns = [self._spawn(x, y=random.uniform(-self.h, self.h)) for x in range(self.w)]
        self.targets: dict[tuple[int, int], str] = {}
        self.need: dict[tuple[int, int], int] = {}
        self.hits: dict[tuple[int, int], int] = {}
        self.shown: dict[tuple[int, int], str] = {}
        self.locked: dict[tuple[int, int], str] = {}
        self.pending_fall: list[dict] = []
        self.falling: list[dict] = []
        self.hold_from: float | None = None
        self.phase_started = time.monotonic()
        self.phase = "fact"
        self.next_phase = "logo"
        self.logo_style = "touch"
        self.fact_i = 0
        self.facts = load_facts()
        self.set_fact_target()

    def _spawn(self, x: int, y: float | None = None) -> dict:
        if y is None:
            y = -float(random.randint(2, 20))
            wait = random.uniform(0.0, 1.2)
        else:
            wait = 0.0
        return {
            "x": x,
            "y": y,
            "v": random.uniform(14.0, 32.0),
            "length": random.randint(10, 26),
            "glyphs": [random.choice(KATA) for _ in range(28)],
            "wait": wait,
            "last_head": None,
        }

    def logo_targets(self) -> dict[tuple[int, int], str]:
        if not any(ln.strip() for ln in self.logo):
            return {}
        lw = max((len(r) for r in self.logo), default=0)
        lh = len(self.logo)
        x0 = max(0, (self.w - lw) // 2)
        y0 = max(0, (self.h - lh) // 2)
        out: dict[tuple[int, int], str] = {}
        for yi, row in enumerate(self.logo):
            for xi, ch in enumerate(row):
                if ch != " ":
                    out[x0 + xi, y0 + yi] = ch
        return out

    def fact_targets(self, fact: str) -> dict[tuple[int, int], str]:
        fact = fact.strip()
        if not fact:
            return {}
        x0 = max(0, (self.w - len(fact)) // 2)
        y0 = self.h // 2
        return {(x0 + i, y0): ch for i, ch in enumerate(fact) if ch != " "}

    def scramble(self, target: str) -> str:
        if target.isdigit():
            pool = [c for c in DIGITS if c != target]
        elif target.isalpha():
            pool = [c for c in LETTERS if c != target.upper()]
        else:
            pool = [c for c in KATA if c != target]
        return random.choice(pool) if pool else target

    def arm_targets(
        self,
        targets: dict[tuple[int, int], str],
        phase: str,
        need: dict[tuple[int, int], int] | None = None,
    ) -> None:
        self.targets = targets
        self.need = need if need is not None else {k: random.randint(*HITS_NEEDED) for k in targets}
        self.hits = {}
        self.shown = {}
        self.locked = {}
        self.pending_fall = []
        self.falling = []
        self.hold_from = None
        self.phase = phase
        self.phase_started = time.monotonic()

    def set_fact_target(self) -> None:
        if not self.facts:
            self.facts = load_facts()
        if not self.facts:
            self.arm_targets({}, "fact")
            return
        fact = self.facts[self.fact_i % len(self.facts)]
        self.arm_targets(self.fact_targets(fact), "fact")

    def set_logo_target(self) -> None:
        targets = self.logo_targets()
        style = random.choice(("touch", "scramble", "drip"))
        self.logo_style = style
        if style == "touch":
            need = {k: 1 for k in targets}
        elif style == "scramble":
            need = {k: random.randint(2, 4) for k in targets}
        else:
            need = {k: 1 for k in targets}
        self.arm_targets(targets, "logo", need=need)
        self.logo_style = style

    def begin_dissolve(self, now: float) -> None:
        if self.phase == "fact":
            self.next_phase = "logo"
        else:
            self.next_phase = "fact"
            self.fact_i += 1
            if self.fact_i % max(len(self.facts), 1) == 0:
                self.facts = load_facts()
                self.fact_i = 0
        min_y = min((y for (_, y) in self.locked), default=0)
        self.pending_fall = []
        for (x, y), ch in self.locked.items():
            self.pending_fall.append(
                {
                    "x": x,
                    "y": float(y),
                    "ch": ch,
                    "v": random.uniform(22.0, 42.0),
                    "at": now + (y - min_y) * 0.055 + random.uniform(0.0, 0.22),
                    "born": now,
                }
            )
        self.falling = []
        self.targets = {}
        self.need = {}
        self.hits = {}
        self.shown = {}
        self.hold_from = None
        self.phase = "dissolve"

    def hit(self, key: tuple[int, int]) -> None:
        if key not in self.targets or key in self.locked:
            return
        if self.phase == "logo" and self.logo_style == "drip":
            min_y = min((y for (_, y) in self.targets), default=0)
            reveal_y = min_y + (time.monotonic() - self.phase_started) * 14.0
            if key[1] > reveal_y:
                return
        self.hits[key] = self.hits.get(key, 0) + 1
        if self.hits[key] >= self.need[key]:
            ch = self.targets[key]
            self.locked[key] = ch
            self.shown[key] = ch
        else:
            self.shown[key] = self.scramble(self.targets[key])

    def tick(self, dt: float, now: float) -> None:
        for col in self.columns:
            if col["wait"] > 0:
                col["wait"] -= dt
                continue
            col["y"] += col["v"] * dt
            head = int(col["y"])
            x = col["x"]
            length = col["length"]
            if head - length > self.h:
                self.columns[x] = self._spawn(x)
                continue
            if (
                self.phase != "dissolve"
                and col["last_head"] != head
                and 0 <= x < self.w
                and 0 <= head < self.h
            ):
                self.hit((x, head))
            col["last_head"] = head
            if random.random() < 0.08:
                col["glyphs"][head % len(col["glyphs"])] = random.choice(KATA)

        if self.phase == "dissolve":
            still_pending = []
            for spec in self.pending_fall:
                if now >= spec["at"]:
                    spec["born"] = now
                    self.falling.append(spec)
                    self.locked.pop((spec["x"], int(spec["y"])), None)
                else:
                    still_pending.append(spec)
            self.pending_fall = still_pending
            live = []
            for spec in self.falling:
                spec["y"] += spec["v"] * dt
                if spec["y"] < self.h + 2:
                    if now - spec["born"] > 0.18 and random.random() < 0.35:
                        spec["ch"] = random.choice(KATA)
                    live.append(spec)
            self.falling = live
            if not self.pending_fall and not self.falling and not self.locked:
                if self.next_phase == "logo":
                    self.set_logo_target()
                else:
                    self.set_fact_target()
            return

        if self.targets and self.hold_from is None and len(self.locked) >= len(self.targets):
            self.hold_from = now
        hold = FACT_HOLD if self.phase == "fact" else LOGO_HOLD
        if self.hold_from is not None and now - self.hold_from >= hold:
            self.begin_dissolve(now)

    def render(self) -> str:
        grid = [[" "] * self.w for _ in range(self.h)]
        color: dict[tuple[int, int], tuple[int, int, int]] = {}
        for col in self.columns:
            if col["wait"] > 0:
                continue
            x = col["x"]
            head = int(col["y"])
            length = col["length"]
            glyphs = col["glyphs"]
            for i in range(length):
                y = head - i
                if not (0 <= x < self.w and 0 <= y < self.h):
                    continue
                if (x, y) in self.locked or (x, y) in self.shown:
                    continue
                grid[y][x] = glyphs[y % len(glyphs)]
                color[x, y] = trail_color(i, length)
        for (x, y), ch in self.shown.items():
            if (x, y) in self.locked:
                continue
            if 0 <= x < self.w and 0 <= y < self.h:
                grid[y][x] = ch
                color[x, y] = HEAD
        for (x, y), ch in self.locked.items():
            if 0 <= x < self.w and 0 <= y < self.h:
                grid[y][x] = ch
                color[x, y] = WHITE
        for spec in self.falling:
            x, y = spec["x"], int(spec["y"])
            if 0 <= x < self.w and 0 <= y < self.h:
                age = max(0.0, time.monotonic() - spec["born"])
                grid[y][x] = spec["ch"]
                color[x, y] = WHITE if age < 0.12 else trail_color(min(int(age * 12), 8), 10)
        lines = []
        for y in range(self.h):
            parts = []
            for x in range(self.w):
                ch = grid[y][x]
                parts.append(" " if ch == " " else rgb(color.get((x, y), GREEN), ch))
            lines.append("".join(parts))
        return "\033[H" + "\n".join(lines)

    def run(self) -> None:
        sys.stdout.write("\033[?25l\033[2J\033[H\033[?2026h")
        sys.stdout.flush()
        frame = 1.0 / FPS
        last = time.monotonic()
        try:
            while True:
                now = time.monotonic()
                dt = min(0.08, now - last)
                last = now
                self.tick(dt, now)
                sys.stdout.write(self.render())
                sys.stdout.flush()
                spent = time.monotonic() - now
                if spent < frame:
                    time.sleep(frame - spent)
        finally:
            sys.stdout.write("\033[?2026l")
            sys.stdout.flush()


def main(argv: list[str]) -> int:
    logo_path = ""
    seed: int | None = None
    args = [a for a in argv[1:] if a != "run"]
    i = 0
    while i < len(args):
        if args[i] == "--seed" and i + 1 < len(args):
            seed = int(args[i + 1])
            i += 2
            continue
        if args[i] == "--measure-logical" and i + 1 < len(args):
            i += 2
            continue
        if args[i] == "--logo" and i + 1 < len(args):
            logo_path = args[i + 1]
            i += 2
            continue
        if not args[i].startswith("-") and not logo_path:
            logo_path = args[i]
        i += 1
    if not logo_path:
        print("usage: novalis-rain.py LOGO.txt [--seed N]", file=sys.stderr)
        return 2
    text = Path(logo_path).read_text(encoding="utf-8")
    Scene(text, seed=seed).run()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv))
    except KeyboardInterrupt:
        raise SystemExit(0)
