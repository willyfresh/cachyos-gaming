#!/usr/bin/env bash
# Super+K. The line you pick is typed, so the Hyprland bind runs.
# The two wheel rows are labels: wtype cannot turn the wheel.
# wtype is ~/.local/bin/wtype. Hyprland's PATH has no ~/.local/bin.
set -euo pipefail

# key|what it does|wtype args, or "-" when the row is not a key.
# Order: Super+K, Super+Space, Super+Tab, Alt+Tab, Ctrl+Alt+Delete,
# the single buttons, Super scroll and arrows, the other Super chords
# in alpha order, Super+Shift with Super+Shift+Ctrl beside the same
# letter, then everything else.
rows=$(cat <<'EOF'
Super+K|Keybind cheatsheet|-M logo -k k -m logo
Super+Space|Launcher|-M logo -k space -m logo
Super+Tab|Every window, by screen. Esc closes|-M logo -k Tab -m logo
Alt+Tab|Recent windows. Release Alt to switch|-M alt -k Tab -m alt
Ctrl+Alt+Delete|Session: lock, quit, reboot, shut down|-M ctrl -M alt -k Delete -m alt -m ctrl

Super+N|Circle. Notification history|-M logo -k n -m logo
Ctrl+Shift+F3|Triangle. Update list|-M ctrl -M shift -k F3 -m shift -m ctrl
Ctrl+Shift+F4|Square. Devices|-M ctrl -M shift -k F4 -m shift -m ctrl
Ctrl+Shift+F5|X. Session: lock, quit, reboot, shut down|-M ctrl -M shift -k F5 -m shift -m ctrl
Volume up|5% louder|-k XF86AudioRaiseVolume
Volume down|5% quieter|-k XF86AudioLowerVolume
Volume mute|Mute or unmute|-k XF86AudioMute
Ctrl+Shift+F6|Mic. Mute the microphone|-M ctrl -M shift -k F6 -m shift -m ctrl
Ctrl+Shift+F8|Play or pause|-M ctrl -M shift -k F8 -m shift -m ctrl
Media next|Next track|-k XF86AudioNext
Media previous|Previous track|-k XF86AudioPrev
Crop|Screenshot a region|-k Print
Shift+Crop|Screenshot the window|-M shift -k Print -m shift
Ctrl+Shift+Crop|Screenshot both screens|-M ctrl -M shift -k Print -m shift -m ctrl

Super+scroll down|Next occupied workspace on this screen|-
Super+scroll up|Previous occupied workspace on this screen|-
Super+Left|Focus left|-M logo -k Left -m logo
Super+Right|Focus right|-M logo -k Right -m logo
Super+Up|Focus up. At the top window, previous workspace|-M logo -k Up -m logo
Super+Down|Focus down. At the bottom window, next workspace|-M logo -k Down -m logo

Super+E|Files|-M logo -k e -m logo
Super+F|Maximize, keep the gaps|-M logo -k f -m logo
Super+L|Lock screen|-M logo -k l -m logo
Super+M|Maximize, keep the gaps|-M logo -k m -m logo
Super+Q|Close window|-M logo -k q -m logo
Super+T|Float or tile|-M logo -k t -m logo
Super+V|Clipboard history|-M logo -k v -m logo
Super+W|Weather|-M logo -k w -m logo
Super+Return|Terminal|-M logo -k Return -m logo
Super+minus|This window 10% narrower|-M logo -k minus -m logo
Super+equal|This window 10% wider|-M logo -k equal -m logo
Super+1|This screen's workspace 1|-M logo -k 1 -m logo
Super+2|This screen's workspace 2|-M logo -k 2 -m logo
Super+3|This screen's workspace 3|-M logo -k 3 -m logo
Super+4|This screen's workspace 4|-M logo -k 4 -m logo
Super+5|This screen's workspace 5|-M logo -k 5 -m logo
Super+6|This screen's workspace 6|-M logo -k 6 -m logo
Super+7|This screen's workspace 7|-M logo -k 7 -m logo
Super+8|This screen's workspace 8|-M logo -k 8 -m logo
Super+9|This screen's workspace 9|-M logo -k 9 -m logo
Super+0|This screen's workspace 10|-M logo -k 0 -m logo

Super+Shift+A|Grok Bot|-M logo -M shift -k a -m shift -m logo
Super+Shift+Ctrl+A|Grok|-M logo -M shift -M ctrl -k a -m ctrl -m shift -m logo
Super+Shift+B|Board Game Arena|-M logo -M shift -k b -m shift -m logo
Super+Shift+C|Calendar|-M logo -M shift -k c -m shift -m logo
Super+Shift+D|Discord|-M logo -M shift -k d -m shift -m logo
Super+Shift+Ctrl+D|Concord|-M logo -M shift -M ctrl -k d -m ctrl -m shift -m logo
Super+Shift+E|Thunderbird|-M logo -M shift -k e -m shift -m logo
Super+Shift+Ctrl+E|Thunderbird compose|-M logo -M shift -M ctrl -k e -m ctrl -m shift -m logo
Super+Shift+F|Yazi|-M logo -M shift -k f -m shift -m logo
Super+Shift+Ctrl+F|Google Drive|-M logo -M shift -M ctrl -k f -m ctrl -m shift -m logo
Super+Shift+G|Gmail|-M logo -M shift -k g -m shift -m logo
Super+Shift+H|Heroic|-M logo -M shift -k h -m shift -m logo
Super+Shift+I|Inkscape|-M logo -M shift -k i -m shift -m logo
Super+Shift+K|Google Keep|-M logo -M shift -k k -m shift -m logo
Super+Shift+L|Maps|-M logo -M shift -k l -m shift -m logo
Super+Shift+M|Messages|-M logo -M shift -k m -m shift -m logo
Super+Shift+N|Feedly|-M logo -M shift -k n -m shift -m logo
Super+Shift+O|LibreOffice|-M logo -M shift -k o -m shift -m logo
Super+Shift+Ctrl+O|Obsidian|-M logo -M shift -M ctrl -k o -m ctrl -m shift -m logo
Super+Shift+P|Google Photos|-M logo -M shift -k p -m shift -m logo
Super+Shift+Ctrl+P|GIMP|-M logo -M shift -M ctrl -k p -m ctrl -m shift -m logo
Super+Shift+S|Steam|-M logo -M shift -k s -m shift -m logo
Super+Shift+T|btop|-M logo -M shift -k t -m shift -m logo
Super+Shift+Ctrl+T|nvtop|-M logo -M shift -M ctrl -k t -m ctrl -m shift -m logo
Super+Shift+V|Neovim|-M logo -M shift -k v -m shift -m logo
Super+Shift+Ctrl+V|VS Code|-M logo -M shift -M ctrl -k v -m ctrl -m shift -m logo
Super+Shift+W|Chrome|-M logo -M shift -k w -m shift -m logo
Super+Shift+Ctrl+W|Lynx|-M logo -M shift -M ctrl -k w -m ctrl -m shift -m logo
Super+Shift+Y|YouTube Music|-M logo -M shift -k y -m shift -m logo
Super+Shift+Ctrl+Y|YouTube|-M logo -M shift -M ctrl -k y -m ctrl -m shift -m logo
Super+Shift+Tab|Previous workspace on this screen|-M logo -M shift -k Tab -m shift -m logo
Super+Shift+Left|Move the window left|-M logo -M shift -k Left -m shift -m logo
Super+Shift+Right|Move the window right|-M logo -M shift -k Right -m shift -m logo
Super+Shift+Up|Move up. At the top, previous workspace, even if empty|-M logo -M shift -k Up -m shift -m logo
Super+Shift+Down|Move down. At the bottom, next workspace, even if empty|-M logo -M shift -k Down -m shift -m logo
Super+Shift+minus|This window 10% shorter|-M logo -M shift -k minus -m shift -m logo
Super+Shift+equal|This window 10% taller|-M logo -M shift -k equal -m shift -m logo
Super+Shift+.|Google Tasks|-M logo -M shift -k period -m shift -m logo
Super+Shift+Return|Wallpaper color|-M logo -M shift -k Return -m shift -m logo
Super+Shift+1|Move the window to workspace 1|-M logo -M shift -k 1 -m shift -m logo
Super+Shift+2|Move the window to workspace 2|-M logo -M shift -k 2 -m shift -m logo
Super+Shift+3|Move the window to workspace 3|-M logo -M shift -k 3 -m shift -m logo
Super+Shift+4|Move the window to workspace 4|-M logo -M shift -k 4 -m shift -m logo
Super+Shift+5|Move the window to workspace 5|-M logo -M shift -k 5 -m shift -m logo
Super+Shift+6|Move the window to workspace 6|-M logo -M shift -k 6 -m shift -m logo
Super+Shift+7|Move the window to workspace 7|-M logo -M shift -k 7 -m shift -m logo
Super+Shift+8|Move the window to workspace 8|-M logo -M shift -k 8 -m shift -m logo
Super+Shift+9|Move the window to workspace 9|-M logo -M shift -k 9 -m shift -m logo
Super+Shift+0|Move the window to workspace 10|-M logo -M shift -k 0 -m shift -m logo

Alt+Shift+Tab|Recent windows, the other way|-M alt -M shift -k Tab -m shift -m alt
Alt+Escape|Cancel that switch|-M alt -k Escape -m alt
Alt+F4|Close window|-M alt -k F4 -m alt
Super+Ctrl+F|Maximize, keep the gaps|-M logo -M ctrl -k f -m ctrl -m logo
Super+Ctrl+F2|Cover the screen|-M logo -M ctrl -k F2 -m ctrl -m logo
Super+Alt+P|Turn the screens off|-M logo -M alt -k p -m alt -m logo
EOF
)

declare -A spec_of=()
key_list=()
menu=""
pad=24
while IFS='|' read -r keys desc spec; do
  [[ -z ${keys:-} ]] && continue
  printf -v line "%-${pad}s%s" "$keys" "$desc"
  menu+="${line}"$'\n'
  spec_of["$keys"]=$spec
  key_list+=("$keys")
done <<<"$rows"

choice="$(printf '%s' "${menu%$'\n'}" | fuzzel --dmenu --prompt "Keys  " --placeholder "search" --width 86 --lines 18)" || exit 0

matched=""
for keys in "${key_list[@]}"; do
  if [[ "$choice" == "$keys" || "$choice" == "$keys "* ]]; then
    if ((${#keys} > ${#matched})); then
      matched=$keys
    fi
  fi
done
[[ -n $matched ]] || exit 0
spec=${spec_of[$matched]}
[[ $spec != "-" ]] || exit 0

# Prefer a PATH install (pacman). The unpacked copy is only there
# because this session's PATH, including Hyprland's, has no ~/.local/bin.
if [[ -n ${WTYPE:-} ]]; then
  wtype_bin=$WTYPE
elif wtype_bin="$(command -v wtype 2>/dev/null)" && [[ -x $wtype_bin ]]; then
  :
elif [[ -x $HOME/.local/bin/wtype ]]; then
  wtype_bin=$HOME/.local/bin/wtype
else
  wtype_bin=""
fi
if [[ -z $wtype_bin || ! -x $wtype_bin ]]; then
  printf 'wtype is not installed, so %s cannot be typed\n' "$matched" >&2
  exit 1
fi

# The menu has to be gone, or the chord lands in Fuzzel.
sleep 0.15
read -r -a args <<<"$spec"
"$wtype_bin" "${args[@]}"
