#!/usr/bin/env bash
# Copy live ~/.config files into this repo (no-op if they are already linked).

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

pull_path "$HOME/.config/niri" "$CONFIGS_DIR/niri"
pull_path "$HOME/.config/noctalia" "$CONFIGS_DIR/noctalia"
pull_path "$HOME/.config/xdg-desktop-portal/niri-portals.conf" \
  "$CONFIGS_DIR/xdg-desktop-portal/niri-portals.conf"
pull_path "$HOME/.bash_profile" "$CONFIGS_DIR/bash_profile"

log "configs pulled into $CONFIGS_DIR"
