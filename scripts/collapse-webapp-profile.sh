#!/usr/bin/env bash
# Make the webapp Chrome user-data-dir a single signed-in Default profile.
# Links out of --app windows open in that dir's Default; an empty Default
# is the logged-out Chrome. Stop webapp Chrome first.
set -euo pipefail

dir="${BORG_CHROME_WEBAPP_DIR:-$HOME/.local/share/borg/chrome-webapps}"
named="${1:-}"
if [[ $named == --quit ]]; then
  pkill -f "user-data-dir=${dir}" || true
  for _ in {1..50}; do
    pgrep -f "user-data-dir=${dir}" >/dev/null || break
    sleep 0.1
  done
  shift
  named="${1:-}"
fi

if pgrep -f "user-data-dir=${dir}" >/dev/null; then
  echo "webapp Chrome is still running; close it or pass --quit" >&2
  exit 1
fi

src=""
if [[ -n $named && -d $dir/$named ]]; then
  src="$named"
elif [[ -d $dir/Delorean ]]; then
  src="Delorean"
fi

if [[ -z $src ]]; then
  echo "No named profile in $dir to collapse (Default is already the session)" >&2
  exit 0
fi

if [[ -d $dir/Default ]]; then
  bak="$dir/Default.unsigned.$(date +%s)"
  mv "$dir/Default" "$bak"
  echo "parked empty Default -> $bak"
fi

mv "$dir/$src" "$dir/Default"
echo "$src -> Default"

python3 - "$dir" "$src" <<'PY'
import json, sys
from pathlib import Path

root = Path(sys.argv[1])
old = sys.argv[2]
state_path = root / "Local State"
if not state_path.exists():
    raise SystemExit(0)
state = json.loads(state_path.read_text())
profile = state.setdefault("profile", {})
cache = profile.setdefault("info_cache", {})
if old in cache:
    cache["Default"] = cache.pop(old)
    cache["Default"]["name"] = cache["Default"].get("name") or "Person 1"
profile["last_used"] = "Default"
profile["last_active_profiles"] = ["Default"]
state_path.write_text(json.dumps(state))
print("Local State: last_used=Default")
PY
