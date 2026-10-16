#!/usr/bin/env bash
# Focus Steam. Notification toasts use the same app-id and are not a window.
set -euo pipefail

id="$(python3 - <<'PY' || true
import json, subprocess, sys

windows = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
matches = []
for w in windows:
    app = (w.get("class") or "").lower()
    title = (w.get("title") or "").lower()
    if app != "steam" and not title.startswith("steam"):
        continue
    if "notificationtoast" in title:
        continue
    matches.append(w)
if not matches:
    sys.exit(1)

matches.sort(key=lambda w: w.get("focusHistoryID") if isinstance(w.get("focusHistoryID"), int) else 10**9)
print(matches[0]["address"])
PY
)"

if [[ -n ${id:-} ]]; then
  exec hyprctl dispatch "hl.dsp.focus({ window = \"address:${id}\" })"
fi

exec setsid steam
