#!/usr/bin/env python3
"""Flicker NOVALIS, then onion-peel every outer layer (including the top)
outward into a rain tunnel — never back to the center."""

from __future__ import annotations

import math
import random
import sys

from dataclasses import dataclass

from terminaltexteffects import Color, ColorPair, Coord, EffectCharacter, Scene, easing
from terminaltexteffects.engine.base_character import EventHandler
from terminaltexteffects.engine.base_config import BaseConfig
from terminaltexteffects.engine.base_effect import BaseEffect, BaseEffectIterator
from terminaltexteffects.engine.terminal import TerminalConfig

GREEN = Color("#5CFF6B")
HEAD = Color("#E8FFE8")
DIM = Color("#1A4A22")
KATA = list("ｱｳｴｵｶｷｹｺｻｼｽｾｿﾀﾂﾃﾅﾆﾇﾈﾊﾋﾎﾏﾐﾑﾒﾓﾔﾕﾗﾘﾜｦ01234589Z*+|")


@dataclass
class TunnelConfig(BaseConfig):
    """Library-only config; not registered as a tte CLI plugin."""


def onion_layers(chars: list[EffectCharacter]) -> list[list[EffectCharacter]]:
    """Outermost silhouette first, including the top of the wordmark."""
    remaining = {(c.input_coord.column, c.input_coord.row): c for c in chars}
    layers: list[list[EffectCharacter]] = []
    neigh = ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1))
    while remaining:
        keys = set(remaining)
        edge = [
            ch
            for (x, y), ch in remaining.items()
            if any((x + dx, y + dy) not in keys for dx, dy in neigh)
        ]
        if not edge:
            edge = list(remaining.values())
        layers.append(edge)
        for ch in edge:
            del remaining[(ch.input_coord.column, ch.input_coord.row)]
    return layers


def ray_to_edge(cx: float, cy: float, x: float, y: float, canvas) -> Coord:
    dx, dy = x - cx, y - cy
    if dx == 0 and dy == 0:
        dx = random.choice((-1.0, 1.0))
    hits: list[float] = []
    if dx > 0:
        hits.append((canvas.right - cx) / dx)
    elif dx < 0:
        hits.append((canvas.left - cx) / dx)
    if dy > 0:
        hits.append((canvas.top - cy) / dy)
    elif dy < 0:
        hits.append((canvas.bottom - cy) / dy)
    t = min((h for h in hits if h > 0), default=1.0)
    # Past the frame a bit so the zoom flies off-screen (through the camera).
    t *= 1.35
    return Coord(int(round(cx + t * dx)), int(round(cy + t * dy)))


class TunnelIterator(BaseEffectIterator[TunnelConfig]):
    def __init__(self, effect: Tunnel) -> None:
        super().__init__(effect)
        self.hold = 0
        self.phase = "flicker"
        self.layers: list[list[EffectCharacter]] = []
        self.layer_i = 0
        self.layer_wait = 0
        self.build()

    def build(self) -> None:
        chars = [c for c in self.terminal.get_characters() if c.input_symbol.strip()]
        if not chars:
            self.phase = "done"
            return
        xs = [c.input_coord.column for c in chars]
        ys = [c.input_coord.row for c in chars]
        self._cx = (min(xs) + max(xs)) / 2
        self._cy = (min(ys) + max(ys)) / 2
        self._canvas = self.terminal.canvas
        self.layers = onion_layers(chars)

        for ch in chars:
            self.terminal.set_character_visibility(ch, is_visible=False)
            delay = random.randint(0, 14)
            flicker = ch.animation.new_scene()
            for _ in range(delay):
                flicker.add_frame(" ", 1, colors=ColorPair(fg=DIM))
            for _ in range(random.randint(3, 7)):
                flicker.add_frame(ch.input_symbol, 2, colors=ColorPair(fg=HEAD))
                flicker.add_frame(" ", 1, colors=ColorPair(fg=DIM))
                flicker.add_frame(ch.input_symbol, 3, colors=ColorPair(fg=GREEN))
            flicker.add_frame(ch.input_symbol, 16, colors=ColorPair(fg=GREEN))
            ch.animation.activate_scene(flicker)
            self.terminal.set_character_visibility(ch, is_visible=True)
            self.active_characters.add(ch)

        self.hold = 36

    def _peel_layer(self, layer: list[EffectCharacter]) -> None:
        canvas = self._canvas
        cx, cy = self._cx, self._cy
        n = max(len(self.layers), 1)
        # Outer rings (first peels) rush faster — they are the near wall.
        speed = 0.85 - (self.layer_i / n) * 0.4
        for ch in layer:
            x, y = ch.input_coord.column, ch.input_coord.row
            dx, dy = x - cx, y - cy
            length = math.hypot(dx, dy) or 1.0
            # Separate a little, then zoom past the frame along the same ray.
            sep = Coord(
                int(round(cx + dx / length * (length + 3))),
                int(round(cy + dy / length * (length + 2))),
            )
            edge = ray_to_edge(cx, cy, x, y, canvas)

            rain = ch.animation.new_scene(sync=Scene.SyncMetric.STEP)
            for _ in range(36):
                rain.add_frame(
                    random.choice(KATA),
                    2,
                    colors=ColorPair(fg=HEAD if random.random() < 0.22 else GREEN),
                )

            fly = ch.motion.new_path(speed=speed, ease=easing.in_cubic)
            fly.new_waypoint(sep)
            fly.new_waypoint(edge)

            ch.event_handler.register_event(
                EventHandler.Event.PATH_ACTIVATED,
                fly,
                EventHandler.Action.ACTIVATE_SCENE,
                rain,
            )
            ch.motion.activate_path(fly)
            self.active_characters.add(ch)

    def __next__(self) -> str:
        if self.phase == "done" and not self.active_characters:
            raise StopIteration

        if self.phase == "flicker":
            self.update()
            if not any(ch.animation.active_scene for ch in self.terminal.get_characters()):
                self.hold -= 1
                if self.hold <= 0:
                    self.phase = "peel"
                    self.layer_wait = 0
            return self.frame

        if self.phase == "peel":
            if self.layer_wait <= 0 and self.layer_i < len(self.layers):
                self._peel_layer(self.layers[self.layer_i])
                self.layer_i += 1
                self.layer_wait = 8
            else:
                self.layer_wait -= 1
            self.update()
            if self.layer_i >= len(self.layers) and not self.active_characters:
                self.phase = "done"
            return self.frame

        self.update()
        return self.frame


class Tunnel(BaseEffect[TunnelConfig]):
    @property
    def _config_cls(self) -> type[TunnelConfig]:
        return TunnelConfig

    @property
    def _iterator_cls(self) -> type[TunnelIterator]:
        return TunnelIterator


def main() -> int:
    logo_path = sys.argv[1] if len(sys.argv) > 1 else ""
    if not logo_path:
        print("usage: novalis-tunnel.py LOGO.txt", file=sys.stderr)
        return 2
    text = open(logo_path, encoding="utf-8").read()
    cfg = TerminalConfig._build_config()
    cfg.frame_rate = 60
    cfg.anchor_canvas = "c"
    cfg.anchor_text = "c"
    cfg.canvas_width = 0
    cfg.canvas_height = 0
    cfg.no_eol = True
    cfg.no_restore_cursor = True
    cfg.reuse_canvas = True
    cfg.terminal_background_color = Color("#000000")
    effect = Tunnel(text, terminal_config=cfg)
    with effect.terminal_output(end_symbol="") as terminal:
        for frame in effect:
            terminal.print(frame)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        raise SystemExit(0)
