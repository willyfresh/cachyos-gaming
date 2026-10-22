#!/usr/bin/env bash
# Copy live ~/.config files into this repo (no-op if they are already linked).

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

pull_config_links
pull_path "$HOME/.bash_profile" "$CONFIGS_DIR/bash_profile"
pull_path "$HOME/.magic" "$CONFIGS_DIR/magic"

log "configs pulled into $CONFIGS_DIR"
