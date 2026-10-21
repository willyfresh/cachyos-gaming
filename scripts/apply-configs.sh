#!/usr/bin/env bash
# Point live ~/.config paths at the copies in this repo.

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

mkdir -p "$HOME/.config"

if [[ -f "$CONFIGS_DIR/environment.d/gaming.conf" ]]; then
  mkdir -p "$HOME/.config/environment.d"
  link_path "$CONFIGS_DIR/environment.d/gaming.conf" "$HOME/.config/environment.d/gaming.conf"
fi

# Chrome's file dialog. xdg-desktop-portal reads this file when
# XDG_CURRENT_DESKTOP=Hyprland.
mkdir -p "$HOME/.config/xdg-desktop-portal"
link_path "$CONFIGS_DIR/xdg-desktop-portal/hyprland-portals.conf" \
  "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"

# The file, not the directory, so Hyprland's runtime files stay out of the repo.
# require() still looks in ~/.config/hypr, so the module trees are linked too.
link_path "$CONFIGS_DIR/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
link_path "$CONFIGS_DIR/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
link_path "$CONFIGS_DIR/hypr/hypridle.conf" "$HOME/.config/hypr/hypridle.conf"
link_path "$CONFIGS_DIR/hypr/config" "$HOME/.config/hypr/config"
link_path "$CONFIGS_DIR/hypr/keybinds" "$HOME/.config/hypr/keybinds"
link_path "$CONFIGS_DIR/hypr/hyprsplit" "$HOME/.config/hypr/hyprsplit"
mkdir -p "$HOME/.config/mako"
link_path "$CONFIGS_DIR/mako/config" "$HOME/.config/mako/config"
link_path "$CONFIGS_DIR/waybar" "$HOME/.config/waybar"
link_path "$CONFIGS_DIR/fuzzel" "$HOME/.config/fuzzel"
mkdir -p "$HOME/.config/kitty"
link_path "$CONFIGS_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
mkdir -p "$HOME/.config/yazi"
link_path "$CONFIGS_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
link_path "$CONFIGS_DIR/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
# Neovim state stays in ~/.local/share/nvim and ~/.local/state/nvim.
link_path "$CONFIGS_DIR/nvim" "$HOME/.config/nvim"
link_path "$CONFIGS_DIR/mimeapps.list" "$HOME/.config/mimeapps.list"
# The file, not the directory. lsfg-vk and Goverlay write beside these.
mkdir -p "$HOME/.config/lsfg-vk"
link_path "$CONFIGS_DIR/lsfg-vk/conf.toml" "$HOME/.config/lsfg-vk/conf.toml"
mkdir -p "$HOME/.config/MangoHud"
link_path "$CONFIGS_DIR/MangoHud/MangoHud.conf" "$HOME/.config/MangoHud/MangoHud.conf"

mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.local/bin"

chmod +x "$REPO_ROOT/scripts/launch-webapp.sh" \
  "$REPO_ROOT/scripts/launch-app.sh" \
  "$REPO_ROOT/scripts/collapse-webapp-profile.sh" \
  "$REPO_ROOT/scripts/hypr-clipboard.sh" \
  "$REPO_ROOT/scripts/hypr-clipboard-store.sh" \
  "$REPO_ROOT/scripts/hypr-notifications.sh" \
  "$REPO_ROOT/scripts/hypr-screenshot.sh" \
  "$REPO_ROOT/scripts/hypr-switcher.py" \
  "$REPO_ROOT/scripts/hypr-session.sh" \
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
  "$REPO_ROOT/scripts/waybar-notifications.py" \
  "$REPO_ROOT/scripts/waybar-calendar.py" \
  "$REPO_ROOT/scripts/waybar-clock.py" \
  "$REPO_ROOT/scripts/keychron-v6-via.py" \
  "$REPO_ROOT/scripts/neomutt-icat.sh"
link_path "$REPO_ROOT/scripts/launch-webapp.sh" "$HOME/.local/bin/launch-webapp.sh"
link_path "$REPO_ROOT/scripts/launch-app.sh" "$HOME/.local/bin/launch-app.sh"
link_path "$REPO_ROOT/scripts/collapse-webapp-profile.sh" "$HOME/.local/bin/collapse-webapp-profile.sh"
link_path "$REPO_ROOT/scripts/hypr-cheatsheet.sh" "$HOME/.local/bin/hypr-cheatsheet.sh"
link_path "$REPO_ROOT/scripts/hypr-wallpaper.sh" "$HOME/.local/bin/hypr-wallpaper.sh"
link_path "$REPO_ROOT/scripts/hypr-clipboard.sh" "$HOME/.local/bin/hypr-clipboard.sh"
link_path "$REPO_ROOT/scripts/hypr-clipboard-store.sh" "$HOME/.local/bin/hypr-clipboard-store.sh"
link_path "$REPO_ROOT/scripts/hypr-notifications.sh" "$HOME/.local/bin/hypr-notifications.sh"
link_path "$REPO_ROOT/scripts/hypr-screenshot.sh" "$HOME/.local/bin/hypr-screenshot.sh"
link_path "$REPO_ROOT/scripts/hypr-switcher.py" "$HOME/.local/bin/hypr-switcher.py"
link_path "$REPO_ROOT/scripts/hypr-session.sh" "$HOME/.local/bin/hypr-session.sh"
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
link_path "$REPO_ROOT/scripts/waybar-notifications.py" "$HOME/.local/bin/waybar-notifications.py"
link_path "$REPO_ROOT/scripts/waybar-calendar.py" "$HOME/.local/bin/waybar-calendar.py"
link_path "$REPO_ROOT/scripts/waybar-clock.py" "$HOME/.local/bin/waybar-clock.py"
link_path "$REPO_ROOT/scripts/keychron-v6-via.py" "$HOME/.local/bin/keychron-v6-via.py"

if [[ -f "$CONFIGS_DIR/applications/steam.desktop" ]]; then
  link_path "$CONFIGS_DIR/applications/steam.desktop" "$HOME/.local/share/applications/steam.desktop"
fi

# Fuzzel only looks in the apps context. These are the site icons.
link_path "$CONFIGS_DIR/icons/hicolor/256x256/apps/gmail.png" \
  "$HOME/.local/share/icons/hicolor/256x256/apps/gmail.png"
link_path "$CONFIGS_DIR/icons/hicolor/128x128/apps/google-calendar.png" \
  "$HOME/.local/share/icons/hicolor/128x128/apps/google-calendar.png"
link_path "$CONFIGS_DIR/icons/hicolor/512x512/apps/google-maps.png" \
  "$HOME/.local/share/icons/hicolor/512x512/apps/google-maps.png"
link_path "$CONFIGS_DIR/icons/hicolor/192x192/apps/google-messages.png" \
  "$HOME/.local/share/icons/hicolor/192x192/apps/google-messages.png"
link_path "$CONFIGS_DIR/icons/hicolor/256x256/apps/youtube.png" \
  "$HOME/.local/share/icons/hicolor/256x256/apps/youtube.png"
link_path "$CONFIGS_DIR/icons/hicolor/128x128/apps/youtube-music.png" \
  "$HOME/.local/share/icons/hicolor/128x128/apps/youtube-music.png"

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

# Chrome --app-id files repeat a name we already launch (YouTube, Maps,
# Board Game Arena). Hide those. Drive, Keep, Photos, and Tasks have no
# twin, so they stay. Chrome rewrites its own files; the next apply
# hides the twin again.
hide_chrome_name_twins() {
  local apps="${1:-$HOME/.local/share/applications}"
  python3 - "$apps" /usr/share/applications <<'PY'
import sys
from pathlib import Path

edit_root = Path(sys.argv[1])
scan_roots = [edit_root, *[Path(p) for p in sys.argv[2:]]]
if not edit_root.is_dir():
    sys.exit(0)

def entry_fields(path):
    name = None
    nodisplay = False
    section = None
    for raw in path.read_text(errors="replace").splitlines():
        line = raw.strip()
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
            continue
        if section != "Desktop Entry" or not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        if key == "Name" and name is None:
            name = value
        elif key == "NoDisplay" and value.strip().lower() == "true":
            nodisplay = True
    return name, nodisplay

def set_nodisplay(path):
    lines = path.read_text(errors="replace").splitlines()
    section = None
    entry_end = None
    for i, raw in enumerate(lines):
        line = raw.strip()
        if line.startswith("[") and line.endswith("]"):
            if section == "Desktop Entry":
                entry_end = i
                break
            section = line[1:-1]
            continue
        if section == "Desktop Entry" and line.startswith("NoDisplay="):
            lines[i] = "NoDisplay=true"
            path.write_text("\n".join(lines) + "\n")
            return
    if entry_end is None:
        lines.append("NoDisplay=true")
    else:
        lines.insert(entry_end, "NoDisplay=true")
    path.write_text("\n".join(lines) + "\n")

friendly = {}
for root in scan_roots:
    if not root.is_dir():
        continue
    for path in root.glob("*.desktop"):
        name, nodisplay = entry_fields(path)
        if name and not path.name.startswith("chrome-") and not nodisplay:
            friendly.setdefault(name, path.name)

for path in sorted(edit_root.glob("chrome-*.desktop")):
    name, nodisplay = entry_fields(path)
    if not name or nodisplay or name not in friendly:
        continue
    set_nodisplay(path)
    print(f"hide {path.name} ({name}); menu keeps {friendly[name]}")
PY
}

hide_chrome_name_twins

# tty1 login stays a shell. CachyOS's stock file execs a compositor; do not
# put that back. Type start-hyprland (see bash_profile).
link_path "$CONFIGS_DIR/bash_profile" "$HOME/.bash_profile"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi

log "configs applied"
