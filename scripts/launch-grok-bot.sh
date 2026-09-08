#!/usr/bin/env bash
# Super+Shift+Alt+A: focus Grok Bot, or launch it.
set -euo pipefail

id="$(python3 - <<'PY' || true
import json, re, subprocess, sys

windows = json.loads(subprocess.check_output(["niri", "msg", "--json", "windows"], text=True))
rx = re.compile(r"grok[- ]?bot", re.I)
matches = []
for w in windows:
    app = w.get("app_id") or ""
    title = w.get("title") or ""
    if rx.search(app) or rx.search(title):
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

if ! command -v grok-bot >/dev/null 2>&1; then
  echo "grok-bot is not installed. Run: ./scripts/pkg-add.sh grok-bot-bin" >&2
  exit 1
fi

exec setsid grok-bot
