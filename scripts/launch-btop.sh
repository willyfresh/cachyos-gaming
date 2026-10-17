#!/usr/bin/env bash
# Super+Ctrl+T and Super+Shift+T: tiled btop. Super+Shift+Ctrl+T: nvtop.
# Focus it if it is already open, close it if it is already focused,
# otherwise spawn kitty. The menu's *-tile class is left alone.
# usage: launch-btop.sh [btop|nvtop]
set -euo pipefail

app="${1:-btop}"
case "$app" in
  btop|nvtop) ;;
  *)
    echo "usage: $0 [btop|nvtop]" >&2
    exit 1
    ;;
esac

id=""
focused=""
eval "$(app="$app" python3 - <<'PY' || true
import json, os, subprocess, sys

app = os.environ["app"]
wanted = {app, app + "-key"}
windows = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
matches = [w for w in windows if (w.get("class") or "") in wanted]
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

exec setsid kitty --class "${app}-key" --title "$app" -e "$app"
