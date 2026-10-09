#!/usr/bin/env bash
# Install Hyprland beside niri. Run this from the tty prompt.
#
# It does not start Hyprland, does not start Noctalia, and does not
# change how login works. After it finishes, type: start-hyprland

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

journal_append "Hyprland config beside niri" "$(cat <<'EOF'
- packages: hyprland, xdg-desktop-portal-hyprland
- config: configs/hypr/hyprland.lua (dwindle) and configs/waybar. Noctalia is not started.
- portal: configs/xdg-desktop-portal/hyprland-portals.conf
- from the tty prompt type start-hyprland. type niri for the other session.
- Super+Shift+Q quits Hyprland. Do not run both compositors at once.
EOF
)"

cat <<'EOF'

Hyprland is installed. Waybar is the bar. Launcher, lock screen,
clipboard, and control center stay on niri.

From this prompt, type:

  start-hyprland

Super+Return opens Alacritty. Super+E opens Nautilus.
Super+Shift+letter opens the same apps as on niri.
Super+arrows move focus. Super+Shift+arrows move the window.
Super+Shift+Q quits back to this prompt.

If the screen is stuck, press Ctrl+Alt+F2 and log in there.
Type niri for the other session. Do not run both at once.
EOF
