#!/usr/bin/env bash
# Point live ~/.config paths at the copies in this repo.

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

mkdir -p "$HOME/.config"

link_path "$CONFIGS_DIR/niri" "$HOME/.config/niri"

if [[ -f "$CONFIGS_DIR/environment.d/gaming.conf" ]]; then
  mkdir -p "$HOME/.config/environment.d"
  link_path "$CONFIGS_DIR/environment.d/gaming.conf" "$HOME/.config/environment.d/gaming.conf"
fi

# Chrome's file dialog. Must be the desktop-named file (niri-portals.conf),
# which xdg-desktop-portal reads when XDG_CURRENT_DESKTOP=niri.
mkdir -p "$HOME/.config/xdg-desktop-portal"
link_path "$CONFIGS_DIR/xdg-desktop-portal/niri-portals.conf" \
  "$HOME/.config/xdg-desktop-portal/niri-portals.conf"
# Hyprland reads this when XDG_CURRENT_DESKTOP=Hyprland. The niri file stays.
link_path "$CONFIGS_DIR/xdg-desktop-portal/hyprland-portals.conf" \
  "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"

# The file, not the directory, so Hyprland's runtime files stay out of the repo.
link_path "$CONFIGS_DIR/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
link_path "$CONFIGS_DIR/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
link_path "$CONFIGS_DIR/hypr/hypridle.conf" "$HOME/.config/hypr/hypridle.conf"
mkdir -p "$HOME/.config/mako"
link_path "$CONFIGS_DIR/mako/config" "$HOME/.config/mako/config"
link_path "$CONFIGS_DIR/waybar" "$HOME/.config/waybar"
link_path "$CONFIGS_DIR/fuzzel" "$HOME/.config/fuzzel"

mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.local/bin"

chmod +x "$REPO_ROOT/scripts/launch-webapp.sh" \
  "$REPO_ROOT/scripts/launch-or-focus-webapp.sh" \
  "$REPO_ROOT/scripts/launch-or-focus-app.sh" \
  "$REPO_ROOT/scripts/launch-youtube.sh" \
  "$REPO_ROOT/scripts/launch-steam.sh" \
  "$REPO_ROOT/scripts/collapse-webapp-profile.sh" \
  "$REPO_ROOT/scripts/launch-discord.sh" \
  "$REPO_ROOT/scripts/launch-btop.sh" \
  "$REPO_ROOT/scripts/launch-grok-bot.sh" \
  "$REPO_ROOT/scripts/launch-steam-heroic.sh" \
  "$REPO_ROOT/scripts/lock.sh" \
  "$REPO_ROOT/scripts/hypr-clipboard.sh" \
  "$REPO_ROOT/scripts/hypr-notifications.sh" \
  "$REPO_ROOT/scripts/waybar-weather.py" \
  "$REPO_ROOT/scripts/waybar-disk.py" \
  "$REPO_ROOT/scripts/waybar-temp.py" \
  "$REPO_ROOT/scripts/waybar-gpu.py" \
  "$REPO_ROOT/scripts/waybar-cpu.py" \
  "$REPO_ROOT/scripts/waybar-mem.py" \
  "$REPO_ROOT/scripts/waybar-devices.py" \
  "$REPO_ROOT/scripts/waybar-media.py" \
  "$REPO_ROOT/scripts/waybar-ws.py" \
  "$REPO_ROOT/scripts/waybar-locks.py" \
  "$REPO_ROOT/scripts/waybar-updates.py" \
  "$REPO_ROOT/scripts/waybar-calendar.py" \
  "$REPO_ROOT/scripts/keychron-v6-via.py" \
  "$REPO_ROOT/scripts/neomutt-icat.sh"
link_path "$REPO_ROOT/scripts/launch-webapp.sh" "$HOME/.local/bin/launch-webapp.sh"
link_path "$REPO_ROOT/scripts/launch-or-focus-webapp.sh" "$HOME/.local/bin/launch-or-focus-webapp.sh"
link_path "$REPO_ROOT/scripts/launch-or-focus-app.sh" "$HOME/.local/bin/launch-or-focus-app.sh"
link_path "$REPO_ROOT/scripts/launch-youtube.sh" "$HOME/.local/bin/launch-youtube.sh"
link_path "$REPO_ROOT/scripts/launch-steam.sh" "$HOME/.local/bin/launch-steam.sh"
link_path "$REPO_ROOT/scripts/collapse-webapp-profile.sh" "$HOME/.local/bin/collapse-webapp-profile.sh"
link_path "$REPO_ROOT/scripts/launch-discord.sh" "$HOME/.local/bin/launch-discord.sh"
link_path "$REPO_ROOT/scripts/launch-btop.sh" "$HOME/.local/bin/launch-btop.sh"
link_path "$REPO_ROOT/scripts/launch-grok-bot.sh" "$HOME/.local/bin/launch-grok-bot.sh"
link_path "$REPO_ROOT/scripts/launch-steam-heroic.sh" "$HOME/.local/bin/launch-steam-heroic.sh"
link_path "$REPO_ROOT/scripts/lock.sh" "$HOME/.local/bin/lock.sh"
link_path "$REPO_ROOT/scripts/hypr-cheatsheet.sh" "$HOME/.local/bin/hypr-cheatsheet.sh"
link_path "$REPO_ROOT/scripts/hypr-wallpaper.sh" "$HOME/.local/bin/hypr-wallpaper.sh"
link_path "$REPO_ROOT/scripts/hypr-clipboard.sh" "$HOME/.local/bin/hypr-clipboard.sh"
link_path "$REPO_ROOT/scripts/hypr-notifications.sh" "$HOME/.local/bin/hypr-notifications.sh"
link_path "$REPO_ROOT/scripts/waybar-weather.py" "$HOME/.local/bin/waybar-weather.py"
link_path "$REPO_ROOT/scripts/waybar-disk.py" "$HOME/.local/bin/waybar-disk.py"
link_path "$REPO_ROOT/scripts/waybar-temp.py" "$HOME/.local/bin/waybar-temp.py"
link_path "$REPO_ROOT/scripts/waybar-gpu.py" "$HOME/.local/bin/waybar-gpu.py"
link_path "$REPO_ROOT/scripts/waybar-cpu.py" "$HOME/.local/bin/waybar-cpu.py"
link_path "$REPO_ROOT/scripts/waybar-mem.py" "$HOME/.local/bin/waybar-mem.py"
link_path "$REPO_ROOT/scripts/waybar-devices.py" "$HOME/.local/bin/waybar-devices.py"
link_path "$REPO_ROOT/scripts/waybar-media.py" "$HOME/.local/bin/waybar-media.py"
link_path "$REPO_ROOT/scripts/waybar-ws.py" "$HOME/.local/bin/waybar-ws.py"
link_path "$REPO_ROOT/scripts/waybar-locks.py" "$HOME/.local/bin/waybar-locks.py"
link_path "$REPO_ROOT/scripts/waybar-updates.py" "$HOME/.local/bin/waybar-updates.py"
link_path "$REPO_ROOT/scripts/waybar-calendar.py" "$HOME/.local/bin/waybar-calendar.py"
link_path "$REPO_ROOT/scripts/keychron-v6-via.py" "$HOME/.local/bin/keychron-v6-via.py"

if [[ -f "$CONFIGS_DIR/applications/steam.desktop" ]]; then
  link_path "$CONFIGS_DIR/applications/steam.desktop" "$HOME/.local/share/applications/steam.desktop"
fi

# Our names: symlink. Chrome-generated names: copy, so a Chrome rewrite
# cannot clobber the repo (and so Desktop launchers stay --app=URL).
install_desktop() {
  local src="$1" dest="$2"
  [[ -f "$src" ]] || die "desktop source missing: $src"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" ]]; then
    rm -f "$dest"
  elif [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    log "already current: $dest"
    return 0
  elif [[ -e "$dest" ]]; then
    local stamp dest_name backup
    stamp="$(date +%Y%m%d-%H%M%S)"
    dest_name="$(basename "$dest")"
    backup="$BACKUP_DIR/$stamp/$dest_name"
    mkdir -p "$(dirname "$backup")"
    log "backing up $dest -> $backup"
    mv "$dest" "$backup"
  fi
  cp "$src" "$dest"
  log "installed $dest"
}

link_path "$CONFIGS_DIR/applications/board-game-arena.desktop" \
  "$HOME/.local/share/applications/board-game-arena.desktop"
link_path "$CONFIGS_DIR/applications/gmail.desktop" \
  "$HOME/.local/share/applications/Gmail.desktop"
link_path "$CONFIGS_DIR/applications/google-messages.desktop" \
  "$HOME/.local/share/applications/Google Messages.desktop"
link_path "$CONFIGS_DIR/applications/google-maps.desktop" \
  "$HOME/.local/share/applications/Google Maps.desktop"
link_path "$CONFIGS_DIR/applications/google-calendar.desktop" \
  "$HOME/.local/share/applications/Google Calendar.desktop"
link_path "$CONFIGS_DIR/applications/youtube-music.desktop" \
  "$HOME/.local/share/applications/YouTube Music.desktop"
link_path "$CONFIGS_DIR/applications/youtube.desktop" \
  "$HOME/.local/share/applications/YouTube.desktop"
link_path "$CONFIGS_DIR/applications/superfile.desktop" \
  "$HOME/.local/share/applications/superfile.desktop"
link_path "$CONFIGS_DIR/applications/concord.desktop" \
  "$HOME/.local/share/applications/concord.desktop"
link_path "$CONFIGS_DIR/applications/neomutt.desktop" \
  "$HOME/.local/share/applications/neomutt.desktop"
mkdir -p "$HOME/.config/neomutt"
link_path "$CONFIGS_DIR/neomutt/neomuttrc" "$HOME/.config/neomutt/neomuttrc"
link_path "$CONFIGS_DIR/neomutt/mailcap" "$HOME/.config/neomutt/mailcap"
link_path "$REPO_ROOT/scripts/neomutt-icat.sh" "$HOME/.local/bin/neomutt-icat.sh"

install_desktop "$CONFIGS_DIR/applications/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" \
  "$HOME/.local/share/applications/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop"
if [[ -f "$HOME/Desktop/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" || -L "$HOME/Desktop/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" ]]; then
  install_desktop "$CONFIGS_DIR/applications/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" \
    "$HOME/Desktop/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop"
fi

# tty1 login stays a shell. CachyOS's stock file execs niri; do not
# put that back. Type niri or start-hyprland (see bash_profile).
link_path "$CONFIGS_DIR/bash_profile" "$HOME/.bash_profile"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

log "configs applied"
