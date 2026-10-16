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

windows = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
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

exec "$ROOT/launch-webapp.sh" "$@"
