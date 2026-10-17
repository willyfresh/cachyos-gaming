#!/usr/bin/env python3
"""Notification count for Waybar. Hidden when mako has nothing.

The count is notifications still on screen plus the history. A click
opens the same Fuzzel list as Super+N. Picking a line invokes its
action when it is still on screen, or opens a link in the text. A
screenshot line opens that file in yazi. Clear notifications
dismisses what is up and restarts mako, which is the only way this
version drops its history.
"""

from __future__ import annotations

import json
import re
import subprocess
import time
from pathlib import Path

ICON = "\uf0f3"  # fa-bell
CLEAR = "Clear notifications"
URL = re.compile(r"https?://[^\s<>\"]+")


def notes_from(kind: str) -> list[dict]:
    proc = subprocess.run(
        ["makoctl", kind, "-j"],
        text=True,
        capture_output=True,
        check=False,
    )
    if proc.returncode != 0 or not proc.stdout.strip():
        return []
    try:
        data = json.loads(proc.stdout)
    except json.JSONDecodeError:
        return []
    return data if isinstance(data, list) else []


def notes() -> list[dict]:
    current = notes_from("list")
    for note in current:
        note["_live"] = True
    seen = {note.get("id") for note in current}
    history = [note for note in notes_from("history") if note.get("id") not in seen]
    for note in history:
        note["_live"] = False
    return current + history


def actions_of(note: dict) -> list[tuple[str, str]]:
    raw = note.get("actions") or {}
    if isinstance(raw, dict):
        return [(str(key), str(label) or str(key)) for key, label in raw.items()]
    if isinstance(raw, list) and len(raw) % 2 == 0 and all(isinstance(item, str) for item in raw):
        return [(raw[index], raw[index + 1] or raw[index]) for index in range(0, len(raw), 2)]
    return []


def screenshot_file(note: dict) -> str | None:
    """Path from a screenshot notification, when the body names one."""
    if str(note.get("app_name") or "") != "Screenshot":
        return None
    found = None
    for line in str(note.get("body") or "").splitlines():
        path = line.strip()
        if path.startswith("/") and path.endswith(".png"):
            found = path
    return found


def open_screenshot(path: str) -> None:
    script = Path(__file__).resolve().parent / "hypr-screenshot.sh"
    subprocess.Popen(
        [str(script), "open", path],
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def first_url(note: dict) -> str | None:
    text = f"{note.get('summary') or ''} {note.get('body') or ''}"
    match = URL.search(text)
    if match is None:
        return None
    return match.group(0).rstrip(".,);]")


def note_line(note: dict) -> str:
    summary = str(note.get("summary") or "").strip()
    body = str(note.get("body") or "").replace("\n", " ").strip()
    app = str(note.get("app_name") or "").strip()
    title = summary or app or "Notification"
    if body and body != title:
        return f"{title}  {body}"
    return title


def status() -> None:
    found = notes()
    if not found:
        print(json.dumps({"text": "", "tooltip": "No notifications"}), flush=True)
        return
    print(
        json.dumps(
            {
                "text": f"{len(found)} {ICON}",
                "tooltip": "\n".join(note_line(note) for note in found),
            },
            ensure_ascii=False,
        ),
        flush=True,
    )


def fuzzel(lines: list[str], prompt: str) -> str:
    width = max(len(prompt), min(72, max(len(line) for line in lines)))
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


def menu_rows(found: list[dict]) -> list[tuple[str, dict | None]]:
    rows: list[tuple[str, dict | None]] = [(CLEAR, None)]
    used = {CLEAR}
    for note in found:
        text = note_line(note)
        if text in used:
            text = f"{text}  {note.get('app_name') or note.get('id')}"
        used.add(text)
        rows.append((text, note))
    return rows


def invoke(note: dict, action: str) -> None:
    subprocess.run(
        ["makoctl", "invoke", "-n", str(note["id"]), action],
        check=False,
    )
    subprocess.run(
        ["makoctl", "dismiss", "-n", str(note["id"])],
        check=False,
    )


def pick_action(note: dict) -> str | None:
    acts = actions_of(note)
    if not note.get("_live") or not acts:
        return None
    if len(acts) == 1:
        return acts[0][0]
    labels = []
    for key, label in acts:
        shown = label if label not in labels else f"{label}  {key}"
        labels.append(shown)
    chosen = fuzzel(labels, "Action  ")
    for shown, (key, _label) in zip(labels, acts):
        if shown == chosen:
            return key
    return None


def clear_notifications() -> None:
    # History lives only in the mako process. Dismiss cannot empty it.
    subprocess.run(["pkill", "-x", "mako"], check=False)
    for _ in range(20):
        if subprocess.run(["pgrep", "-x", "mako"], check=False).returncode != 0:
            break
        time.sleep(0.1)
    subprocess.Popen(
        ["mako"],
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def open_menu() -> None:
    found = notes()
    if not found:
        fuzzel(["No notifications"], "Notifications  ")
        return
    rows = menu_rows(found)
    chosen = fuzzel([text for text, _note in rows], "Notifications  ")
    match = next((note for text, note in rows if text == chosen), None)
    if chosen == CLEAR:
        clear_notifications()
        return
    if match is None:
        return
    shot = screenshot_file(match)
    if shot is not None:
        open_screenshot(shot)
        if match.get("_live"):
            subprocess.run(["makoctl", "dismiss", "-n", str(match["id"])], check=False)
        return
    action = pick_action(match)
    if action is not None:
        invoke(match, action)
        return
    url = first_url(match)
    if url is None:
        return
    subprocess.run(["xdg-open", url], check=False)
    if match.get("_live"):
        subprocess.run(["makoctl", "dismiss", "-n", str(match["id"])], check=False)


def main() -> None:
    import sys

    if len(sys.argv) > 1 and sys.argv[1] == "open":
        open_menu()
    else:
        status()


if __name__ == "__main__":
    main()
