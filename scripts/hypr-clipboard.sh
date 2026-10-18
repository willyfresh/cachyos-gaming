#!/usr/bin/env bash
# Super+V. Pick a cliphist entry in Fuzzel and copy it back.
# The list ends with wipe, delete, and delete-query.
set -euo pipefail

store=$(dirname "$(readlink -f "$0")")/hypr-clipboard-store.sh

wipe_row='wipe            Clear the history'
delete_row='delete          Remove one entry'
query_row='delete-query    Remove entries containing text'

menu() {
  local prompt=$1
  local lines=${2:-18}
  local width=${3:-72}
  fuzzel --dmenu --prompt "$prompt" --width "$width" --lines "$lines" || true
}

clips() {
  cliphist list | "$store" --menu || true
}

pick=$(
  {
    clips
    printf '%s\n' "$wipe_row" "$delete_row" "$query_row"
  } | menu "Clipboard  "
)
[[ -z "$pick" ]] && exit 0

case "$pick" in
  "$wipe_row")
    # Cancel is the first row, so Enter does not wipe.
    confirm=$(printf '%s\n' cancel wipe | menu "Wipe history?  " 2 24)
    [[ "$confirm" == wipe ]] && cliphist wipe
    ;;
  "$delete_row")
    entries=$(clips)
    if [[ -z "$entries" ]]; then
      printf '%s\n' 'Nothing to delete' | menu "Delete  " 1 24 >/dev/null
      exit 0
    fi
    victim=$(printf '%s\n' "$entries" | menu "Delete  ")
    [[ -z "$victim" ]] && exit 0
    printf '%s\n' "$victim" | cliphist delete
    ;;
  "$query_row")
    query=$(fuzzel --dmenu --prompt-only="Delete matching  " --placeholder "text" --width 72 || true)
    [[ -z "$query" ]] && exit 0
    cliphist delete-query "$query"
    ;;
  *)
    printf '%s\n' "$pick" | cliphist decode | "$store" --normalize | wl-copy
    ;;
esac
