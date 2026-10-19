#!/usr/bin/env bash
# Ctrl+Alt+Delete. A short session list.
# Escape cancels. Lock is first, so Enter does not leave the session.
set -euo pipefail

choice="$(
    printf '%s\n' "Lock" "Quit Hyprland" "Reboot" "Shut down" |
        fuzzel --dmenu --prompt "Session  " --width 20 --lines 4
)" || exit 0

case $choice in
    Lock)
        pidof hyprlock >/dev/null 2>&1 || exec hyprlock
        ;;
    "Quit Hyprland")
        if command -v hyprshutdown >/dev/null 2>&1; then
            exec hyprshutdown
        fi
        exec hyprctl dispatch 'hl.dsp.exit()'
        ;;
    Reboot)
        exec systemctl reboot
        ;;
    "Shut down")
        exec systemctl poweroff
        ;;
esac
