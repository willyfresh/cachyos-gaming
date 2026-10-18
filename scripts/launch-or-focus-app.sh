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

windows = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
matches = [w for w in windows if rx.search(w.get("class") or "")]
if not matches:
    sys.exit(1)

matches.sort(key=lambda w: w.get("focusHistoryID") if isinstance(w.get("focusHistoryID"), int) else 10**9)
print(matches[0]["address"])
PY
)"

if [[ -n ${id:-} ]]; then
  exec hyprctl dispatch "hl.dsp.focus({ window = \"address:${id}\" })"
fi

exec "$@"
