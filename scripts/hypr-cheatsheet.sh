#!/usr/bin/env bash
# Super+K. A searchable list of this session's keys, same job as the
# niri cheatsheet and Omarchy's omarchy-menu-keybindings. Picking a
# line does not run it.
set -euo pipefail

cat <<'EOF' | fuzzel --dmenu --prompt "Keys  " --placeholder "search" --width 72 --lines 18
Super+K                     Keybind cheatsheet
Super+Shift+Return          Wallpaper color
Super+Space                 Launcher
Super+Return                Terminal
Super+E                     Files
Super+Q                     Close window
Super+Shift+Q               Quit Hyprland
Super+T                     Float or tile
Super+F                     Maximize, keep the gaps
Super+Ctrl+F                Maximize, keep the gaps
Super+Shift+F               Cover the screen
Super+minus                 This window 10% narrower
Super+equal                 This window 10% wider
Super+Shift+minus           This window 10% shorter
Super+Shift+equal           This window 10% taller
Super+arrows                Focus that way
Super+Shift+arrows          Move the window that way
Super+Alt+arrows            Focus the monitor that way
Super+Shift+Alt+arrows      Move the window to that monitor
Super+1…0                   This screen's workspace
Super+Shift+1…0             Move the window to that workspace
Super+Shift+Tab             Previous workspace on this screen
Alt+Tab                     Next window
Alt+Shift+Tab               Previous window
Super+Ctrl+T                btop
Super+Shift+B               Board Game Arena
Super+Shift+C               Calendar
Super+Shift+D               Discord
Super+Shift+E               Thunderbird
Super+Shift+Alt+E           Thunderbird compose
Super+Shift+G               Gmail
Super+Shift+H               Heroic
Super+Shift+I               Inkscape
Super+Shift+L               Maps
Super+Shift+M               Messages
Super+Shift+O               LibreOffice
Super+Shift+P               GIMP
Super+Shift+S               Steam
Super+Shift+T               VS Code
Super+Shift+W               Chrome
Super+Shift+Y               YouTube Music, then YouTube
Super+Shift+Alt+A           Grok
EOF
