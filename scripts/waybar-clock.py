#!/usr/bin/env python3
"""Clock chip: the time, a stopwatch, and a few timers.

Waybar runs this with no arguments. Left click runs it with "menu".
Right click runs it with "next" and cycles the chip through the clock,
each running timer, and the stopwatch.

The clock face is HH:MM. One outline timer icon sits in front of that
time while a timer or the stopwatch is active. The timer and stopwatch
faces use the filled timer icon, one space, then -m:ss or +m:ss. Times
use CLOCK_BOOTTIME, so a suspend still counts.
"""

from __future__ import annotations

import fcntl
import json
import math
import subprocess
import time
from contextlib import contextmanager
from pathlib import Path

STATE = Path.home() / ".cache" / "novalis" / "waybar-clock.json"
SIGNAL = 4
PRESETS = (5, 10, 25, 60)
MINUTE_CHOICES = range(1, 181)
ALARM = "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
# Meslo nerd icons, drawn at 16pt like the lock glyphs.
BIG = "<span size='16384'>{}</span>"
ICON_OUTLINE = "\U000f051b"  # md-timer_outline, clock face
ICON_FILLED = "\U000f13ab"  # md-timer, timer and stopwatch faces


def now() -> float:
    return time.clock_gettime(time.CLOCK_BOOTTIME)


def empty_state() -> dict:
    return {
        "stopwatch": {"running": False, "elapsed": 0.0, "since": None},
        "timers": [],
        "face": "clock",
    }


def normalize(state: dict) -> dict:
    if not isinstance(state, dict):
        return empty_state()
    watch = state.get("stopwatch")
    if not isinstance(watch, dict):
        watch = empty_state()["stopwatch"]
    timers = state.get("timers")
    if not isinstance(timers, list):
        timers = []
    face = state.get("face")
    if not isinstance(face, str) or not face:
        face = "clock"
    return {"stopwatch": watch, "timers": timers, "face": face}


@contextmanager
def locked():
    STATE.parent.mkdir(parents=True, exist_ok=True)
    with STATE.open("a+") as handle:
        fcntl.flock(handle, fcntl.LOCK_EX)
        handle.seek(0)
        raw = handle.read()
        try:
            state = normalize(json.loads(raw) if raw.strip() else empty_state())
        except json.JSONDecodeError:
            state = empty_state()
        try:
            yield state
        finally:
            handle.seek(0)
            handle.truncate()
            json.dump(state, handle)
            handle.flush()


def fmt(whole: int) -> str:
    whole = max(0, whole)
    minutes, secs = divmod(whole, 60)
    return f"{minutes}:{secs:02d}"


def stopwatch_elapsed(watch: dict, moment: float) -> float:
    elapsed = float(watch.get("elapsed") or 0)
    since = watch.get("since")
    if watch.get("running") and since is not None:
        elapsed += max(0.0, moment - float(since))
    return elapsed


def expire(state: dict, moment: float) -> list[str]:
    due = []
    kept = []
    for timer in state["timers"]:
        if float(timer["end"]) <= moment:
            due.append(timer["label"])
        else:
            kept.append(timer)
    state["timers"] = kept
    return due


def alert(labels: list[str]) -> None:
    for label in labels:
        subprocess.Popen(
            ["notify-send", "-a", "Clock", "-t", "20000", label, "Timer done"],
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        subprocess.Popen(
            ["paplay", ALARM],
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def running_timers(state: dict, moment: float) -> list[dict]:
    timers = [timer for timer in state["timers"] if float(timer["end"]) > moment]
    return sorted(timers, key=lambda timer: float(timer["end"]))


def timer_order(state: dict, moment: float) -> list[int]:
    """Preset timers first, then any custom one, soonest end within each."""
    known = [minutes * 60 for minutes in PRESETS]
    by_end = {int(timer["seconds"]): float(timer["end"]) for timer in running_timers(state, moment)}
    ordered = [seconds for seconds in known if seconds in by_end]
    extras = sorted(
        (seconds for seconds in by_end if seconds not in known),
        key=lambda seconds: by_end[seconds],
    )
    return ordered + extras


def stopwatch_active(state: dict, moment: float) -> bool:
    watch = state["stopwatch"]
    return bool(watch.get("running")) or stopwatch_elapsed(watch, moment) >= 1


def faces(state: dict, moment: float) -> list[str]:
    shown = ["clock"]
    shown.extend(f"timer:{seconds}" for seconds in timer_order(state, moment))
    if stopwatch_active(state, moment):
        shown.append("stopwatch")
    return shown


def clamp_face(state: dict, moment: float) -> str:
    available = faces(state, moment)
    if state.get("face") not in available:
        state["face"] = "clock"
    return state["face"]


def cycle_face(state: dict, moment: float) -> None:
    available = faces(state, moment)
    face = state.get("face") if state.get("face") in available else "clock"
    state["face"] = available[(available.index(face) + 1) % len(available)]


def with_icon(glyph: str, number: str) -> str:
    return f"{BIG.format(glyph)} {number}"


def chip(state: dict, moment: float) -> dict:
    clock = time.strftime("%H:%M")
    face = clamp_face(state, moment)
    if face == "stopwatch":
        elapsed = int(stopwatch_elapsed(state["stopwatch"], moment))
        text = with_icon(ICON_FILLED, "+" + fmt(elapsed))
    elif face.startswith("timer:"):
        seconds = int(face.split(":", 1)[1])
        timer = next(
            timer for timer in state["timers"] if int(timer["seconds"]) == seconds
        )
        left = math.ceil(float(timer["end"]) - moment)
        text = with_icon(ICON_FILLED, "-" + fmt(left))
    elif running_timers(state, moment) or stopwatch_active(state, moment):
        text = with_icon(ICON_OUTLINE, clock)
    else:
        text = clock

    tips = [clock]
    for timer in running_timers(state, moment):
        left = fmt(math.ceil(float(timer["end"]) - moment))
        tips.append(f"{timer['label']}  -{left}")
    if stopwatch_active(state, moment):
        watch = state["stopwatch"]
        elapsed = fmt(int(stopwatch_elapsed(watch, moment)))
        line = f"Stopwatch  +{elapsed}"
        if not watch.get("running"):
            line += "  paused"
        tips.append(line)
    return {"text": text, "tooltip": "\n".join(tips)}


def label_for(seconds: int) -> str:
    return f"{seconds // 60} min"


def rows_for(state: dict, moment: float) -> list[tuple[str, tuple]]:
    """Menu lines and the command a click runs."""
    labels: list[tuple[str, str, tuple]] = []
    watch = state["stopwatch"]
    elapsed = stopwatch_elapsed(watch, moment)
    elapsed_text = "+" + fmt(int(elapsed)) if watch.get("running") or elapsed >= 1 else ""
    if watch.get("running"):
        labels.append(("Pause stopwatch", elapsed_text, ("pause", None)))
    else:
        labels.append(("Start stopwatch", elapsed_text, ("start-sw", None)))
    if watch.get("running") or elapsed >= 1:
        labels.append(("Reset stopwatch", "", ("reset", None)))

    known = [minutes * 60 for minutes in PRESETS]
    extras = sorted(
        int(timer["seconds"])
        for timer in state["timers"]
        if int(timer["seconds"]) not in known
    )
    by_seconds = {int(timer["seconds"]): timer for timer in state["timers"]}
    for seconds in known + extras:
        name = label_for(seconds)
        timer = by_seconds.get(seconds)
        left = ""
        if timer is not None and float(timer["end"]) > moment:
            left = "-" + fmt(math.ceil(float(timer["end"]) - moment))
        labels.append((name, left, ("start", seconds)))
        if left:
            labels.append((f"Cancel {name}", "", ("cancel", seconds)))
    labels.append(("Custom minutes", "", ("custom", None)))

    timed = [len(label) for label, extra, _command in labels if extra]
    column = max(timed, default=0)
    rows = []
    for label, extra, command in labels:
        if extra:
            gap = column - len(label) + 2
            text = f"{label}{' ' * gap}{extra}"
        else:
            text = label
        rows.append((text, command))
    return rows


def command_for(chosen: str, rows: list[tuple[str, tuple]]) -> tuple | None:
    for text, command in rows:
        if text == chosen:
            return command
    return None


def apply_command(state: dict, command: tuple, moment: float) -> None:
    kind, arg = command
    watch = state["stopwatch"]
    if kind == "start-sw" and not watch.get("running"):
        watch["since"] = moment
        watch["running"] = True
    elif kind == "pause" and watch.get("running"):
        watch["elapsed"] = stopwatch_elapsed(watch, moment)
        watch["since"] = None
        watch["running"] = False
    elif kind == "reset":
        watch["elapsed"] = 0.0
        watch["since"] = None
        watch["running"] = False
    elif kind == "start":
        seconds = int(arg)
        state["timers"] = [
            timer for timer in state["timers"] if int(timer["seconds"]) != seconds
        ]
        state["timers"].append(
            {
                "seconds": seconds,
                "label": label_for(seconds),
                "end": moment + seconds,
            }
        )
    elif kind == "cancel":
        seconds = int(arg)
        state["timers"] = [
            timer for timer in state["timers"] if int(timer["seconds"]) != seconds
        ]


def next_face() -> None:
    with locked() as state:
        cycle_face(state, now())
    refresh()


def refresh() -> None:
    subprocess.run(["pkill", f"-RTMIN+{SIGNAL}", "-x", "waybar"], check=False)


def fuzzel(lines: list[str], prompt: str, width: int, height: int) -> str:
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
            str(height),
        ],
        input="\n".join(lines) + "\n",
        text=True,
        capture_output=True,
        check=False,
    )
    return result.stdout.rstrip("\n")


def ask_minutes() -> int | None:
    lines = [str(minutes) for minutes in MINUTE_CHOICES]
    chosen = fuzzel(lines, "Minutes  ", 12, 10)
    if not chosen.isdigit():
        return None
    minutes = int(chosen)
    if minutes not in MINUTE_CHOICES:
        return None
    return minutes


def menu() -> None:
    while True:
        with locked() as state:
            moment = now()
            due = expire(state, moment)
            rows = rows_for(state, moment)
        alert(due)
        chosen = fuzzel(
            [text for text, _command in rows],
            "Clock  ",
            max(len(text) for text, _command in rows),
            len(rows),
        )
        command = command_for(chosen, rows)
        if command is None:
            return
        if command[0] == "custom":
            minutes = ask_minutes()
            if minutes is None:
                continue
            command = ("start", minutes * 60)
        with locked() as state:
            apply_command(state, command, now())
        refresh()
        return


def status() -> None:
    with locked() as state:
        moment = now()
        due = expire(state, moment)
        payload = chip(state, moment)
    alert(due)
    print(json.dumps(payload, ensure_ascii=False), flush=True)


def main() -> None:
    import sys

    arg = sys.argv[1] if len(sys.argv) > 1 else ""
    if arg == "menu":
        menu()
    elif arg == "next":
        next_face()
    else:
        status()


if __name__ == "__main__":
    main()
