#!/usr/bin/env bash
# Focus a matching window, or run the command.
# --match class is the default. title and both check the window title too.
# --skip-title ignores a window whose title contains that text. Repeatable.
# --toggle closes the match when it is already focused.
# --show-hide closes every match. With no match, it runs the command.
# usage: launch-app.sh [--match class|title|both] [--skip-title TEXT]... [--toggle|--show-hide] <pattern> <command> [args...]
set -euo pipefail

match="class"
toggle=0
show_hide=0
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
    --show-hide)
      show_hide=1
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
  echo "Usage: $0 [--match class|title|both] [--skip-title TEXT]... [--toggle|--show-hide] <pattern> <command> [args...]" >&2
  exit 1
fi

pattern="$1"
shift

export LAUNCH_MATCH="$match"
export LAUNCH_TOGGLE="$toggle"
export LAUNCH_SHOW_HIDE="$show_hide"
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
show_hide = os.environ.get("LAUNCH_SHOW_HIDE") == "1"
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
if show_hide:
    addrs = [m.get("address") or "" for m in matches if m.get("address")]
    if not addrs:
        sys.exit(1)
    print("close", *addrs)
elif toggle and w.get("focusHistoryID") == 0:
    print("close", w.get("address") or "")
else:
    print("focus", w.get("address") or "")
PY
)"
status=$?
set -e

if [[ $status -eq 2 ]]; then
  exit 2
fi

read -r verb targets <<<"${action:-}"
case "${verb:-}" in
  focus)
    if [[ -n ${targets:-} ]]; then
      exec hyprctl dispatch "hl.dsp.focus({ window = \"address:${targets}\" })"
    fi
    ;;
  close)
    if [[ -z ${targets:-} ]]; then
      exec hyprctl dispatch 'hl.dsp.window.close()'
    fi
    for target in $targets; do
      hyprctl dispatch "hl.dsp.window.close({ window = \"address:${target}\" })" >/dev/null
    done
    exit 0
    ;;
esac

exec "$@"
