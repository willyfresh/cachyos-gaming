#!/usr/bin/env bash
# Focus a window whose app-id matches, or launch the command.
set -euo pipefail

if (($# < 2)); then
  echo "Usage: $0 <app-id-regex> <command> [args...]" >&2
  exit 1
fi

pattern="$1"
shift

id="$(python3 - "$pattern" <<'PY' || true
import json, re, subprocess, sys

pat = sys.argv[1]
try:
    rx = re.compile(pat, re.I)
except re.error as e:
    print(f"invalid app-id pattern {pat!r}: {e}", file=sys.stderr)
    sys.exit(2)

raw = subprocess.check_output(["niri", "msg", "--json", "windows"], text=True)
windows = json.loads(raw)
matches = [w for w in windows if rx.search(w.get("app_id") or "")]
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

exec "$@"
