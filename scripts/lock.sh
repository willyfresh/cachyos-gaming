#!/usr/bin/env bash
# Super+L from niri. Hyprland binds hyprlock on its own.
set -euo pipefail

if [[ -z ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  printf 'lock: hyprlock needs Hyprland\n' >&2
  exit 1
fi
if pidof hyprlock >/dev/null 2>&1; then
  exit 0
fi
exec hyprlock
