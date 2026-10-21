#!/usr/bin/env bash
# Focus a matching window, or run the command.
# --match class is the default. title and both check the window title too.
# --skip-title ignores a window whose title contains that text. Repeatable.
# --toggle closes the match when it is already focused.
# usage: launch-app.sh [--match class|title|both] [--skip-title TEXT]... [--toggle] <pattern> <command> [args...]
set -euo pipefail

match="class"
toggle=0
skip_titles=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --match)
      match="${2:-}"
      shift 2
      ;;
    --skip-title)
      skip_titles+=("${2:-}")
      shift 2
      ;;
    --toggle)
      toggle=1
      shift
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "unknown option: $1" >&2
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

if [[ "$match" != "class" && "$match" != "title" && "$match" != "both" ]]; then
  echo "--match must be class, title, or both" >&2
  exit 2
fi

if (($# < 2)); then
  echo "Usage: $0 [--match class|title|both] [--skip-title TEXT]... [--toggle] <pattern> <command> [args...]" >&2
  exit 1
fi

pattern="$1"
shift

export LAUNCH_MATCH="$match"
export LAUNCH_TOGGLE="$toggle"
export LAUNCH_PATTERN="$pattern"
LAUNCH_SKIP=""
if ((${#skip_titles[@]})); then
  printf -v LAUNCH_SKIP '%s\n' "${skip_titles[@]}"
fi
export LAUNCH_SKIP

set +e
action="$(python3 - <<'PY'
import json, os, re, subprocess, sys

match = os.environ["LAUNCH_MATCH"]
toggle = os.environ["LAUNCH_TOGGLE"] == "1"
pattern = os.environ["LAUNCH_PATTERN"]
skips = [s.lower() for s in os.environ.get("LAUNCH_SKIP", "").split("\n") if s]

try:
    rx = re.compile(pattern, re.I)
except re.error as e:
    print(f"invalid pattern {pattern!r}: {e}", file=sys.stderr)
    sys.exit(2)

try:
    windows = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
    sys.exit(1)

matches = []
for w in windows:
    app = w.get("class") or ""
    title = w.get("title") or ""
    folded = title.lower()
    if any(s in folded for s in skips):
        continue
    hit = rx.search(title) if match == "title" else rx.search(app)
    if match == "both":
        hit = rx.search(app) or rx.search(title)
    if hit:
        matches.append(w)
if not matches:
    sys.exit(1)

matches.sort(key=lambda w: w.get("focusHistoryID") if isinstance(w.get("focusHistoryID"), int) else 10**9)
w = matches[0]
if toggle and w.get("focusHistoryID") == 0:
    print("close")
else:
    print("focus", w.get("address") or "")
PY
)"
status=$?
set -e

if [[ $status -eq 2 ]]; then
  exit 2
fi

read -r verb target <<<"${action:-}"
case "${verb:-}" in
  focus)
    if [[ -n ${target:-} ]]; then
      exec hyprctl dispatch "hl.dsp.focus({ window = \"address:${target}\" })"
    fi
    ;;
  close)
    exec hyprctl dispatch 'hl.dsp.window.close()'
    ;;
esac

exec "$@"
