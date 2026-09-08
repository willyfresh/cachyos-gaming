#!/usr/bin/env bash
# Super+L / idle lock: start the screensaver first so the lock snapshot
# captures it, then engage Noctalia session lock.
set -euo pipefail

if command -v niri-screensaver-ctl >/dev/null 2>&1; then
  if ! niri-screensaver-ctl is-running; then
    niri-screensaver-ctl launch
    sleep 0.45
  fi
fi

exec noctalia msg session lock
