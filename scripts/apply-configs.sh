#!/usr/bin/env bash
# Point live ~/.config paths at the copies in this repo.

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

apply_config_links

# User commands. Repo tools and waybar_level.py stay in the repo.
bin_scripts=(
  launch-webapp.sh
  launch-app.sh
  collapse-webapp-profile.sh
  hypr-cheatsheet.sh
  hypr-wallpaper.sh
  hypr-clipboard.sh
  hypr-clipboard-store.sh
  hypr-notifications.sh
  hypr-screenshot.sh
  hypr-switcher.py
  hypr-session.sh
  waybar-weather.py
  waybar-disk.py
  waybar-temp.py
  waybar-gpu.py
  waybar-cpu.py
  waybar-mem.py
  waybar-devices.py
  waybar-media.py
  waybar-ws.py
  waybar-locks.py
  waybar-updates.py
  waybar-notifications.py
  waybar-calendar.py
  waybar-clock.py
  keychron-v6-via.py
  neomutt-icat.sh
)

for name in "${bin_scripts[@]}"; do
  chmod +x "$REPO_ROOT/scripts/$name"
  link_path "$REPO_ROOT/scripts/$name" "$HOME/.local/bin/$name"
done

# Fuzzel only looks in the apps context. These are the site icons.
shopt -s globstar nullglob
for src in "$CONFIGS_DIR"/icons/**/*; do
  [[ -f "$src" ]] || continue
  rel="${src#"$CONFIGS_DIR/icons/"}"
  link_path "$src" "$HOME/.local/share/icons/$rel"
done
shopt -u globstar nullglob

# Dest basename differs when it must match the Chrome webapp filename.
desktop_links=(
  board-game-arena.desktop
  concord.desktop
  neomutt.desktop
  nvim.desktop
  steam.desktop
  superfile.desktop
  "gmail.desktop|Gmail.desktop"
  "google-messages.desktop|Google Messages.desktop"
  "google-maps.desktop|Google Maps.desktop"
  "google-calendar.desktop|Google Calendar.desktop"
  "youtube-music.desktop|YouTube Music.desktop"
  "youtube.desktop|YouTube.desktop"
  "google-tasks.desktop|Google Tasks.desktop"
  "google-keep.desktop|Google Keep.desktop"
  "google-drive.desktop|Google Drive.desktop"
  "google-photos.desktop|Google Photos.desktop"
  "feedly.desktop|Feedly.desktop"
)

for spec in "${desktop_links[@]}"; do
  src="${spec%%|*}"
  dest="${spec#*|}"
  link_path "$CONFIGS_DIR/applications/$src" \
    "$HOME/.local/share/applications/$dest"
done

# Chrome --app-id files repeat a name we already launch. Hide those.
# Chrome rewrites its own files; the next apply hides the twin again.
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
