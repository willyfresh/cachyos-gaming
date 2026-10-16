#!/usr/bin/env bash
# Super+Shift+Alt+A: focus Grok Bot, or launch it.
set -euo pipefail

id="$(python3 - <<'PY' || true
import json, re, subprocess, sys

windows = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
rx = re.compile(r"grok[- ]?bot", re.I)
matches = []
for w in windows:
    app = w.get("class") or ""
    title = w.get("title") or ""
    if rx.search(app) or rx.search(title):
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

if ! command -v grok-bot >/dev/null 2>&1; then
  echo "grok-bot is not installed. Run: ./scripts/pkg-add.sh grok-bot-bin" >&2
  exit 1
fi

exec setsid grok-bot
