#!/usr/bin/env bash
# Super+Alt+Mic. Unload the dictation model, or load it again.
set -euo pipefail
flag="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hyprwhspr/model_unloaded"
if [[ -e "$flag" ]]; then
  exec hyprwhspr model reload
fi
exec hyprwhspr model unload
