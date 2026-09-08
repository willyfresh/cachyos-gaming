#!/usr/bin/env python3
"""Grow a stem in the rain, bloom a blue flower, lightning, unfold into NOVALIS."""

from __future__ import annotations

import math
import random
import shutil
import sys
import time

GREEN = (92, 255, 107)
LEAF = (60, 180, 80)
BUD = (200, 220, 90)
BLUE = (70, 120, 255)
PETAL = (90, 150, 255)
HEAD = (232, 255, 232)
DIM = (26, 74, 34)
WHITE = (255, 255, 255)
CYAN = (180, 230, 255)
YELLOW = (240, 220, 80)
KATA = "ｱｳｴｵｶｷｹｺｻｼｽｾｿﾀﾂﾃﾅﾆﾇﾈﾊﾋﾎﾏﾐﾑﾒﾓﾔﾕﾗﾘﾜｦ01234589Z*"


def rgb(c: tuple[int, int, int], s: str) -> str:
    r, g, b = c
    return f"\033[38;2;{r};{g};{b}m{s}\033[0m"


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def ease_out(t: float) -> float:
    return 1 - (1 - t) ** 3


class Bloom:
    def __init__(self, logo: str) -> None:
        size = shutil.get_terminal_size((120, 40))
        self.w, self.h = max(40, size.columns), max(20, size.lines)
        self.cx = self.w // 2
        self.ground = self.h - 2
        self.stem_max = max(8, self.h // 2)
        self.logo = [ln.rstrip("\n") for ln in logo.splitlines() if ln.strip()]
        self.rain = []
        for _ in range(max(28, self.w // 3)):
            self.rain.append(
                {
                    "x": random.randint(0, self.w - 1),
                    "y": random.uniform(-self.h, self.h),
                    "v": random.uniform(0.35, 1.1),
                    "ch": random.choice(KATA),
                    "head": random.random() < 0.18,
                }
            )
        self.t0 = time.monotonic()
        self.flash = 0.0
        self.bolt: list[tuple[int, int]] = []
        self.strikes_done = 0
        self.unfold_t = 0.0

    def elapsed(self) -> float:
        return time.monotonic() - self.t0

    def tick_rain(self) -> None:
        for d in self.rain:
            d["y"] += d["v"]
            if d["y"] > self.h + 1:
                d["y"] = random.uniform(-8, -1)
                d["x"] = random.randint(0, self.w - 1)
                d["ch"] = random.choice(KATA)
                d["head"] = random.random() < 0.18

    def make_bolt(self, tx: int, ty: int) -> list[tuple[int, int]]:
        x = random.randint(self.w // 5, 4 * self.w // 5)
        y = 0
        pts = [(x, y)]
        while y < ty:
            y += random.randint(1, 2)
            x += random.randint(-3, 3)
            x = max(1, min(self.w - 2, x))
            # home in near the end
            if y > ty - 6:
                x += 1 if x < tx else -1 if x > tx else 0
            pts.append((x, min(y, ty)))
        pts.append((tx, ty))
        return pts

    def _put(
        self,
        cells: dict[tuple[int, int], tuple[str, tuple[int, int, int]]],
        x: int,
        y: int,
        ch: str,
        col: tuple[int, int, int],
    ) -> None:
        cells[int(x), int(y)] = (ch, col)

    def _slope_char(self, x0: int, y0: int, x1: int, y1: int) -> str:
        dx, dy = x1 - x0, y1 - y0
        if abs(dx) * 2 < abs(dy):
            return "│"
        if abs(dy) * 2 < abs(dx):
            return "_" if dy > 0 else "-"
        # y grows downward on the terminal
        if dx * dy < 0:
            return "/"
        return "\\"

    def _line(
        self,
        cells: dict[tuple[int, int], tuple[str, tuple[int, int, int]]],
        x0: int,
        y0: int,
        x1: int,
        y1: int,
        col: tuple[int, int, int],
    ) -> None:
        x0, y0, x1, y1 = int(x0), int(y0), int(x1), int(y1)
        dx, dy = abs(x1 - x0), abs(y1 - y0)
        sx = 1 if x0 < x1 else -1
        sy = 1 if y0 < y1 else -1
        err = dx - dy
        x, y = x0, y0
        while True:
            nx, ny = x, y
            e2 = 2 * err
            if e2 > -dy:
                err -= dy
                nx += sx
            if e2 < dx:
                err += dx
                ny += sy
            self._put(cells, x, y, self._slope_char(x, y, nx, ny), col)
            if x == x1 and y == y1:
                break
            x, y = nx, ny

    def _stem_x(self, i: int) -> int:
        t = i / max(self.stem_max, 1)
        # Gentle S-curve: lean one way, then the other.
        return int(round(self.cx + 3.4 * math.sin(t * math.pi * 1.2) + 1.1 * math.sin(t * math.pi * 2.4)))

    def _leaf(
        self,
        cells: dict[tuple[int, int], tuple[str, tuple[int, int, int]]],
        ax: int,
        ay: int,
        left: bool,
    ) -> None:
        s = -1 if left else 1
        # Midrib, then a pointed outline — all ASCII lines.
        tipx, tipy = ax + s * 7, ay - 2
        self._line(cells, ax + s, ay, tipx, tipy, LEAF)
        self._line(cells, ax + s, ay, ax + s * 3, ay + 1, LEAF)
        self._line(cells, ax + s * 3, ay + 1, tipx, tipy, LEAF)
        self._line(cells, ax + s, ay, ax + s * 4, ay - 3, LEAF)
        self._line(cells, ax + s * 4, ay - 3, tipx, tipy, LEAF)

    def _petals(
        self,
        cells: dict[tuple[int, int], tuple[str, tuple[int, int, int]]],
        fx: int,
        fy: int,
        bloom: float,
    ) -> None:
        # Five line-drawn petals around the center. bloom 0..1 opens them.
        n = max(1, int(5 * bloom))
        length = 2.2 + 3.2 * bloom
        for i in range(n):
            ang = -math.pi / 2 + i * (2 * math.pi / 5)
            tx = fx + int(round(math.cos(ang) * length))
            ty = fy + int(round(math.sin(ang) * length * 0.72))
            # petal edges (two sides of a teardrop)
            perp = ang + math.pi / 2
            wx = 1.4 * bloom * math.cos(perp)
            wy = 1.1 * bloom * math.sin(perp)
            mx = fx + int(round(math.cos(ang) * length * 0.45 + wx))
            my = fy + int(round(math.sin(ang) * length * 0.45 * 0.72 + wy))
            nx = fx + int(round(math.cos(ang) * length * 0.45 - wx))
            ny = fy + int(round(math.sin(ang) * length * 0.45 * 0.72 - wy))
            self._line(cells, fx, fy, mx, my, PETAL)
            self._line(cells, mx, my, tx, ty, BLUE)
            self._line(cells, fx, fy, nx, ny, PETAL)
            self._line(cells, nx, ny, tx, ty, BLUE)

    def _stamen(
        self,
        cells: dict[tuple[int, int], tuple[str, tuple[int, int, int]]],
        fx: int,
        fy: int,
        bloom: float,
    ) -> None:
        # Yellow filaments + anthers (the stamen).
        n = 5 if bloom > 0.7 else 3
        for i in range(n):
            ang = -math.pi / 2 + (i - (n - 1) / 2) * 0.45
            length = 1.2 + bloom * 1.6
            tx = fx + int(round(math.cos(ang) * length))
            ty = fy + int(round(math.sin(ang) * length * 0.7)) - 1
            self._line(cells, fx, fy, tx, ty, YELLOW)
            self._put(cells, tx, ty, "*", YELLOW)
        self._put(cells, fx, fy, "o", YELLOW)

    def plant(
        self, e: float
    ) -> tuple[str, dict[tuple[int, int], tuple[str, tuple[int, int, int]]], tuple[int, int]]:
        """Return phase, cells, and the flower-head position."""
        cells: dict[tuple[int, int], tuple[str, tuple[int, int, int]]] = {}
        # Faster stem: ~3s to full height.
        stem_t = min(1.0, e / 3.0)
        stem_len = int(self.stem_max * stem_t)
        pts = [(self._stem_x(i), self.ground - i) for i in range(stem_len + 1)]
        for i, (x, y) in enumerate(pts):
            if i + 1 < len(pts):
                self._line(cells, x, y, pts[i + 1][0], pts[i + 1][1], GREEN)
            else:
                self._put(cells, x, y, "│", GREEN)
        fx, fy = pts[-1] if pts else (self.cx, self.ground)

        # Leaves once the stem has passed their height.
        for li, frac in enumerate((0.32, 0.58)):
            hi = int(self.stem_max * frac)
            if stem_len < hi + 1:
                continue
            lx, ly = pts[hi]
            self._leaf(cells, lx, ly, left=(li % 2 == 0))

        phase = "stem"
        if e < 3.0:
            return phase, cells, (fx, fy)

        # Bud at the curved tip.
        self._put(cells, fx, fy, "o", BUD)
        self._put(cells, fx, fy - 1, ".", YELLOW)
        phase = "bud"
        if e < 4.2:
            return phase, cells, (fx, fy)

        bloom = min(1.0, (e - 4.2) / 3.2)
        phase = "bloom" if bloom < 1.0 else "full"
        self._petals(cells, fx, fy, bloom)
        self._stamen(cells, fx, fy, bloom)
        return phase, cells, (fx, fy)

    def logo_cells(self) -> list[tuple[int, int, str]]:
        rows = self.logo
        lh = len(rows)
        lw = max(len(r) for r in rows)
        x0 = max(0, (self.w - lw) // 2)
        y0 = max(0, (self.h - lh) // 2 - 1)
        out = []
        for yi, row in enumerate(rows):
            for xi, ch in enumerate(row):
                if ch != " ":
                    out.append((x0 + xi, y0 + yi, ch))
        return out

    def render(
        self,
        plant: dict[tuple[int, int], tuple[str, tuple[int, int, int]]],
        extra: dict[tuple[int, int], tuple[str, tuple[int, int, int]]] | None = None,
        bg_flash: tuple[int, int, int] | None = None,
    ) -> str:
        grid = [[" "] * self.w for _ in range(self.h)]
        color: dict[tuple[int, int], tuple[int, int, int]] = {}
        for d in self.rain:
            x, y = d["x"], int(d["y"])
            if 0 <= x < self.w and 0 <= y < self.h:
                grid[y][x] = d["ch"]
                color[x, y] = HEAD if d["head"] else DIM
        for (x, y), (ch, col) in plant.items():
            if 0 <= x < self.w and 0 <= y < self.h:
                grid[y][x] = ch
                color[x, y] = col
        if extra:
            for (x, y), (ch, col) in extra.items():
                if 0 <= x < self.w and 0 <= y < self.h:
                    grid[y][x] = ch
                    color[x, y] = col
        for x, y in self.bolt:
            if 0 <= x < self.w and 0 <= y < self.h:
                grid[y][x] = random.choice("│/\\")
                color[x, y] = WHITE
        lines = []
        for y in range(self.h):
            parts = []
            for x in range(self.w):
                ch = grid[y][x]
                if ch == " ":
                    parts.append(" ")
                else:
                    parts.append(rgb(color.get((x, y), GREEN), ch))
            lines.append("".join(parts))
        prefix = "\033[H"
        if bg_flash:
            r, g, b = bg_flash
            prefix = f"\033[48;2;{r};{g};{b}m" + prefix
        suffix = "\033[49m" if bg_flash else ""
        return prefix + "\n".join(lines) + suffix

    def run(self) -> None:
        sys.stdout.write("\033[?25l\033[2J\033[H\033[?2026h")
        sys.stdout.flush()
        logo = self.logo_cells()
        fx, fy = self.cx, self.ground - self.stem_max
        unfold = False
        unfold_t0 = 0.0
        last_strike_at = 0.0
        try:
            while True:
                e = self.elapsed()
                self.tick_rain()
                extra: dict[tuple[int, int], tuple[str, tuple[int, int, int]]] = {}
                flash = None
                phase, plant = self.plant(e)
                if plant:
                    ys = [y for (x, y) in plant if x == self.cx]
                    if ys:
                        fy = min(ys)
                        fx = self.cx

                if not unfold:
                    if 14.0 <= e < 14.18 or 14.45 <= e < 14.6:
                        # two very quick strikes that miss / flash the sky
                        if self.strikes_done < (1 if e < 14.4 else 2):
                            self.bolt = self.make_bolt(self.cx + random.randint(-6, 6), fy + 4)
                            self.strikes_done = 1 if e < 14.4 else 2
                            last_strike_at = e
                        flash = (40, 50, 70) if (e - last_strike_at) < 0.06 else (10, 14, 22)
                    elif e >= 15.05 and self.strikes_done < 3:
                        self.bolt = self.make_bolt(self.cx, fy)
                        self.strikes_done = 3
                        last_strike_at = e
                    if self.strikes_done == 3 and e - last_strike_at < 0.12:
                        flash = (220, 230, 255)
                    if self.strikes_done == 3 and e - last_strike_at >= 0.12:
                        unfold = True
                        unfold_t0 = time.monotonic()
                        self.bolt = []

                if unfold:
                    t = min(1.0, (time.monotonic() - unfold_t0) / 2.4)
                    te = ease_out(t)
                    extra = {}
                    for x1, y1, ch in logo:
                        x = int(round(lerp(fx, x1, te)))
                        y = int(round(lerp(fy, y1, te)))
                        col = WHITE if t < 0.15 else PETAL if t < 0.4 else GREEN
                        extra[x, y] = (ch, col)
                    plant = {} if t > 0.2 else plant
                    if t >= 1.0:
                        sys.stdout.write(self.render({}, extra))
                        sys.stdout.flush()
                        time.sleep(0.8)
                        break

                sys.stdout.write("\033[?2026h")
                sys.stdout.write(self.render(plant, extra, flash))
                sys.stdout.write("\033[?2026l")
                sys.stdout.flush()
                time.sleep(1 / 30)
        finally:
            sys.stdout.write("\033[?25h\033[?2026l\033[49m")
            sys.stdout.flush()


def main() -> int:
    path = sys.argv[1] if len(sys.argv) > 1 else ""
    if not path:
        print("usage: novalis-bloom.py LOGO.txt", file=sys.stderr)
        return 2
    text = open(path, encoding="utf-8").read()
    Bloom(text).run()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        raise SystemExit(0)
