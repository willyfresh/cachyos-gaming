#!/usr/bin/env bash
# Yazi `g` then `a`. Open the hovered path in the Grok CLI.
# A directory is the working directory. A file uses its parent.
# No path means the directory Yazi is already in.
set -euo pipefail

path="${1:-}"
if [[ -z "$path" ]]; then
  dir="$PWD"
elif [[ -d "$path" ]]; then
  dir="$path"
else
  dir="$(dirname -- "$path")"
fi

if [[ ! -d "$dir" ]]; then
  echo "yazi-open-grok: not a directory: $dir" >&2
  exit 1
fi

exec setsid -f kitty --class grok-cli --title grok --working-directory "$dir" \
  -e /home/willyfresh/.grok/bin/grok
