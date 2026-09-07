#!/usr/bin/env bash
# Focus an existing title-less webapp, or launch it into the persistent profile.
set -euo pipefail

if (($# < 2)); then
  echo "Usage: $0 <window-pattern> <url> [chrome-flags...]" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
WINDOW_PATTERN="$1"
shift

id="$(python3 - "$WINDOW_PATTERN" <<'PY' || true
import json, re, subprocess, sys

pat = sys.argv[1]
try:
    rx = re.compile(pat, re.I)
except re.error as e:
    print(f"invalid window pattern {pat!r}: {e}", file=sys.stderr)
    sys.exit(2)

raw = subprocess.check_output(["niri", "msg", "--json", "windows"], text=True)
windows = json.loads(raw)
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

exec "$ROOT/launch-webapp.sh" "$@"
