#!/usr/bin/env bash
# Print grabs a region (the Keychron crop key sends Print).
# Alt+Print grabs the focused window. Super+Print grabs both screens.
# Each shot is copied and saved under ~/Pictures/Screenshots.
# Escape, or a click without a drag, cancels the region.
# Clicking the notification opens the file in yazi. Super+N does too.
set -euo pipefail

# Open one saved shot in yazi. Used by the notification click and by
# the Fuzzel notification list.
if [[ "${1:-}" == "open" ]]; then
  shot="${2:-}"
  if [[ ! -f "$shot" ]]; then
    notify-send -a Screenshot "Screenshot" "Missing ${shot}"
    exit 1
  fi
  setsid -f kitty --class yazi-shot --title yazi -e yazi "$shot" >/dev/null 2>&1
  exit 0
fi

mode="${1:-region}"

exec 9>/tmp/hypr-screenshot.lock
if ! flock -n 9; then
  exit 0
fi

# Alt+Print can arrive as both Alt+Print and Sys_Req. Drop the second
# one when it starts just after the first shot finished.
stamp_file=/tmp/hypr-screenshot.last
now_ms=$(( $(date +%s%N) / 1000000 ))
if [[ -f "$stamp_file" ]]; then
  prev_ms="$(<"$stamp_file")"
  if [[ "$prev_ms" =~ ^[0-9]+$ ]] && (( now_ms - prev_ms < 500 )); then
    exit 0
  fi
fi
printf '%s\n' "$now_ms" > "$stamp_file"

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    notify-send -a Screenshot "Screenshot" "$1 is not installed"
    exit 1
  fi
}

need grim
need wl-copy

dir="${HOME}/Pictures/Screenshots"
mkdir -p "$dir"
stamp="$(date +%Y-%m-%d_%H-%M-%S)"
file="${dir}/${stamp}.png"
n=2
while [[ -e "$file" ]]; do
  file="${dir}/${stamp}-${n}.png"
  n=$((n + 1))
done

save() {
  local geom="${1:-}"
  if [[ -n "$geom" ]]; then
    grim -g "$geom" "$file"
  else
    grim "$file"
  fi
  wl-copy --type image/png < "$file"
}

finish() {
  local label="$1"
  local shot="$file"
  local self body
  self="$(readlink -f "$0")"
  body="${label}"$'\n'"${shot}"
  # Detach so the shot can finish while notify-send waits for the click.
  # Close the lock fd so the next shot is not stuck behind this notice.
  setsid -f bash -c '
    exec 9>&-
    action="$(notify-send -a Screenshot -i "$1" -t 15000 -A "default=Open" \
      "Screenshot" "$2" || true)"
    [[ "$action" == "default" ]] && "$3" open "$1"
  ' _ "$shot" "$body" "$self" >/dev/null 2>&1
}

case "$mode" in
  region)
    need slurp
    geom="$(slurp -b 0a0d0b80 -c 5cff6bff -w 2 || true)"
    if [[ -z "${geom}" ]]; then
      exit 0
    fi
    save "$geom"
    finish "Region"
    ;;
  window)
    geom="$(hyprctl activewindow -j | python3 -c '
import json, sys
raw = sys.stdin.read().strip()
try:
    w = json.loads(raw)
except json.JSONDecodeError:
    sys.exit(2)
if not isinstance(w, dict) or "at" not in w or "size" not in w:
    sys.exit(2)
x, y = w["at"]
width, height = w["size"]
if int(width) < 1 or int(height) < 1:
    sys.exit(2)
print(f"{int(x)},{int(y)} {int(width)}x{int(height)}")
')" || true
    if [[ -z "${geom}" ]]; then
      notify-send -a Screenshot "Screenshot" "No window"
      exit 0
    fi
    save "$geom"
    finish "Window"
    ;;
  screen)
    save
    finish "Both screens"
    ;;
  *)
    echo "usage: $0 [region|window|screen]" >&2
    exit 1
    ;;
esac
