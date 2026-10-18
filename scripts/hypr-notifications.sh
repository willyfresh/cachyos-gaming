#!/usr/bin/env bash
# Super+N and the Keychron circle. Mako has no panel, so the list
# opens in Fuzzel. A line runs its action, opens a screenshot in
# yazi, or opens its link. Clear notifications empties the list.
exec "$(dirname "$(readlink -f "$0")")/waybar-notifications.py" open
