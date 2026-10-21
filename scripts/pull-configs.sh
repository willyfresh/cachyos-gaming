#!/usr/bin/env bash
# Copy live ~/.config files into this repo (no-op if they are already linked).

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

pull_path "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf" \
  "$CONFIGS_DIR/xdg-desktop-portal/hyprland-portals.conf"
pull_path "$HOME/.config/hypr/hyprland.lua" "$CONFIGS_DIR/hypr/hyprland.lua"
pull_path "$HOME/.config/hypr/hyprlock.conf" "$CONFIGS_DIR/hypr/hyprlock.conf"
pull_path "$HOME/.config/hypr/hypridle.conf" "$CONFIGS_DIR/hypr/hypridle.conf"
pull_path "$HOME/.config/hypr/config" "$CONFIGS_DIR/hypr/config"
pull_path "$HOME/.config/hypr/keybinds" "$CONFIGS_DIR/hypr/keybinds"
pull_path "$HOME/.config/hypr/hyprsplit" "$CONFIGS_DIR/hypr/hyprsplit"
pull_path "$HOME/.config/mako/config" "$CONFIGS_DIR/mako/config"
pull_path "$HOME/.config/kitty/kitty.conf" "$CONFIGS_DIR/kitty/kitty.conf"
pull_path "$HOME/.config/waybar" "$CONFIGS_DIR/waybar"
pull_path "$HOME/.bash_profile" "$CONFIGS_DIR/bash_profile"
pull_path "$HOME/.config/nvim" "$CONFIGS_DIR/nvim"
pull_path "$HOME/.config/mimeapps.list" "$CONFIGS_DIR/mimeapps.list"
pull_path "$HOME/.config/lsfg-vk/conf.toml" "$CONFIGS_DIR/lsfg-vk/conf.toml"
pull_path "$HOME/.config/MangoHud/MangoHud.conf" "$CONFIGS_DIR/MangoHud/MangoHud.conf"

log "configs pulled into $CONFIGS_DIR"
