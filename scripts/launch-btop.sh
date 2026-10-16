#!/usr/bin/env bash
# Super+Ctrl+T: tiled btop. Focus it if it is already open, close it if
# it is already focused, otherwise spawn kitty.
set -euo pipefail

id=""
focused=""
eval "$(python3 - <<'PY' || true
import json, subprocess, sys

windows = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
matches = [w for w in windows if (w.get("class") or "") in {"btop", "btop-key"}]
if not matches:
    sys.exit(1)

matches.sort(key=lambda w: w.get("focusHistoryID") if isinstance(w.get("focusHistoryID"), int) else 10**9)
w = matches[0]
print(f"id={w['address']}")
print(f"focused={'1' if w.get('focusHistoryID') == 0 else '0'}")
PY
)"

if [[ -n ${id:-} ]]; then
  if [[ ${focused:-0} == 1 ]]; then
    exec hyprctl dispatch 'hl.dsp.window.close()'
  fi
  exec hyprctl dispatch "hl.dsp.focus({ window = \"address:${id}\" })"
fi

exec setsid kitty --class btop-key --title btop -e btop
