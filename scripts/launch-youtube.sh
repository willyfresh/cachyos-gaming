#!/usr/bin/env bash
# Super+Shift+Y: YouTube Music and YouTube. Music comes first.
# Focused music goes to YouTube. Focused YouTube comes back to music.
# From anywhere else: focus music, or YouTube if only that is open, or launch music.
set -euo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

read -r action target <<<"$(python3 - <<'PY' || true
import json, subprocess, sys

windows = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))

def rank(w):
    hid = w.get("focusHistoryID")
    return hid if isinstance(hid, int) else 10**9

def collect(pred):
    out = [w for w in windows if pred((w.get("class") or "").lower())]
    out.sort(key=rank)
    return out

def is_music(app):
    return "chrome-music.youtube.com" in app

def is_youtube(app):
    if is_music(app):
        return False
    return "chrome-www.youtube.com" in app or app.startswith("chrome-youtube.com")

music = collect(is_music)
video = collect(is_youtube)
music_focus = any(w.get("focusHistoryID") == 0 for w in music)
video_focus = any(w.get("focusHistoryID") == 0 for w in video)

if music_focus:
    if video:
        print("focus", video[0]["address"])
    else:
        print("launch youtube")
elif video_focus:
    if music:
        print("focus", music[0]["address"])
    else:
        print("launch music")
elif music:
    print("focus", music[0]["address"])
elif video:
    print("focus", video[0]["address"])
else:
    print("launch music")
PY
)"

case "${action:-}" in
  focus)
    exec hyprctl dispatch "hl.dsp.focus({ window = \"address:${target}\" })"
    ;;
  launch)
    if [[ "$target" == "youtube" ]]; then
      exec "$ROOT/launch-webapp.sh" "https://www.youtube.com/"
    fi
    exec "$ROOT/launch-webapp.sh" "https://music.youtube.com/"
    ;;
  *)
    exec "$ROOT/launch-webapp.sh" "https://music.youtube.com/"
    ;;
esac
