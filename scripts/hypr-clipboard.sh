#!/usr/bin/env bash
# Super+V. Pick a cliphist entry in Fuzzel and copy it back.
set -euo pipefail

pick=$(cliphist list | fuzzel --dmenu --prompt "Clipboard  " --width 72 --lines 18 || true)
if [[ -z "$pick" ]]; then
  exit 0
fi
printf '%s\n' "$pick" | cliphist decode | wl-copy
