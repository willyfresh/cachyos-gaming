#!/usr/bin/env bash
# Install Hyprland. Run this from the tty prompt.
#
# It does not start Hyprland and does not change how login works.
# After it finishes, type: start-hyprland

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  warn "a Wayland session is up (WAYLAND_DISPLAY=${WAYLAND_DISPLAY})."
  warn "install can continue. quit to the tty prompt before you start Hyprland."
fi

need_cmd pacman

"$REPO_ROOT/scripts/pkg-add.sh" hyprland xdg-desktop-portal-hyprland
"$REPO_ROOT/scripts/apply-configs.sh"

journal_append "Hyprland config" "$(cat <<'EOF'
- packages: hyprland, xdg-desktop-portal-hyprland
- config: configs/hypr/hyprland.lua (dwindle) and configs/waybar.
- portal: configs/xdg-desktop-portal/hyprland-portals.conf
- from the tty prompt type start-hyprland.
- Super+Shift+Q quits Hyprland.
EOF
)"

cat <<'EOF'

Hyprland is installed. Waybar is the bar. Super+Space opens Fuzzel.
Super+L locks. Super+V opens the clipboard.

From this prompt, type:

  start-hyprland

Super+Return opens Alacritty. Super+E opens Nautilus.
Super+Shift+letter opens the apps.
Super+arrows move focus. Super+Shift+arrows move the window.
Super+Shift+Q quits back to this prompt.

If the screen is stuck, press Ctrl+Alt+F2 and log in there.
EOF
