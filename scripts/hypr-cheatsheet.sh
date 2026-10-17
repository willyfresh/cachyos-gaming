#!/usr/bin/env bash
# Super+K. A searchable list of this session's keys, same job as
# Omarchy's omarchy-menu-keybindings. Picking a line does not run it.
set -euo pipefail

cat <<'EOF' | fuzzel --dmenu --prompt "Keys  " --placeholder "search" --width 72 --lines 18
Super+K                     Keybind cheatsheet
Super+Shift+Return          Wallpaper color
Super+Space                 Launcher
Super+V                     Clipboard history
Super+N                     Notification history
Super+L                     Lock screen
Super+Return                Terminal
Super+E                     Files
Super+Q                     Close window
Super+Shift+Q               Quit Hyprland
Super+T                     Float or tile
Super+F                     Maximize, keep the gaps
Super+Ctrl+F                Maximize, keep the gaps
Super+Shift+F               Cover the screen
Super+M                     Maximize, keep the gaps
Super+Shift+V               Focus a floating window, or a tiled one
Super+Alt+P                 Turn the screens off
Super+minus                 This window 10% narrower
Super+equal                 This window 10% wider
Super+Shift+minus           This window 10% shorter
Super+Shift+equal           This window 10% taller
Super+Left/Right            Focus that way
Super+Up                    Focus up. At the top window, previous workspace
Super+Down                  Focus down. At the bottom window, next workspace
Super+Shift+arrows          Move the window that way
Super+Alt+arrows            Focus the monitor that way
Super+Shift+Alt+arrows      Move the window to that monitor
Super+Ctrl+Left/Up          Previous workspace on this screen
Super+Ctrl+Right/Down       Next workspace on this screen
Super+Shift+Ctrl+arrows     Move the window to that workspace
Super+Ctrl+Alt+arrows       Resize, same steps as Super+/-
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
Volume keys                 Volume up, down, mute
Mic / Ctrl+Shift+F6         Mute the microphone
Play / Ctrl+Shift+F8        Play or pause
Ctrl+Shift+F2               Notification history
Media next / previous       Next or previous track
Print / crop                Screenshot a region
Alt+Print                   Screenshot the window
Super+Print                 Screenshot both screens
EOF
