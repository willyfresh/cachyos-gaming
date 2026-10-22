# Journal

Decisions that still shape this machine. Packages live in `packages/`.
Configs live in `configs/`. Open work lives in `records/next.md`.
`scripts/pkg-add.sh` appends new installs at the bottom.

## Session

Hyprland on CachyOS. The hostname is Novalis (Borg until 2026-09-07).
`/etc/hosts` `127.0.1.1` must say Novalis, or sudo and some local TLS break.

tty1 stays a shell. Type `start-hyprland`. Do not exec that from
`bash_profile`. SDDM is installed and disabled. Turning it on replaces
the tty login.

Ctrl+Alt+Delete opens the session list: lock, quit back to the tty,
reboot, or shut down. It does not quit on its own. Escape cancels.
Lock is the first row. Super+Shift+Q is unbound.

niri and Noctalia were removed 2026-10-15. Leave them out. If
`cachyos-niri-noctalia` shows up again, do not remove it with
`pacman -Rns`: that also tries to remove the GTK portal, gnome-keyring,
fonts, and cursors. Hyprland has its own Xwayland.

Lock is hyprlock: a blurred screenshot in Novalis green, not the live
wallpaper. hypridle locks at 10 minutes and turns the screens off at 15.
tty login does not unlock gnome-keyring. Leave that dialog.

Super alone does nothing. Super+Space opens Fuzzel. Kitty is the
terminal. Yazi is Super+E.

A full reload of `hyprland.lua` re-runs hyprsplit and moves open windows.
Turn `misc.disable_autoreload` on with `hyprctl eval` before an edit,
then turn it back off. `hyprctl keyword` does not work on this Lua config.
Saving the file is a rename, and a failed load can leave the red bar up
after `hyprctl configerrors` is already empty. `hyprctl seterror disable`
fades that bar.

## Desktop

Each screen has workspaces 1–10 (hyprsplit). DP-1 is ids 1–10, HDMI-A-1
is 11–20. Empty workspaces stay empty. Waybar sits on the bottom of both
screens. A number shows when that workspace has windows, or when it is
the active one.

Surface `#0A0D0B`, green `#5CFF6B`, text `#C8D4C8`. A focused window has
a 2px green border. Unfocused borders are transparent and those windows
are 70% opaque. The 2px stays reserved so focus does not resize them.
Windows open and close with `gnomed` at speed 3. Their opacity fades at
speed 1. Workspace changes use `slidevert` at speed 3. Speed is tenths
of a second.

The four files in `configs/hypr/wallpapers/` are one picture in four
colors, at 1920×1080, which is the size of these panels. Super+Shift+Return picks. The choice is one word in
`~/.local/state/hypr/wallpaper`, read when `wallpaper.py` starts.

Chrome webapps are title-less `--app` windows. Their profile stays at
`~/.local/share/borg/chrome-webapps` (the old hostname). Do not use
`--app-id`; that draws a title bar. PDFs open in Zathura. Images open
in swayimg. Video and audio open in VLC. In Yazi, O on a video also
lists Kdenlive. A `.kdenlive` project is `application/x-kdenlive`:
`~/.magic` matches the `kdenlive:` marker, and that type opens in Kdenlive.
Yazi drops the `x-` prefix, so its opener matches `application/kdenlive`
and `*.kdenlive`.
O on audio also lists Audacity.

A link from another app opens in the running Chrome, and that window
is focused. `configs/hyprland-mimeapps.list` sends http and https to
`launch-browser.sh`. The browser named in `mimeapps.list` stays
`google-chrome.desktop`, which Chrome and the webapp launcher read.
`chrome-flags.conf` skips the default-browser bar.

Print grabs a region, Shift+Print the focused window, Ctrl+Shift+Print
both screens. Alt+Print is SysRq and never reaches Hyprland. Shots are
copied and saved under `~/Pictures/Screenshots`. The notification and
the Fuzzel list open that file in yazi.

Clipboard history is one `wl-paste` watcher into cliphist. Super+V lists
the newest copy first, then wipe, delete, and delete-query. A picture is
stored once. The UTF-16 text Chrome offers beside it is skipped.

Fuzzel 1.15 cannot color a single row. An update that needs a reboot is
marked `reboot *`. A library a running service still has loaded is
marked `restart *`. The updates list can install every other pending
package without the reboot ones. Each row shows the download size when
it is known. After the upgrade, the terminal asks before a reboot or a
service restart. Enter means yes. A reboot is refused when the Limine
menu names a missing or mismatched file. The list is only as tall as
its rows, and it stops growing at 40.

Alt+Tab walks windows in the order you used them, on both screens, nine
on a row, and switches when Alt is released. Alt+Shift+Tab goes the other way. Alt+Esc
cancels. Super+Tab lists every window by screen, five on a row, and stays up until you
pick one or press Esc. Super+Shift+Tab is still the previous workspace.
Alt+Tab is not a submap. Super+Tab uses one named `taskview` so the
arrows work, and Waybar does not show that name. If that switcher
process has exited, it is started again.

Super+Ctrl+Left and Super+Ctrl+Right step every screen to the previous
or next workspace number, including an empty one, and stop at 1 and at
10. Super+Ctrl+Up and Super+Ctrl+Down do the same and skip numbers with
no windows. Super+Ctrl+1 through Super+Ctrl+0 moves every screen to that
number together. 0 is 10. Super+number still follows the focused screen only.
Super+scroll changes to the next or previous occupied workspace on this
screen. Super+Shift+scroll moves the focused window one workspace number
on this screen, including an empty one, and follows it.
Super+D opens the next empty number on the focused screen.
Super+U opens the update list. Super+Shift+U focuses VLC, or starts it.
Video and audio open in VLC. Super+Alt+M opens now playing.
Super+. picks an emoji and types it. The menu keeps a name only when it
contains what you typed, then sorts those hits. A loose match does not
sit on the first row. With nothing typed, the list stays in emoji order.
Super+Mic starts hyprwhspr and stops it. The mic key alone still mutes.
A mic overlay shows while it is listening. hyprwhspr does not grab the
keyboard, so keyd keeps the mic key. It listens with faster-whisper
large-v3-turbo on the NVIDIA card, and starts with the Hyprland session.
Super+Alt+Mic unloads that model and loads it again. The mic readout
turns red while the model is off the GPU.

## Packages

Repo names go in `packages/extra.txt`. AUR names go in `packages/aur.txt`.
`packages/baseline/` is the day-0 explicit set and still lists
`cachyos-niri-noctalia`. Leave that snapshot alone.

Do not install Feral GameMode. `ananicy-cpp` already sets niceness. Use
`game-performance`. `wine-mono` is the distro package. Skip Wine's own
mono installer.

`lsfg-vk` is not a pacman package. The 2.0.0 tree lives under `~/.local`.
Profiles are `configs/lsfg-vk/conf.toml`. `DISABLE_LSFGVK=1` turns the
layer off. `valvefm` is a manual binary at `/usr/local/bin/valvefm`, not
in the package lists.

LazyVim is `configs/nvim`, linked at `~/.config/nvim`. Plugin downloads
stay in `~/.local/share/nvim`.

## Removed

Screensavers, the falling-code catalog, Matrix rain on the lock, and an
SDDM greeter were tried and dropped. The lock stays the blurred
screenshot. The WebKit Board Game Arena window was replaced by the
Chrome webapp. GNU Stow was considered and left as a note in
`records/next.md`.

## 2026-10-19 — installed tailscale

- requested: tailscale
- repos (pacman): tailscale
- AUR (paru): (none)

## 2026-10-21 — installed gtk4-layer-shell wtype hyprwhspr

- requested: gtk4-layer-shell wtype hyprwhspr
- repos (pacman): gtk4-layer-shell wtype
- AUR (paru): hyprwhspr

## 2026-10-21 — installed kdenlive

- requested: kdenlive
- repos (pacman): kdenlive
- AUR (paru): (none)

## 2026-10-21 — installed audacity

- requested: audacity
- repos (pacman): audacity
- AUR (paru): (none)

## 2026-10-21 — installed lmms

- requested: lmms
- repos (pacman): lmms
- AUR (paru): (none)
