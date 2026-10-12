#!/usr/bin/env bash
# Super+N and the Keychron circle. Mako has no panel, so the history
# opens in Fuzzel. Picking a line does not run it.
set -euo pipefail

list=$(makoctl history 2>/dev/null || true)
if [[ -z "${list//[[:space:]]/}" ]]; then
  list="No notifications"
fi
printf '%s\n' "$list" | fuzzel --dmenu --prompt "Notifications  " --width 72 --lines 18 >/dev/null || true
