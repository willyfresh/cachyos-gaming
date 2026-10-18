#!/usr/bin/env bash
# Keychron square: cycle Steam and Heroic. Focus the other if one is
# focused; otherwise the more recently focused of the two, or launch Steam.
set -euo pipefail

read -r action target <<<"$(python3 - <<'PY' || true
import json, subprocess, sys

windows = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))

def rank(w):
    hid = w.get("focusHistoryID")
    return hid if isinstance(hid, int) else 10**9

def collect(pred):
    out = []
    for w in windows:
        app = (w.get("class") or "").lower()
        title = (w.get("title") or "").lower()
        if pred(app, title):
            out.append(w)
    out.sort(key=rank)
    return out

def is_steam(app, title):
    if "notificationtoast" in title:
        return False
    return app == "steam" or title.startswith("steam")

def is_heroic(app, title):
    return app == "heroic" or "heroic" in app

steam = collect(is_steam)
heroic = collect(is_heroic)
steam_focus = any(w.get("focusHistoryID") == 0 for w in steam)
heroic_focus = any(w.get("focusHistoryID") == 0 for w in heroic)

if steam_focus:
    if heroic:
        print("focus", heroic[0]["address"])
    else:
        print("launch heroic")
elif heroic_focus:
    if steam:
        print("focus", steam[0]["address"])
    else:
        print("launch steam")
elif steam or heroic:
    pick = (steam + heroic)
    pick.sort(key=rank)
    print("focus", pick[0]["address"])
else:
    print("launch steam")
PY
)"

case "${action:-}" in
  focus)
    exec hyprctl dispatch "hl.dsp.focus({ window = \"address:${target}\" })"
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
