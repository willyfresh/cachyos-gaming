#!/usr/bin/env bash
# Focus Steam. Notification toasts use the same app-id and are not a window.
set -euo pipefail

id="$(python3 - <<'PY' || true
import json, subprocess, sys

windows = json.loads(subprocess.check_output(["niri", "msg", "--json", "windows"], text=True))
matches = []
for w in windows:
    app = (w.get("app_id") or "").lower()
    title = (w.get("title") or "").lower()
    if app != "steam" and not title.startswith("steam"):
        continue
    if "notificationtoast" in title:
        continue
    matches.append(w)
if not matches:
    sys.exit(1)

def recency(w):
    ts = w.get("focus_timestamp") or {}
    return (ts.get("secs") or 0, ts.get("nanos") or 0)

matches.sort(key=lambda w: (not w.get("is_focused"), -recency(w)[0], -recency(w)[1]))
print(matches[0]["id"])
PY
)"

if [[ -n ${id:-} ]]; then
  exec niri msg action focus-window --id "$id"
fi

exec setsid steam
