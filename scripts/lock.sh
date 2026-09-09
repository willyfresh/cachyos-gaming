#!/usr/bin/env bash
# Super+L: session-lock only. Idle screensaver is separate (150s) and
# does not lock. niri cannot composite a live saver over the lock, so
# kill any running saver first for a normal wallpaper lock screen.
set -euo pipefail

if command -v niri-screensaver-ctl >/dev/null 2>&1; then
  niri-screensaver-ctl kill >/dev/null 2>&1 || true
fi

exec noctalia msg session lock
