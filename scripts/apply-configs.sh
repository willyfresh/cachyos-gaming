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

mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.local/bin"

if [[ -f "$CONFIGS_DIR/applications/steam.desktop" ]]; then
  link_path "$CONFIGS_DIR/applications/steam.desktop" "$HOME/.local/share/applications/steam.desktop"
fi

if [[ -x "$REPO_ROOT/scripts/board-game-arena" ]]; then
  chmod +x "$REPO_ROOT/scripts/board-game-arena"
  link_path "$REPO_ROOT/scripts/board-game-arena" "$HOME/.local/bin/board-game-arena"
fi

if [[ -f "$CONFIGS_DIR/applications/board-game-arena.desktop" ]]; then
  link_path "$CONFIGS_DIR/applications/board-game-arena.desktop" "$HOME/.local/share/applications/board-game-arena.desktop"
fi

# Replace Chrome's generated PWA shortcut so existing launchers stay correct.
if [[ -f "$CONFIGS_DIR/applications/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" ]]; then
  link_path "$CONFIGS_DIR/applications/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" \
    "$HOME/.local/share/applications/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop"
  if [[ -f "$HOME/Desktop/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" || -L "$HOME/Desktop/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" ]]; then
    link_path "$CONFIGS_DIR/applications/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" \
      "$HOME/Desktop/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop"
  fi
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

log "configs applied"
