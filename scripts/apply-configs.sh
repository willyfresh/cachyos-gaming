#!/usr/bin/env bash
# Point live ~/.config paths at the copies in this repo.

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

mkdir -p "$HOME/.config"

link_path "$CONFIGS_DIR/niri" "$HOME/.config/niri"
link_path "$CONFIGS_DIR/noctalia" "$HOME/.config/noctalia"

if [[ -f "$CONFIGS_DIR/environment.d/gaming.conf" ]]; then
  mkdir -p "$HOME/.config/environment.d"
  link_path "$CONFIGS_DIR/environment.d/gaming.conf" "$HOME/.config/environment.d/gaming.conf"
fi

log "configs applied"
