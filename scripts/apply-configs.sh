#!/usr/bin/env bash
# Point live ~/.config paths at the copies in this repo.

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

mkdir -p "$HOME/.config"

link_path "$CONFIGS_DIR/niri" "$HOME/.config/niri"
link_path "$CONFIGS_DIR/noctalia" "$HOME/.config/noctalia"
link_path "$CONFIGS_DIR/niri-screensaver" "$HOME/.config/niri-screensaver"

if [[ -f "$CONFIGS_DIR/environment.d/gaming.conf" ]]; then
  mkdir -p "$HOME/.config/environment.d"
  link_path "$CONFIGS_DIR/environment.d/gaming.conf" "$HOME/.config/environment.d/gaming.conf"
fi

mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.local/bin"

chmod +x "$REPO_ROOT/scripts/launch-webapp.sh" \
  "$REPO_ROOT/scripts/launch-or-focus-webapp.sh" \
  "$REPO_ROOT/scripts/collapse-webapp-profile.sh" \
  "$REPO_ROOT/scripts/launch-discord.sh" \
  "$REPO_ROOT/scripts/launch-btop.sh" \
  "$REPO_ROOT/scripts/launch-grok-bot.sh" \
  "$REPO_ROOT/scripts/lock.sh" \
  "$REPO_ROOT/scripts/novalis-screensaver" \
  "$REPO_ROOT/scripts/novalis-tunnel.py" \
  "$REPO_ROOT/scripts/novalis-bloom.py" \
  "$REPO_ROOT/scripts/novalis-clock.py" \
  "$REPO_ROOT/scripts/novalis-rain.py"
link_path "$REPO_ROOT/scripts/launch-webapp.sh" "$HOME/.local/bin/launch-webapp.sh"
link_path "$REPO_ROOT/scripts/launch-or-focus-webapp.sh" "$HOME/.local/bin/launch-or-focus-webapp.sh"
link_path "$REPO_ROOT/scripts/collapse-webapp-profile.sh" "$HOME/.local/bin/collapse-webapp-profile.sh"
link_path "$REPO_ROOT/scripts/launch-discord.sh" "$HOME/.local/bin/launch-discord.sh"
link_path "$REPO_ROOT/scripts/launch-btop.sh" "$HOME/.local/bin/launch-btop.sh"
link_path "$REPO_ROOT/scripts/launch-grok-bot.sh" "$HOME/.local/bin/launch-grok-bot.sh"
link_path "$REPO_ROOT/scripts/lock.sh" "$HOME/.local/bin/lock.sh"
link_path "$REPO_ROOT/scripts/novalis-screensaver" "$HOME/.local/bin/novalis-screensaver"
link_path "$REPO_ROOT/scripts/novalis-tunnel.py" "$HOME/.local/bin/novalis-tunnel.py"
link_path "$REPO_ROOT/scripts/novalis-bloom.py" "$HOME/.local/bin/novalis-bloom.py"
link_path "$REPO_ROOT/scripts/novalis-clock.py" "$HOME/.local/bin/novalis-clock.py"
link_path "$REPO_ROOT/scripts/novalis-rain.py" "$HOME/.local/bin/novalis-rain.py"

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

install_desktop "$CONFIGS_DIR/applications/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" \
  "$HOME/.local/share/applications/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop"
if [[ -f "$HOME/Desktop/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" || -L "$HOME/Desktop/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" ]]; then
  install_desktop "$CONFIGS_DIR/applications/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop" \
    "$HOME/Desktop/chrome-acgfoponpgapajbgbfgboblhfejpaamn-Default.desktop"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

plugins_file="$PACKAGES_DIR/noctalia-plugins.txt"
if command -v noctalia >/dev/null 2>&1 && [[ -f "$plugins_file" ]]; then
  while read -r plugin; do
    [[ -n "$plugin" ]] || continue
    log "enabling noctalia plugin: $plugin"
    noctalia msg plugins enable "$plugin" >/dev/null || warn "could not enable $plugin"
  done < <(read_pkg_list "$plugins_file")
fi

log "configs applied"
