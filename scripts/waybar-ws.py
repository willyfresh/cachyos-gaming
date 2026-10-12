#!/usr/bin/env python3
"""Workspace chips for one Waybar screen.

Waybar 0.15 still clicks with `dispatch workspace N`. Hyprland 0.56
ignores that. A click here runs hl.dsp.focus instead.

The argument is the number on that screen, 1 through 10. DP-1 owns
ids 1–10 and HDMI-A-1 owns 11–20, same as hyprsplit. A chip is shown
when that workspace has a window, and when it is the one in use.
"""

from __future__ import annotations

import fcntl
import json
import os
import socket
import subprocess
import sys
import time
from pathlib import Path

PRIORITY = ("DP-1", "HDMI-A-1")
COUNT = 10
CACHE = Path.home() / ".cache" / "novalis" / "waybar-ws.json"
LOCK = Path.home() / ".cache" / "novalis" / "waybar-ws.lock"
LOG = Path.home() / ".cache" / "novalis" / "waybar-ws.log"

# socket2 lines worth redrawing. Window titles are not.
REFRESH = (
    "workspace",
    "openwindow",
    "closewindow",
    "movewindow",
    "focusedmon",
    "createworkspace",
    "destroyworkspace",
    "moveworkspace",
    "urgent",
    "configreloaded",
    "monitoradded",
    "monitorremoved",
)


def runtime_dir() -> Path:
    return Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))


def signature() -> str:
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
    if sig:
        return sig
    root = runtime_dir() / "hypr"
    found = [p.name for p in root.glob("*") if (p / ".socket2.sock").exists()]
    return found[0] if len(found) == 1 else ""


def hyprctl(*args: str) -> str:
    env = os.environ.copy()
    sig = signature()
    if sig:
        env["HYPRLAND_INSTANCE_SIGNATURE"] = sig
    out = subprocess.check_output(["hyprctl", *args], text=True, env=env)
    return out.strip()


def global_id(output: str, local: int) -> int:
    try:
        base = PRIORITY.index(output)
    except ValueError:
        base = len(PRIORITY)
    return base * COUNT + local


def output_at_cursor() -> str:
    raw = hyprctl("cursorpos").replace(" ", "")
    x_s, y_s = raw.split(",", 1)
    x, y = int(x_s), int(y_s)
    monitors = json.loads(hyprctl("monitors", "-j"))
    for monitor in monitors:
        left, top = monitor["x"], monitor["y"]
        right = left + monitor["width"]
        bottom = top + monitor["height"]
        if left <= x < right and top <= y < bottom:
            return monitor["name"]
    named = os.environ.get("WAYBAR_OUTPUT_NAME", "")
    if named:
        return named
    return monitors[0]["name"] if monitors else ""


def focus(local: int) -> None:
    output = output_at_cursor()
    if not output:
        return
    ws_id = global_id(output, local)
    subprocess.run(
        ["hyprctl", "dispatch", f"hl.dsp.focus({{ workspace = {ws_id} }})"],
        check=False,
        env={**os.environ, "HYPRLAND_INSTANCE_SIGNATURE": signature()},
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def snapshot() -> dict:
    workspaces = json.loads(hyprctl("workspaces", "-j"))
    monitors = json.loads(hyprctl("monitors", "-j"))
    state: dict[str, dict] = {}
    for monitor in monitors:
        state[monitor["name"]] = {
            "active": monitor["activeWorkspace"]["id"],
            "windows": {},
        }
    for workspace in workspaces:
        name = workspace.get("monitor") or ""
        slot = state.get(name)
        if slot is None:
            continue
        slot["windows"][str(workspace["id"])] = int(workspace.get("windows") or 0)
    return state


def write_cache(state: dict) -> None:
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    tmp = CACHE.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(state))
    tmp.replace(CACHE)


def want_refresh(line: str) -> bool:
    name = line.split(">>", 1)[0]
    return any(name == prefix or name.startswith(prefix + "v") for prefix in REFRESH)


def listen() -> None:
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    lock = LOCK.open("a+")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return
    try:
        write_cache(snapshot())
        sock_path = runtime_dir() / "hypr" / signature() / ".socket2.sock"
        while True:
            try:
                with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
                    sock.connect(str(sock_path))
                    with sock.makefile() as stream:
                        for line in stream:
                            if want_refresh(line):
                                write_cache(snapshot())
            except OSError:
                time.sleep(1)
                try:
                    write_cache(snapshot())
                except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
                    pass
    finally:
        fcntl.flock(lock, fcntl.LOCK_UN)
        lock.close()


def listener_running() -> bool:
    try:
        fd = os.open(LOCK, os.O_RDWR | os.O_CREAT, 0o644)
    except OSError:
        return False
    try:
        fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        os.close(fd)
        return True
    fcntl.flock(fd, fcntl.LOCK_UN)
    os.close(fd)
    return False


def ensure_listener() -> None:
    if listener_running():
        return
    LOG.parent.mkdir(parents=True, exist_ok=True)
    log = LOG.open("ab")
    subprocess.Popen(
        [sys.executable, str(Path(__file__).resolve()), "listen"],
        start_new_session=True,
        stdin=subprocess.DEVNULL,
        stdout=log,
        stderr=subprocess.STDOUT,
    )


def chip(local: int, state: dict) -> str:
    output = os.environ.get("WAYBAR_OUTPUT_NAME", "")
    info = state.get(output) or {}
    ws_id = global_id(output, local) if output else 0
    windows = (info.get("windows") or {}).get(str(ws_id), 0)
    active = info.get("active")
    if not output or (windows <= 0 and active != ws_id):
        payload = {"text": "", "class": "empty", "tooltip": ""}
    else:
        payload = {
            "text": str(local),
            "class": "active" if active == ws_id else "occupied",
            "tooltip": f"Workspace {local}",
        }
    return json.dumps(payload)


def follow(local: int) -> None:
    ensure_listener()
    deadline = time.monotonic() + 1
    while not CACHE.exists() and time.monotonic() < deadline:
        time.sleep(0.05)
        ensure_listener()
    last = None
    seen = None
    while True:
        try:
            mtime = CACHE.stat().st_mtime_ns
        except OSError:
            mtime = None
        if mtime != seen or last is None:
            try:
                state = json.loads(CACHE.read_text())
            except (OSError, json.JSONDecodeError):
                state = {}
            line = chip(local, state)
            if line != last:
                print(line, flush=True)
                last = line
            seen = mtime
        if mtime is None:
            ensure_listener()
        time.sleep(0.2)


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit("usage: waybar-ws.py <1-10> [focus] | listen")
    if sys.argv[1] == "listen":
        listen()
        return
    local = int(sys.argv[1])
    if not 1 <= local <= COUNT:
        raise SystemExit(f"workspace {local} is outside 1–{COUNT}")
    if len(sys.argv) > 2 and sys.argv[2] == "focus":
        focus(local)
        return
    follow(local)


if __name__ == "__main__":
    main()
