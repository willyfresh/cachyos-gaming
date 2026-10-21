#!/usr/bin/env bash
# Super+period. Pick an emoji and type it into the focused window.
# Exact match, then sort, so a loose hit does not sit on the first row.
# An empty search stays in list order.
set -euo pipefail

here=$(dirname "$(readlink -f "$0")")
list=$here/emoji-list.txt
[[ -f $list ]] || exit 1

font='MesloLGS Nerd Font Mono:size=14,Noto Color Emoji'
choice=$(grep -v '^[[:space:]]*#' "$list" | fuzzel --dmenu --match-mode=exact --font "$font" --width 56 --lines 16 --minimal-lines --prompt 'Emoji  ') || exit 0
[[ -n ${choice} ]] || exit 0
emoji=${choice%% *}
[[ -n $emoji ]] || exit 0

printf '%s' "$emoji" | wl-copy || true
sleep 0.05

if [[ -n ${WTYPE:-} ]]; then
  wtype_bin=$WTYPE
elif wtype_bin=$(command -v wtype 2>/dev/null) && [[ -x $wtype_bin ]]; then
  :
elif [[ -x $HOME/.local/bin/wtype ]]; then
  wtype_bin=$HOME/.local/bin/wtype
else
  exit 0
fi
"$wtype_bin" "$emoji"
