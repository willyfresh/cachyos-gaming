#!/usr/bin/env python3
"""Now playing from playerctl. Click pauses or resumes that player."""

from __future__ import annotations

import json
import subprocess
import sys
from dataclasses import dataclass

# Bar font is MesloLGS Nerd Font Mono at 14px: 8px per cell. The chip
# padding is 10px on each side. The label stops at a quarter of the screen.
CELL_PX = 8
PAD_PX = 20


def run(args: list[str]) -> str:
    return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL).strip()


def pango(text: str) -> str:
    # Titles are markup. An ampersand or a bracket otherwise eats the rest
    # of the line, which is what made some song names look blank.
    kept = "".join(ch for ch in text if ch == "\n" or ord(ch) >= 32)
    return kept.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


@dataclass
class Player:
    name: str
    status: str
    title: str
    artist: str

    @property
    def mark(self) -> str:
        return "▶" if self.status == "Playing" else "❚❚"


def players() -> list[Player]:
    try:
        names = [line for line in run(["playerctl", "-l"]).splitlines() if line]
    except (OSError, subprocess.CalledProcessError):
        return []
    found: list[Player] = []
    for name in names:
        try:
            status = run(["playerctl", "-p", name, "status"])
        except (OSError, subprocess.CalledProcessError):
            continue
        found.append(Player(name, status, meta(name, "xesam:title"), meta(name, "xesam:artist")))
    return found


def meta(player: str, key: str) -> str:
    try:
        return run(["playerctl", "-p", player, "metadata", key])
    except (OSError, subprocess.CalledProcessError):
        return ""


def rank(player: Player) -> tuple[int, int]:
    # Chromium keeps a second instance that is Stopped and has no title.
    # Pausing used to select that one, so the chip said Unknown and the
    # click did not resume the track.
    order = {"Playing": 0, "Paused": 1, "Stopped": 2}.get(player.status, 3)
    if player.status == "Stopped" and not player.title:
        order = 4
    return (order, 0 if player.title else 1)


def usable(found: list[Player]) -> list[Player]:
    return sorted((player for player in found if rank(player)[0] < 4), key=rank)


def current(found: list[Player]) -> Player | None:
    kept = usable(found)
    return kept[0] if kept else None


def text_limit() -> int:
    width = 1920
    try:
        monitors = json.loads(run(["hyprctl", "monitors", "-j"]))
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
        monitors = []
    focused = next((mon for mon in monitors if mon.get("focused")), None)
    mon = focused or (monitors[0] if monitors else None)
    if mon and mon.get("width"):
        width = int(mon["width"])
    return max(12, int((width * 0.25 - PAD_PX) // CELL_PX))


def shorten(text: str, limit: int) -> str:
    if len(text) <= limit:
        return text
    if limit <= 1:
        return "…"
    return text[: limit - 1] + "…"


def pretty(name: str) -> str:
    base = name.split(".", 1)[0]
    return {
        "chromium": "Chrome",
        "chrome": "Chrome",
        "spotify": "Spotify",
        "vlc": "VLC",
        "firefox": "Firefox",
        "mpv": "mpv",
    }.get(base, base)


def show(player: Player) -> None:
    title = player.title or pretty(player.name)
    shown = shorten(f"{player.mark} {title}", text_limit())
    tip = title if not player.artist else f"{player.artist}\n{title}"
    print(
        json.dumps(
            {
                "text": pango(shown),
                "tooltip": pango(tip),
                "class": "playing" if player.status == "Playing" else "paused",
            },
            ensure_ascii=False,
        ),
        flush=True,
    )


def control(player: str, command: str) -> None:
    args = ["playerctl", "-p", player, command]
    if command == "shuffle":
        args.append("Toggle")
    subprocess.run(args, check=False)


def fuzzel(lines: list[str], prompt: str) -> str:
    width = max(len(prompt), min(72, max((len(line) for line in lines), default=20)))
    result = subprocess.run(
        [
            "fuzzel",
            "--dmenu",
            "--no-sort",
            "--prompt",
            prompt,
            "--width",
            str(width),
            "--lines",
            str(min(18, len(lines))),
        ],
        input="\n".join(lines) + "\n",
        text=True,
        capture_output=True,
        check=False,
    )
    return result.stdout.rstrip("\n")


def menu(found: list[Player]) -> None:
    kept = usable(found)
    rows: list[tuple[str, tuple[str, str]]] = []
    used: set[str] = set()
    many = len(kept) > 1
    for player in kept:
        title = player.title or pretty(player.name)
        who = f"{title}  —  {player.artist}" if player.artist else title
        verb = "Pause" if player.status == "Playing" else "Play"
        actions = (
            ("play-pause", verb),
            ("next", "Next"),
            ("previous", "Previous"),
            ("shuffle", "Shuffle"),
        )
        for command, caption in actions:
            label = f"{caption:<8}  {who}" if many else caption
            text = label
            n = 2
            while text in used:
                text = f"{label}  {n}"
                n += 1
            used.add(text)
            rows.append((text, (command, player.name)))
    if not rows:
        fuzzel(["Nothing playing"], "Playing  ")
        return
    chosen = fuzzel([text for text, _action in rows], "Playing  ")
    action = next((act for text, act in rows if text == chosen), None)
    if action is None:
        return
    command, name = action
    control(name, command)


def main() -> None:
    found = players()
    arg = sys.argv[1] if len(sys.argv) > 1 else ""
    if arg == "menu":
        menu(found)
        return
    player = current(found)
    if arg == "toggle":
        if player is not None:
            control(player.name, "play-pause")
        return
    if player is None:
        print(json.dumps({"text": "", "tooltip": ""}), flush=True)
        return
    show(player)


if __name__ == "__main__":
    main()
