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
Super+E                     Yazi
Super+Q / Alt+F4            Close window
Super+Shift+Q               Quit Hyprland
Super+T                     Float or tile
Super+F                     Maximize, keep the gaps
Super+Ctrl+F                Maximize, keep the gaps
Super+Ctrl+F2               Cover the screen
Super+M                     Maximize, keep the gaps
Super+Alt+P                 Turn the screens off
Super+minus                 This window 10% narrower
Super+equal                 This window 10% wider
Super+Shift+minus           This window 10% shorter
Super+Shift+equal           This window 10% taller
Super+Left/Right            Focus that way
Super+Up                    Focus up. At the top window, previous workspace
Super+Down                  Focus down. At the bottom window, next workspace
Super+Shift+Left/Right      Move the window that way
Super+Shift+Up              Move up. At the top, previous workspace, even if empty
Super+Shift+Down            Move down. At the bottom, next workspace, even if empty
Super+1…0                   This screen's workspace
Super+Shift+1…0             Move the window to that workspace
Super+Shift+Tab             Previous workspace on this screen
Alt+Tab                     Next window
Alt+Shift+Tab               Previous window
Super+Ctrl+T                btop
Super+Shift+T               btop
Super+Shift+Ctrl+T          nvtop
Super+Shift+A               Grok Bot
Super+Shift+Ctrl+A          Grok
Super+Shift+B               Board Game Arena
Super+Shift+C               Calendar
Super+Shift+D               Discord
Super+Shift+Ctrl+D          Concord
Super+Shift+E               Thunderbird
Super+Shift+Ctrl+E          Thunderbird compose
Super+Shift+G               Gmail
Super+Shift+H               Heroic
Super+Shift+I               Inkscape
Super+Shift+L               Maps
Super+Shift+M               Messages
Super+Shift+O               LibreOffice
Super+Shift+Ctrl+O          Obsidian
Super+Shift+P               GIMP
Super+Shift+S               Steam
Super+Shift+V               Neovim
Super+Shift+Ctrl+V          VS Code
Super+Shift+W               Chrome
Super+Shift+Ctrl+W          Lynx
Super+Shift+Y               YouTube Music
Super+Shift+Ctrl+Y          YouTube
Volume keys                 Volume up, down, mute
Mic / Ctrl+Shift+F6         Mute the microphone
Play / Ctrl+Shift+F8        Play or pause
Media next / previous       Next or previous track
Print / crop                Screenshot a region
Alt+Print                   Screenshot the window
Super+Print                 Screenshot both screens
EOF
