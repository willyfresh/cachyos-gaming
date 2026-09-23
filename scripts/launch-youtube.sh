#!/usr/bin/env bash
# Super+Shift+Y: YouTube Music and YouTube. Music comes first.
# Focused music goes to YouTube. Focused YouTube comes back to music.
# From anywhere else: focus music, or YouTube if only that is open, or launch music.
set -euo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

read -r action target <<<"$(python3 - <<'PY' || true
import json, subprocess, sys

windows = json.loads(subprocess.check_output(["niri", "msg", "--json", "windows"], text=True))

def recency(w):
    ts = w.get("focus_timestamp") or {}
    return (ts.get("secs") or 0, ts.get("nanos") or 0)

def collect(pred):
    out = [w for w in windows if pred((w.get("app_id") or "").lower())]
    out.sort(key=lambda w: -recency(w)[0] * 10**9 - recency(w)[1])
    return out

def is_music(app):
    return "chrome-music.youtube.com" in app

def is_youtube(app):
    if is_music(app):
        return False
    return "chrome-www.youtube.com" in app or app.startswith("chrome-youtube.com")

music = collect(is_music)
video = collect(is_youtube)
music_focus = any(w.get("is_focused") for w in music)
video_focus = any(w.get("is_focused") for w in video)

if music_focus:
    if video:
        print("focus", video[0]["id"])
    else:
        print("launch youtube")
elif video_focus:
    if music:
        print("focus", music[0]["id"])
    else:
        print("launch music")
elif music:
    print("focus", music[0]["id"])
elif video:
    print("focus", video[0]["id"])
else:
    print("launch music")
PY
)"

case "${action:-}" in
  focus)
    exec niri msg action focus-window --id "$target"
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
