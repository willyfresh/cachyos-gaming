#!/usr/bin/env bash
# Keychron square: cycle Steam and Heroic. Focus the other if one is
# focused; otherwise the more recently focused of the two, or launch Steam.
set -euo pipefail

read -r action target <<<"$(python3 - <<'PY' || true
import json, subprocess, sys

windows = json.loads(subprocess.check_output(["niri", "msg", "--json", "windows"], text=True))

def recency(w):
    ts = w.get("focus_timestamp") or {}
    return (ts.get("secs") or 0, ts.get("nanos") or 0)

def collect(pred):
    out = []
    for w in windows:
        app = (w.get("app_id") or "").lower()
        title = (w.get("title") or "").lower()
        if pred(app, title):
            out.append(w)
    out.sort(key=lambda w: -recency(w)[0] * 10**9 - recency(w)[1])
    return out

def is_steam(app, title):
    if "notificationtoast" in title:
        return False
    return app == "steam" or title.startswith("steam")

def is_heroic(app, title):
    return app == "heroic" or "heroic" in app

steam = collect(is_steam)
heroic = collect(is_heroic)
steam_focus = any(w.get("is_focused") for w in steam)
heroic_focus = any(w.get("is_focused") for w in heroic)

if steam_focus:
    if heroic:
        print("focus", heroic[0]["id"])
    else:
        print("launch heroic")
elif heroic_focus:
    if steam:
        print("focus", steam[0]["id"])
    else:
        print("launch steam")
elif steam or heroic:
    pick = (steam + heroic)
    pick.sort(key=lambda w: -recency(w)[0] * 10**9 - recency(w)[1])
    print("focus", pick[0]["id"])
else:
    print("launch steam")
PY
)"

case "${action:-}" in
  focus)
    exec niri msg action focus-window --id "$target"
    ;;
  launch)
    if [[ "$target" == "heroic" ]]; then
      exec setsid heroic
    fi
    exec setsid steam
    ;;
  *)
    exec setsid steam
    ;;
esac
