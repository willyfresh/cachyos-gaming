#!/usr/bin/env bash
# Super+Ctrl+T: floating btop. Focus if it exists, close if it is already
# focused, otherwise spawn Alacritty with app-id "btop".
set -euo pipefail

id=""
focused=""
eval "$(python3 - <<'PY' || true
import json, subprocess, sys

windows = json.loads(subprocess.check_output(["niri", "msg", "--json", "windows"], text=True))
matches = []
for w in windows:
    app = w.get("app_id") or ""
    if app == "btop":
        matches.append(w)
if not matches:
    sys.exit(1)

def recency(w):
    ts = w.get("focus_timestamp") or {}
    return (ts.get("secs") or 0, ts.get("nanos") or 0)

matches.sort(key=lambda w: (not w.get("is_focused"), -recency(w)[0], -recency(w)[1]))
w = matches[0]
print(f"id={w['id']}")
print(f"focused={'1' if w.get('is_focused') else '0'}")
PY
)"

if [[ -n ${id:-} ]]; then
  if [[ ${focused:-0} == 1 ]]; then
    exec niri msg action close-window --id "$id"
  fi
  exec niri msg action focus-window --id "$id"
fi

exec setsid alacritty --class btop --title btop -e btop
