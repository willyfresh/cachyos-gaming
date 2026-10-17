# Journal

A running record of installs and config changes. Package names that should survive a reinstall also live in `packages/extra.txt`. Config diffs live in git.

## 2026-10-09 — installed kitty

- requested: kitty
- repos (pacman): kitty 0.49.2-1.1
- Concord image previews use the terminal graphics protocol. Alacritty
  falls back to block characters. Run `concord` inside kitty.
  Super+Return stays Alacritty.

## 2026-10-08 — installed the terminal apps

- requested: superfile concord lynx neovim caligula neomutt valvefm steam-tui
- repos (pacman): superfile 1.6.0-1.1, lynx 2.9.3-1.1, neovim 0.12.5-1.1,
  caligula 0.5.0-1.1, neomutt 1:20260616-1.1
- AUR (paru): concord-bin 2.6.1-1, steam-tui 0.3.0b-6
- steam-tui pulled `steamcmd` latest-7. Run `steamcmd` once before the
  first `steam-tui`. `rustup` 1.29.1-1.1 stayed behind as an explicit
  package from the build.
- valvefm 0.1.8 is the TUI-only GitHub binary at `/usr/local/bin/valvefm`.
  sha256 `ae3cf99eb759a268031b66ed3b12d25465bd85e7221ddec07ec9ee15b6496703`.
- The first pacman attempt 404'd `libutf8proc` 2.11.3-1.1. A database
  sync moved it to 2.12.0-1.1 and the install went through.
- No keybinds. Commands: `spf`, `concord`, `lynx`, `nvim`, `caligula`,
  `neomutt`, `valvefm`, `steam-tui`.

## 2026-10-07 — Super alone does nothing

- keyd no longer maps a Super tap to Super+Space, and it no longer
  grabs the mouse. Super+Space is still the launcher. Keychron media
  and knob maps are unchanged. Delorean was left alone.
- A half-width default for new windows was tried the same day and
  taken back. niri stays on the scrolling strip. Noctalia settings
  and btop still float. Board Game Arena still opens maximized.

## 2026-10-07 — Nautilus bookmarks for household shares

- Installed `gvfs-smb` 1.60.3-3. Pacman also upgraded `gvfs` from
  1.60.2-4 to 1.60.3-3. Recorded in `packages/extra.txt`.
- `~/.config/gtk-3.0/bookmarks` now has Will, Ally, Bexley, and Conway
  on `smb://10.82.64.4/`. Guest mount and a directory listing succeeded
  for each share. Conway's share is empty.

## 2026-10-01 — installed vlc

- requested: vlc
- repos (pacman): vlc
- AUR (paru): (none)
- versions: vlc 3.0.23_2-16.1
- `vlc-plugins-all` was already installed. This pull added
  `vlc-gui-qt` and the Qt5 libraries it needs.

## 2026-09-26 — overview hot corner off

- niri's top-left hot corner toggled the overview. `gestures {
  hot-corners { off } }` in `configs/niri/cfg/misc.kdl`. Super+Tab
  still opens the overview.

## 2026-09-26 — bar clock shows the date

- `[widget.clock] format = "{:%a %m-%d  %H:%M}"` in
  `configs/noctalia/config.toml`. Abbreviated weekday, numeric
  month-day, then 24-hour time. Example: `Sat 09-26  14:26`.

## 2026-09-26 — installed obsidian bitwarden

- requested: obsidian bitwarden
- repos (pacman): obsidian bitwarden
- AUR (paru): (none)
- versions: obsidian 1.13.7-2, bitwarden 2026.3.1-2.1
- First attempt 404'd `electron43` 43.7.0 because the sync databases
  were stale. `pacman -Sy` got `electron43` 43.7.5-1 and the install
  finished. Vault stays at `~/Projects/Obsidian-Vault`. Signed in
  the same day. The Bitwarden browser extension was left in place.

## 2026-09-26 — Thunderbird mailboxes and bar network label

- Gmail (`willyfresh@gmail.com`) was already in Thunderbird. Added
  DreamHost IMAP for `will@billcompany.net`, `email@willyfresh.com`,
  and `will@willfloyd.com` (`imap.dreamhost.com:993`,
  `smtp.dreamhost.com:465`, normal password). Folder pane is the
  unified (smart) inbox. Passwords are not stored in git; Thunderbird
  asks for the three DreamHost passwords on connect.
- Bar network widget: `show_label = false` in
  `configs/noctalia/config.toml`. The glyph stays.

## 2026-09-22 — Super+Shift+H I S P

- Super+Shift+H Heroic. Super+Shift+I Inkscape. Super+Shift+S Steam
  (toasts skipped). Super+Shift+P GIMP.
- Settings stay on Super+I. Monitor power moved to Super+Alt+P.
  Alt was already the monitor modifier.

## 2026-09-22 — Super+Shift+D W M L Y O

- Super+Shift+D Discord (`launch-discord.sh`).
- Super+Shift+W focuses the main Chrome (`app-id` google-chrome) or
  launches it. Webapps stay on their own chords.
- Super+Shift+M is Google Messages. Maps moved to Super+Shift+L.
  Super+Shift+Ctrl+G no longer opens Messages.
- Super+Shift+Y is YouTube Music first. Pressed while Music is focused,
  it goes to YouTube, and the other way around.
- Super+Shift+O is LibreOffice (`libreoffice-fresh`).

## 2026-09-22 — Super+Shift+letter apps

- Same Delorean chords, focus or launch: Super+Shift+C Calendar,
  E Thunderbird, Alt+E compose, G Gmail, Ctrl+G Messages, M Maps,
  Y YouTube. Super+Shift+B was already Board Game Arena.
- VS Code is Super+Shift+T. Delorean uses bare Super+T; that key still
  toggles floating here.
- YouTube is a title-less Chrome app (`configs/applications/youtube.desktop`).
  Native apps go through `scripts/launch-or-focus-app.sh`.
- Left alone: Super+M maximize-to-edges (Delorean's YouTube Music),
  Super+D unbound (Delorean's Discord), Super+Shift+D unbound
  (Delorean's Docker), Super+Shift+Return wallpaper
  (Delorean's Messages).

## 2026-09-22 — Super+A / I / N / W

- Super+A toggles the control center (Super+S still does too).
- Super+I toggles Noctalia settings (Super+Shift+S still does too).
- Super+N toggles notification history (Keychron circle still does too).
- Super+W toggles the weather tab. It used to toggle a tabbed column.
- Super+B (Firefox) and Super+D (Discord) are unbound. Super+Shift+B
  is still Board Game Arena.
- `[weather] enabled = true` in `configs/noctalia/config.toml`.

## 2026-09-22 — tty1 stays a shell

- This morning's `exec niri-session` in `configs/bash_profile` never
  reached the compositor. `niri-session` re-execs a login shell so it
  can read `bash_profile`, and that file exec'd `niri-session` again.
  tty1 sat in that loop (getty and Plymouth were fine). Login on tty3
  and `niri` from that shell is the session in use now.
- Auto-start is off. Next tty1 login is a prompt. Start the desktop
  with `niri-session`, not bare `niri`, so systemd still learns the
  Wayland display and Chrome's file chooser works.
- Stopped the stuck tty1 shell (pid 720). Getty is back on tty1.
  `niri.service` was inactive; the live compositor is the one on tty3.

## 2026-09-22 — Chrome file picker opens nothing

- Clicking "pick a file" in Chrome calls `xdg-desktop-portal`. The GTK
  backend was crash-looping: `cannot open display`, then
  `start-limit-hit`. systemd's user environment had no `WAYLAND_DISPLAY`
  or `DISPLAY` because tty1 runs `exec niri` instead of `niri-session`.
  `graphical-session.target` was dead, so the GNOME portal would not
  start either.
- This session: imported `WAYLAND_DISPLAY=wayland-1` and `DISPLAY=:0`
  into the user manager and restarted the portal. Did not start
  `graphical-session.target` (that would launch a second
  `xwayland-satellite` on top of the one niri already spawned).
- Next login: `configs/bash_profile` is `exec niri-session`, and
  `apply-configs.sh` symlinks that over `~/.bash_profile`.
  `spawn-sh-at-startup` in `configs/niri/cfg/autostart.kdl` imports the
  same variables if niri is ever started without the session wrapper.
- File chooser is pinned to the GTK portal in
  `configs/xdg-desktop-portal/niri-portals.conf`. The stock niri config
  prefers the GNOME portal, which needs `graphical-session.target` and
  was failing the request before GTK could draw anything. Screencast
  stays on the GNOME portal.
- The GTK dialog was tiling into the next column, unfocused, so it
  still looked like nothing opened. `rules.kdl` floats it, focuses it,
  and sizes it 920×640.

## 2026-09-02 — bootstrap this repo

- Created `~/Projects/cachyos-gaming` and initialized git.
- Snapshotted the stock CachyOS niri + noctalia configs into `configs/`.
- Snapshotted explicitly installed packages (168) into `packages/baseline/`.
- Linked `~/.config/niri` and `~/.config/noctalia` to this repo.
- No extra packages yet. `packages/extra.txt` is empty on purpose.

## 2026-09-02 — Google Chrome and VS Code

- Installed `paru` from the CachyOS repos (AUR helper). Recorded in `packages/extra.txt`.
- Installed AUR packages (recorded in `packages/aur.txt`):
  - `google-chrome` 152.0.7977.75-1 (Google does not allow it in the repos)
  - `visual-studio-code-bin` 1.136.0-1 (official Microsoft VS Code with marketplace; repo `code` is Code OSS)
- `setup.sh` / `pkg-add.sh` now install repo extras via pacman and AUR extras via paru.
- Launchers: `google-chrome-stable` and `code`. Custom flags live in `~/.config/chrome-flags.conf` and `~/.config/code-flags.conf` if we need them later.

## 2026-09-02 — Super tap opens the launcher

- Stock CachyOS bind is Super+Ctrl+Enter (`Mod+CTRL+Return`). Kept as a fallback.
- Bound Super+Space to `noctalia msg panel-toggle launcher`.
- Installed `keyd` so tapping Super sends Super+Space (hold Super still works as a modifier).
- keyd config lives in `configs/keyd/default.conf` and is installed to `/etc/keyd/default.conf` by `scripts/apply-system.sh`.

## 2026-09-02 — swap the two VE247s in software

- Stock automatic layout had HDMI-A-1 (serial C5LMQS118094) on the left and DP-1 (K1LMQS100417) on the right.
- Explicit positions in `configs/niri/cfg/display.kdl`: DP-1 at x=0 (left), HDMI-A-1 at x=1920 (right), both 1920×1080@60.
- Outputs are adjacent, so the cursor can move across the bezel. Niri still keeps a separate workspace strip per monitor (not one giant canvas).

## 2026-09-02 — gaming stack

- NVIDIA already healthy: driver 610.57.04, Vulkan 1.4, `lib32-nvidia-utils`, ntsync loaded. No driver work needed.
- Installed `cachyos-gaming-meta` (proton-cachyos-slr, umu-launcher, wine-cachyos-opt, winetricks, protontricks, vulkan-tools), `steam`, `heroic-games-launcher-bin`, `mangohud`, `lib32-mangohud`, `gamescope`, `goverlay`.
- Did not install GameMode (`ananicy-cpp` is already running) or Lutris.
- NVIDIA shader cache raised to 12 GB via `configs/environment.d/gaming.conf` and niri `environment`.
- Notes: `records/gaming.md`.

## 2026-09-02 — Steam menus flash and close

- Steam client update (2026-09-01) + niri/xwayland-satellite: dropdowns appear for a frame then vanish.
- Stop clipping Steam windows (`clip-to-geometry false`), min-size empty-title popups, launch with `-cef-disable-gpu-compositing` via a user steam.desktop override.

## 2026-09-03 — Halo Infinite launch options

- AppID 1240440 on `/mnt/tb1/SteamLibrary` was exiting instantly: leftover `gamemoderun` in launch options, and GameMode is not installed.
- Replaced with `game-performance`, kept NVIDIA `VKD3D_DISABLE_EXTENSIONS=VK_NV_device_generated_commands_compute`.
- Forced compatibility tool to `proton-cachyos-slr` for Easy Anti-Cheat.

## 2026-09-03 — Halo Infinite Xbox Live login

- NTP was off (`systemd-timesyncd` disabled). Xbox Authentication Library had ~3h of clock skew in `XalClockSkew.json`. Enabled timesyncd.
- Xbox login popup is a Steam CEF web view. Dropped `-cef-disable-gpu-compositing` and set `GPUAccelWebViewsV3=1`.
- Cleared Wine `Xbl|DeviceKey` credentials in the Halo prefix (sign-in loop leftover).

## 2026-09-03 — Halo Xbox sign-in window not clickable

- Sign-in is Steam overlay on a niri-fullscreen game, so clicks never reach it. Stopped auto-fullscreen for `steam_app_1240440`.
- Disabled Xalia (`PROTON_USE_XALIA=0`); two `xalia.exe` processes were running over the login UI.

- Xbox sign-in is a Steam window titled **Steam Big Picture Mode** (1280×800). Halo was covering it; keep that window focused and on the left (primary) monitor.

## 2026-09-03 — Discord

- Installed `discord` 1:1.0.156-1 from extra. Recorded in `packages/extra.txt`.

## 2026-09-03 — Board Game Arena hides its title bar

- Chrome PWAs always draw their own **title bar** (CSD) and, when the page is out of the app scope, a gray **custom tab bar** (page title, URL, close). niri cannot strip those; exclusive fullscreen also does not.
- Replaced the Chrome PWA window with `scripts/board-game-arena`: a GTK4/WebKit window with no title bar, no URL bar, no close strip. Login is stored under `~/.local/share/board-game-arena/` (separate from Chrome, so sign in once).
- Installed `webkitgtk-6.0`. Existing Board Game Arena launchers now run this wrapper.

## 2026-09-03 — Super+arrows / Super+scroll

- Super+Left/Right: focus columns (windows). Super+Up/Down: workspaces. Super+H/L still columns; Super+J/K still stacked windows in a column.
- Super+scroll left/right: columns. Super+scroll up/down: workspaces. Super+Ctrl+scroll: workspaces (mice without tilt-wheel).
- Super+Shift on those same keys/scrolls **moves** the window along that axis.
- Displaced: Super+Shift+arrows used to focus the other monitor. That is now Super+Alt+arrows. Super+Ctrl+Shift+arrows still move a column to the other monitor.

## 2026-09-03 — Super modifiers: Ctrl workspace, Alt monitor, Shift move

- Super+arrows still focus (Up/Down = workspaces without Ctrl). Ctrl = workspace, Alt = monitor, Shift = move. Combos like Super+Shift+Alt+Left move a window to the other screen; Super+Shift+Ctrl+Alt+Left moves the whole workspace over.
- Super+scroll: windows. Super+Ctrl+scroll: workspace. Super+Alt+scroll: monitor. Shift still moves.
- Super+Tab opens overview. Alt+Tab is niri's recent-windows switcher. Super+Shift+Tab is previous workspace (what Super+Tab did before). Super+O still toggles overview.
- Super+Alt+L stays lock.

## 2026-09-04 — Super+K keybind cheatsheet

- Enabled Noctalia plugin `kenn/keybind-cheatsheet` (searchable list of live niri binds, like Omarchy Super+K).
- Super+K toggles it. Super+Shift+Escape still opens niri's short Important Hotkeys overlay.
- Super+K used to focus the window above in a stacked column; Super+J still focuses down. Super+Shift+K still moves a stacked window up.

## 2026-09-04 — drop duplicate keybinds

- Super+Up/Down now `focus-window-or-workspace` (stacked window first, then workspace). Super+Shift+Up/Down move the same way.
- Removed vim HJKL aliases of the arrows, Super+Ctrl+1–9 (Shift+1–9 still moves), Super+O (Super+Tab is overview), and Super+Ctrl+Return (Super+Space / Super tap is the launcher).
- Super+scroll still maps vertical ticks to windows so a mouse without a tilt-wheel works.

## 2026-09-04 — notes workflow (records, not docs)

- Same loop as omarchy-delorean: dump in `os-notes.txt`, triage into
  `records/next.md`, empty the inbox. Done work stays in journal / gaming /
  hardware.
- Super+V opens Noctalia clipboard history (`noctalia msg panel-toggle clipboard`).
  Super+Shift+V still toggles floating vs tiling.
- `focus-follows-mouse max-scroll-amount="0%"` so a mouse overshoot at a
  screen edge does not swap the next fullscreen/maximized column. Confirm
  in `records/next.md`.

## 2026-09-04 — wine-mono for Heroic / For Honor

- Heroic's Wine version is system `wine-11.16` (`/usr/bin/wine`), not Proton.
- Installed distro `wine-mono` 11.3.0-1.1 so Wine uses `/usr/share/wine/mono`
  instead of the per-prefix WineHQ bootstrap dialog. Recorded in
  `packages/extra.txt`. Skip Wine's Install button.

## 2026-09-04 — For Honor Ubisoft Connect hang

- wine-11.16 launched Connect (`uplay://launch/569`) then stuck in CEF
  (upc.exe ~35% CPU, no further launcher log after "Client launched").
- Switched Sundrop to `proton-cachyos-slr` (umu). Backed up the hung
  Connect `http2` CEF cache. Stopped the wine prefix.

## 2026-09-04 — For Honor still on wine-11.16

- Next Play still launched `/usr/bin/wine`. Heroic has been running since
  Sep 2 and keeps game Wine settings in memory; editing
  `GamesConfig/Sundrop.json` does not apply until Quit (tray) + reopen, or
  the game's Wine dropdown is changed in the UI.
- Stopped the hung `upc.exe`. Added `WINEDLLOVERRIDES=libglesv2.dll=d`
  (known Connect CEF hang workaround). niri rule: `upc.exe` no clip.

## 2026-09-04 — Borg rice

- Custom Noctalia palette `Borg` (gunmetal + `#5CFF6B` energy green). Bar
  **Assimilate** is square-cornered with a `BORG` hostname chip. Windows
  dropped the 20px radius; active border is the green, idle is dark metal.
- Wallpapers in `configs/noctalia/wallpapers/`: cube, regeneration alcoves,
  charging station, and `RESISTANCE IS FUTILE` (text burned in with
  Liberation Sans so the words stay exact). Super+Shift+Return cycles them.
- Bar `BORG` chip replaced the launcher button; left-click toggles the
  launcher (`panel-toggle launcher`). Super+Space / Super tap still do too.
- Focused window gets the energy-green ring and border (focus-ring was
  off, so only idle metal edges showed). `draw-border-with-background false`
  so the edge sits around opaque clients.

## 2026-09-04 — Splitgate: Arena Reloaded

- AppID 2918300 on `/mnt/tb1/SteamLibrary`. Instant exit: Steam launched
  the Windows `PortalWars2.exe` as native Linux. Forced
  `proton-cachyos-slr`, launch options `game-performance %command% -windowed`.
- niri rule: no exclusive fullscreen. Servers are P2P as of 2026-09-03.

## 2026-09-06 — keybinds.md

- `records/keybinds.md`: Super-key chords by letter for Windows 11, this
  niri box, and the Delorean overlay.

## 2026-09-06 — Super+D Discord, Super+L lock

- Super+D focuses the native Discord client, skipping the updater splash
  (`scripts/launch-discord.sh`). Super+L locks (noctalia); Super+Alt+L
  still does too. Remaining Super-letter app keys wait on a Windows pass.

## 2026-09-06 — Super+Ctrl+Alt+scroll up = bigger

- Wheel up widens the column 10%, down thins it. Tilt left/right unchanged.

## 2026-09-06 — Super+Ctrl+Alt size, Super+drag, windowed fullscreen

- Super+Ctrl+Alt+arrows/scroll resize the focused column/window by 10%.
  Left/Right (and the wheel) are width; Up/Down are height. Super+/- is
  still `set-column-width ±10%` — not Omarchy's left-edge resize.
- Super+Ctrl+F is niri `toggle-windowed-fullscreen` (site chrome off,
  tile stays). Old expand-column bind moved to Super+Alt+F.
- keyd lists the Glorious Model D and Keychron V6 pointer so Super+click
  counts as a hold. `overload_tap_timeout = 200` so a Super-hold does not
  fire the launcher on release. Super+left-drag moves windows again.

## 2026-09-06 — Chrome --app webapps on Borg

- Ported Delorean's persistent `--app=URL` launcher. Profile:
  `~/.local/share/borg/chrome-webapps`. Scripts: `launch-webapp.sh`,
  `launch-or-focus-webapp.sh`, `collapse-webapp-profile.sh`.
- Board Game Arena Super+Shift+B and the old Chrome PWA desktop file now
  use that launcher. WebKit wrapper stays in the repo unused.
- Launcher entries: Gmail, Messages, Maps, Calendar, YouTube Music.

## 2026-09-07 — Novalis

- Hostname is Novalis (Tirant's hovercraft, Zion dock pad 4).
  `scripts/apply-system.sh` runs `hostnamectl set-hostname Novalis` and
  rewrites `/etc/hosts`. Needs sudo in a real terminal.
- Palette file is `configs/noctalia/palettes/Novalis.json` (same gunmetal
  + `#5CFF6B`). Bar chip is `NOVALIS` and still opens the launcher.
- Wallpapers: digital rain, hull in the tunnels, Zion dock, construct
  street. Super+Shift+Return cycles them. Old cube/alcove stills live in
  `configs/noctalia/archive-borg-wallpapers/`.
- Screensaver: AUR `niri-screensaver`, TTE effects matrix/rain/decrypt,
  Novalis wordmark, both monitors mirrored. Idle 150s screensaver, 300s
  lock. `pkg-add` still needs sudo.
- Chrome webapp profile stays at `~/.local/share/borg/chrome-webapps`.

## 2026-09-07 — Novalis screensaver sequence + lock

- Custom inner driver (`scripts/novalis-screensaver`): flower grows
  (pour up) through a thunderstorm, decrypts into the NOVALIS wordmark,
  flickers, then the outer ASCII peels into a matrix-rain tunnel
  (`scripts/novalis-tunnel.py`). Loops without the old 8s random cuts.
- Super+L and idle lock run `scripts/lock.sh`: start the saver, then
  Noctalia lock with a desktop snapshot (`blurred_desktop`, no blur) so
  the lock background is the animation.

## 2026-09-07 — more wallpapers

- Added eight stills to the Super+Shift+Return loop: close title-sequence
  rain, code skyline, phone booth, operator core, cockpit down the
  tunnel, pad hero, broadcast depth, and the blue flower in the rain
  (Novalis the poet). Default wallpaper is still digital rain.

## 2026-09-07 — floating btop, Grok Bot, drop BORG chip

- Super+Ctrl+T opens a floating Alacritty running btop (`app-id=btop`,
  ~55%×65%, centered). Press again while it is focused to close it;
  otherwise the key focuses the existing window. Script:
  `scripts/launch-btop.sh`. Same chord as Omarchy Activity.
- Super+Shift+Alt+A focuses or launches the Grok Bot desktop app
  (`scripts/launch-grok-bot.sh`). Package is recorded as AUR
  `grok-bot-bin`; live install still needs
  `./scripts/pkg-add.sh grok-bot-bin` in a real terminal (sudo). Same
  chord as Delorean Grok.
- Bar **Assimilate** dropped the `BORG` chip for a few hours; the
  Novalis nameplate replaced it the same day.

## 2026-09-04 — table For Honor

- proton-cachyos-slr/umu did run (`upc.exe` + WebCore + xalia) but no
  window. Killed the leftover tree. Tabled with Halo / BGA.

## 2026-09-07 — installed niri-screensaver grok-bot-bin

- requested: niri-screensaver grok-bot-bin
- repos (pacman): (none)
- AUR (paru): niri-screensaver grok-bot-bin

## 2026-09-08 — screensaver vs lock split

- Idle is screensaver only (150s). `[idle.behavior.lock]` disabled, so
  idle never locks.
- Super+L is a normal lock: `scripts/lock.sh` kills any saver, then
  Noctalia session lock (wallpaper + password). niri cannot play a live
  saver over the lock. Lid close / suspend still locks.

## 2026-09-08 — screensaver day-of-year + countdowns

- `scripts/novalis-clock.py` prints one-line facts: until Bex is 18
  (born 2017-11-07), years left of the current decade (40s now), until
  65, until 90. Day-of-year was dropped the same day. No snowboarding
  timer.
- Rain never stops (`scripts/novalis-rain.py`). A cell scrambles for
  4–7 rain-head hits (digits cycle 0–9) then locks white. After the
  hold, locked glyphs dissolve downward into the rain (fact and logo).
  Flower and tunnel dropped.

## 2026-09-15 — installed thunderbird inkscape gimp

- requested: thunderbird inkscape gimp
- repos (pacman): thunderbird inkscape gimp
- AUR (paru): (none)
- versions: thunderbird 155.0.1-1.1, inkscape 1.4.4-6.1, gimp 3.2.6-1.1
- `mirror.krfoss.org` had the suitesparse package but 404'd the
  `.sig`; pacman aborted instead of trying the next mirror. That
  Server line is commented in `/etc/pacman.d/cachyos-v3-mirrorlist`
  and `cachyos-mirrorlist`. Cached thunderbird 154 failed its
  signature; sync DBs were stale (local 154, mirrors 155).

## 2026-09-09 — Keychron circle / triangle / square

- Circle / triangle / square were dead: keyd uinput drops F13–F24
  (same as Fn+F8/F18). keyd now maps F13–F17/F20 to Ctrl+Shift+F1–F6.
  niri: F1 light, F2 notifs, F3 Grok, F4 Steam/Heroic, F6 mic mute.
  X (F17→Ctrl+Shift+F5) still unassigned.

## 2026-09-09 — Keychron V6 Windows special keys

- Fn+F8 play/pause: Chrome MPRIS needs hardware media-key handling, but
  HID Play is resume-only. VIA sends F18; keyd turns F18/Play into
  Ctrl+Shift+F8 (keyd uinput drops F13–F24). niri Ctrl+Shift+F8 =
  `noctalia msg media toggle`.
- Fn+F4 six-pack: VIA remaps Win-Fn F4 from Super+E to Super+Space
  (launcher). Super+E stays files.
- Knob cluster (crop, mic, light, circle, triangle, square, X): stock
  Windows layer was Print / none / RGB / empty. VIA writes Print, F20,
  F13–F17. niri Print = region screenshot, F20 = mic mute, F13 =
  control center; F14–F17 captured until assigned.
- `scripts/keychron-v6-via.py` plus udev
  `configs/udev/99-keychron-v6-via.rules`. apply-system.sh installs.

## 2026-09-08 — Super+F maximize on both machines

- Novalis Super+F was already `maximize-column`; left it.
- Delorean overlay: Super+F toggles maximize (`mode = "maximized"`)
  instead of exclusive fullscreen. Super+Ctrl+F / Super+Alt+F /
  Super+Shift+F unchanged. Needs `hyprctl reload` on Delorean.

## 2026-09-08 — installed dropbox

- requested: dropbox
- repos (pacman): (none)
- AUR (paru): dropbox
- Autostart: `spawn-at-startup "dropbox" "start" "-i"` in
  `configs/niri/cfg/autostart.kdl`. Sign in on first run.

## 2026-10-09 — installed hyprland xdg-desktop-portal-hyprland

- requested: hyprland xdg-desktop-portal-hyprland
- repos (pacman): hyprland xdg-desktop-portal-hyprland
- AUR (paru): (none)

## 2026-10-09 — Hyprland config beside niri

- packages: hyprland, xdg-desktop-portal-hyprland
- config: configs/hypr/hyprland.lua (dwindle). Noctalia is not started.
- portal: configs/xdg-desktop-portal/hyprland-portals.conf
- from the tty prompt type start-hyprland. type niri for the other session.
- Super+Shift+Q quits Hyprland. Do not run both compositors at once.

## 2026-10-09 — Hyprland bar

- waybar 0.15.0-3.1, recorded in `packages/extra.txt`. playerctl came
  along as a dependency.
- config: `configs/waybar`, linked at `~/.config/waybar`. Starts with
  Hyprland. Bottom of both VE247s, 36px, windows leave that strip
  (`reserved` bottom 36).
- Novalis colors. Left: `NOVALIS`, then that screen's workspace
  numbers. Center: `Fri 10-09  14:32`. Right: the playing track, tray,
  network icon, bluetooth, volume. Click a number to show that
  workspace. Click the track to pause. Click the volume to mute.
  Scroll the volume.
- No bluetooth adapter, so that chip stays hidden. The hostname chip
  does not open a launcher. Launcher, lock, clipboard, and control
  center stay on niri.

## 2026-10-09 — Hyprland monitors match the desk

- Auto layout had HDMI-A-1 (`C5LMQS118094`) on the left and DP-1
  (`K1LMQS100417`) on the right. That is the reverse of the desk, and
  of `configs/niri/cfg/display.kdl`.
- `configs/hypr/hyprland.lua` now places DP-1 at 0,0 and HDMI-A-1 at
  1920,0, matched by serial.

## 2026-10-09 — transparent bar, focus by opacity

- Waybar has no plate and no green edge. Text and icons sit on the
  background. The current workspace number is green.
- Window borders are off (`border_size = 0`). The focused window is
  solid. Any other window is 70% opaque. A fullscreen window stays
  solid.

## 2026-10-09 — stock Waybar, Fuzzel launcher

- The custom bar stopped. `configs/waybar` is the package default
  (`/etc/xdg/waybar`), with Hyprland modules where the default names
  Sway. Scratchpad, the media script, and the power menu are left out.
  They need files this install does not have.
- Super+Space runs `fuzzel`. `otf-font-awesome` supplies the stock icons.
- The bar sits on the bottom of the right screen only (`HDMI-A-1`).
  The left screen has no bar.
- The bar lists workspaces 1–10 from both screens. A workspace still
  belongs to one monitor.

## 2026-10-09 — each screen has its own workspaces

- Tried hyprsplit so each monitor would have workspaces 1–10. It moved
  both open windows onto the left screen and left the right screen
  empty. Taken back the same day. hyprsplit is not loaded.
- Bars are on the bottom of both screens again. Each bar lists the
  workspaces on that screen.

## 2026-10-09 — fall fractal wallpaper

- `configs/hypr/wallpapers/fall-fractal.png` is a Julia set in
  burgundy, rust, and gold on a near-black field. `wallpaper.py`
  puts it on the background layer of both screens at Hyprland start.

## 2026-10-09 — separate workspace pools, occupied numbers only

- hyprsplit again (`configs/hypr/hyprsplit`, commit 6b00b677). Each
  screen has workspaces 1–10. Left DP-1 is ids 1–10. Right HDMI-A-1
  is ids 11–20. Super+number follows the focused screen.
- YouTube was moved to the right screen's 1 (id 11) before the split
  loaded, so it stayed on HDMI. The terminal stayed on the left
  screen's 2.
- Bars stay on the bottom of both screens. A number is drawn only
  while that workspace has a window. Empty workspaces are not pinned.

## 2026-10-09 — transparent bar, shared keys

- Waybar's plate is fully transparent. The stock module colors stay.
  A focused Chrome or terminal window no longer paints the bar black.
- Super+K opens a searchable key list in Fuzzel. Noctalia stays off,
  so this is not the niri cheatsheet panel.
- Also shared with niri: Super+/- resizes by 10% of the screen,
  Super+Shift+/- changes height, Super+Ctrl+F maximizes,
  Super+Shift+Tab goes to the previous workspace on this screen,
  and Alt+Tab cycles windows while Alt is held.

## 2026-10-09 — Alt+Tab no longer labels the bar

- Waybar's stock hyprland/submap module prints the active key mode.
  Alt+Tab entered a mode named alt-tab. A quick tap let Alt go before
  that mode was listening for the release, so the session stayed in
  the mode and the bar kept saying alt-tab.
- Alt+Tab and Alt+Shift+Tab are ordinary binds now. The submap module
  is not on the bar. `hyprctl submap` reports default.

## 2026-10-09 — fall wallpaper, closer and brighter

- Replaced `configs/hypr/wallpapers/fall-fractal.png`. It is 3840x2160,
  cropped into the curled fronds of a Julia set. Crimson, pumpkin, and
  gold fill the frame. The near-black field is gone. `wallpaper.py`
  still scales it onto both screens. Restarted that process so the new
  file is the one on the background layer.

## 2026-10-09 — fractal wallpaper colors

- No redraw. The fall picture was recolored into three more files
  beside it: greens (pine through mint), sky (sky blue to white), and
  relaxing (slate, sage, and sand).
- Super+Shift+Return opens the list in Fuzzel, same chord as niri's
  wallpaper picker. Noctalia stays off. The choice is stored in
  `~/.local/state/hypr/wallpaper`. Fall stays up until one is picked.

## 2026-10-12 — Limine menu no longer names the missing initramfs

- The 2026-10-12 update of limine-entry-tool writes the initramfs under
  `/boot/<machine-id>/<kernel>/initramfs` and stops leaving
  `initramfs-linux-cachyos.img`. The menu's first lines still named
  those files. A live ISO added the hashed entries that actually boot.
- `/boot/limine.conf` now keeps only those hashed entries. The CachyOS
  entry carries `comment: machine-id=b86a0f2b3c2040cfa953e5858a0e8cc6`
  so the next update edits that entry. Default boot is the LTS kernel
  this session is running. Backup:
  `/boot/limine.conf.bak-before-img-fix`.
- `scripts/check-limine-boot.sh` checks every `boot():` path, including
  its BLAKE2b hash. Pacman runs it from
  `/etc/pacman.d/hooks/99-limine-boot-files.hook` after a kernel update.

## 2026-10-09 — Fuzzel opens terminal apps in Alacritty

- Neovim's desktop entry is `Terminal=true`. Fuzzel's terminal command
  stays empty unless `$TERMINAL` is set, and this Hyprland session does
  not set it. Fuzzel then execs `nvim` with stdin on `/dev/null`, so
  picking Neovim in the launcher does nothing.
- `configs/fuzzel/fuzzel.ini` sets `terminal=alacritty -e`. Live path is
  `~/.config/fuzzel`.
- Superfile had no desktop entry, so the launcher could not list it.
  `configs/applications/superfile.desktop` runs `spf` in that same
  terminal.

## 2026-10-09 — triaged the Hyprland notes

- Inbox emptied into `records/next.md`. Nothing in the dump was
  started.
- croft instead of neovim. Waybar: drop the top border, language,
  and the power profile. The clock should show the date and the
  time together. The eye is the idle inhibitor.
- The Keychron knob and volume keys do nothing on Hyprland. Those
  binds live on niri and call Noctalia. keyd is already running
  and already maps the keys.
- The keyring prompt is the tty login. gnome-keyring is running,
  and the login password never unlocks it.

## 2026-10-12 — Super+Up/Down continues onto the next workspace

- Super+Up and Super+Down still move focus in the dwindle tree.
  When that focus does not change, Up goes to the previous occupied
  workspace on this screen and Down goes to the next one.
- Super+Left/Right stay on this workspace. Super+Shift+arrows still
  move the window inside the tree.
- hyprsplit sorts the occupied workspaces by id before e+1 and e-1,
  so those steps follow the numbers on the bar.
- Hyprland wraps focus at the edge, so two windows made Up/Down
  bounce and never leave. Up from the top window, and Down from the
  bottom window, now go to the workspace. A window further that way
  is one whose center is above or below.

## 2026-10-12 — niri media keys on Hyprland

- Volume, mute, mic mute, play/pause, next, and previous now talk
  to PipeWire and playerctl. The Keychron mic is Ctrl+Shift+F6 and
  play is Ctrl+Shift+F8. Noctalia stays off.
- Super+Ctrl+arrows change workspace on this screen. Shift adds
  the window and follows. Super+Ctrl+Alt+arrows resize by the same
  10% as Super+/-.
- Super+M maximizes. Super+Shift+V focuses a floating window, or
  a tiled one. Super+Alt+P turns the screens off.
- Still unbound: control center, notifications, weather, settings,
  clipboard history, and lock. Those were Noctalia panels. Brightness
  has no backlight here. Screenshots are not installed.

## 2026-10-12 — mako, cliphist, hyprlock, hypridle

- Omarchy used mako until Quattro replaced it with the Omarchy shell.
  mako is the notifier here. Popups sit at the top right. Super+N and
  Ctrl+Shift+F2 open the history in Fuzzel.
- cliphist watches text and images. Super+V picks one in Fuzzel and
  copies it back.
- Super+L and Super+Alt+L run hyprlock. The background is a blurred
  shot of the desktop. The clock uses the bar's date format.
- hypridle locks after 10 minutes, turns the screens off after 15,
  and locks before sleep. The niri screensaver is unchanged and
  still does not lock.
- niri's lock.sh still calls Noctalia. This session does not.

## 2026-10-12 — Waybar second pass, plus weather

- The gray line along the top of the bar is gone.
- Language, power profile, battery, and backlight are off the bar.
  This machine has no battery and no backlight.
- The clock shows the weekday, the month-day, and the 24-hour time
  together. A click no longer replaces that with the date alone.
- The eye is still the idle inhibitor.
- A weather chip sits beside the clock. Open-Meteo, degrees Celsius,
  cached for 30 minutes. The tooltip shows the city, the condition,
  and today's high and low. The city comes from the public IP.
- Right side order, same day: eye, tray, volume, weather, clock,
  CPU, memory, temperature, then the network address with no mask.
  MPD is off the bar. Nothing is running MPD.
- Temperature was blank because Waybar looks for a thermal zone and
  this board has none. The chip now reads k10temp Tctl.
- One temperature chip. A click cycles CPU, TB1, and TB2.
- One disk chip. A click cycles root, TB1, and TB2. Root is the
  default. TB2 shows as not mounted.
- GPU chip is temperature and busy percent for the RTX 2060.
- Now playing follows playerctl. The old chip was MPD, and MPD is
  not running, so YouTube Music never appeared. A click pauses.
- Temperatures on the bar are Fahrenheit: the CPU and NVMe chip,
  the GPU chip, and the weather chip. 176°F is the hot warning.
  The letter F is not shown.
- Right side, later the same day: eye, tray, clock, CPU, memory,
  temperature, volume, now playing, weather, disk, GPU, network.
- Corrected the same day. Weather belongs left of volume, not the
  system temperature. Order is eye, tray, clock, weather, volume,
  now playing, CPU, memory, disk, GPU, network.
- Every chip on that side is the weather plate: black `#0A0D0B`,
  green `#5CFF6B`.
- CPU is percent, the microchip icon, then Tctl in Fahrenheit.
  Disk is still one drive at a time, root first, click to cycle.
  The chip is percent, a drive icon, then that drive's temperature.
  Root (sda) has no sensor, so the right side is a dash. TB1 and
  TB2 do. TB2 is still unmounted.
- Memory has no temperature sensor on this board. The chip is the
  percent and a memory icon.
- GPU is percent, an expansion-card icon, then Fahrenheit. Font
  Awesome has no GPU glyph, so that one comes from MesloLGS Nerd
  Font, which is last in the bar's font list.
- Meter text follows temperature: green under 140°, yellow-green
  `#D6E04A` from 140° through 174°, red `#FF4B4B` at 175° and up.
  A percent of 90 or more is red even when the part is cool.
  Memory and the root disk have no temperature, so they use the
  percent alone: yellow-green from 70, red from 90.
  The separate temperature chip is off the bar.
- Workspace chips use the same black plate and green numbers. The
  one in use has a green underline. A click focuses that workspace.
  Waybar 0.15 still sends `dispatch workspace`, which Hyprland 0.56
  ignores, so the chips call `hl.dsp.focus` themselves. Each screen
  still shows its own occupied numbers as 1–10.
- Window gaps are 2px between windows and 4px around the screen.
  They were 5 and 10. Waybar chip spacing is unchanged.
- Wallpaper picker is Super+Shift+Return. Fall, Greens, Sky, Relaxing.
- The window title is off the bar. The center is empty.
- Added to the right side: Num/Caps when a lock is on, a privacy
  icon while the mic or a screen share is in use, a pending-update
  count, and up/down speed beside the IP. Hovering the clock shows
  the month. Clicking it opens that month in Fuzzel. Clicking the
  update count lists the packages. Locks come from Hyprland's main
  keyboard, which is keyd, so the input group is not required.
- CPU, memory, disk, and GPU numbers are three-wide monospace
  fields, so the chips stop shuffling as the digits change. Each
  network speed is padded to nine characters, which covers a
  gigabit link. The GPU card icon gets two Meslo spaces before the
  temperature, because one ordinary space sits under the glyph.
- Now playing grows to the whole title. `&`, `<`, and `>` in a
  title are escaped. The bar font list adds Noto Sans, Noto Sans
  CJK JP, Noto Music, Noto Symbols, and Noto Color Emoji.
- Num/Caps moved to just after the eye. Num Lock uses the numeric
  icon and Caps Lock uses the caps-lock key. The chip is hidden
  when both are off.
- The bar face is MesloLGS Nerd Font Mono, the same face as the
  bandwidth figures. Noto stays behind it for characters Meslo
  does not have. Font Awesome 7 Free Solid covers a few icons
  Meslo does not ship.
- Bar font size went from 13px to 17px, about 3pt. The bar stays
  30px tall. 17px was too tall, then 15px, so the text is 14px.
  Eye, Num/Caps, the weather condition, the volume icon, and the
  GPU card are drawn at 16pt. Memory is the RAM-stick glyph.
  Disk is the hard-drive platter. Those two stay at the text size.
- Clicking the update count lists the packages in Fuzzel. The first
  line opens Alacritty and runs `sudo pacman -Syu`. Choosing one
  package runs `sudo pacman -Sy` for that package and its
  dependencies. That list is repo packages only. AUR packages are
  not in the count.

## 2026-10-12 — workspace 2 missing from the bar

- The workspace chips read a cache written by one long-lived listener.
  That listener was still subscribed to the previous Hyprland, so the
  cache never learned that workspace 2 had a window. The bar kept
  drawing only the workspace that had been active when the socket died.
- The listener now follows the Hyprland that is running, and exits
  when that socket goes away so the bar can start a new one. A chip
  restarts the listener if it is not running.

## 2026-10-14 — Fuzzel colors, reboot marks, LazyVim

- Fuzzel is the Novalis palette in `configs/fuzzel/fuzzel.ini`.
  Background `#0A0D0B` is near black with a green cast, not
  `#000000`. Text is `#C8D4C8`. The border, prompt, and typed match
  are `#5CFF6B`. The selected row is that green with `#07100A`
  text. Square corners, 2px border, Meslo at 14px.
  `fuzzel --check-config` passed.
- The bottom bar was already that plate and that green. The
  `#64727D` rules in `configs/waybar/style.css` are leftover stock.
  A later block overrides them for the modules on the bar.
- The updates chip is unchanged. In the Fuzzel list, a row ends in
  `reboot` when the package is unused until the next boot: the
  CachyOS kernels, their NVIDIA modules, `nvidia-utils`,
  `linux-firmware` (not `linux-firmware-whence`), microcode, and
  `limine`. Of the 26 cached updates, only `limine` is marked.
- LazyVim's starter is `~/.config/nvim` (the git remote was
  removed). Plugin sync finished. Mason installed `tree-sitter-cli`
  and `stylua`. No key. Super+Return stays Alacritty.
- tmux did not install. `./scripts/pkg-add.sh tmux` needs a sudo
  password, and this session has no prompt for one.

## 2026-10-14 — green border on the focused window

- Hyprland `border_size` is 2. The focused border is `#5CFF6B`.
  Unfocused borders are `rgba(00000000)`, so they are not drawn.
  The 2px stays on every window and focus does not resize them.
  Unfocused windows stay at 70% opacity.
- Applied with `hyprctl eval` while autoreload was off, so hyprsplit
  did not move the open windows.
- Fuzzel 1.15 cannot paint one dmenu row a different color. The
  reboot mark stays the same color as the rest of the line.

## 2026-10-14 — installed tmux

- requested: tmux
- repos (pacman): tmux
- AUR (paru): (none)

## 2026-10-14 — reboot star on the update list

- A package that needs a reboot ends in `reboot *`. The first line,
  "Update all", says `reboot *` when any package in the list does.
  The chip is unchanged.

## 2026-10-14 — image TUIs open in kitty

- Fuzzel's terminal stays Alacritty. Super+Return stays Alacritty.
  superfile, concord, and neomutt have desktop entries that run
  kitty directly (`Terminal=false`), so Fuzzel does not wrap them.
- Neomutt image attachments go through `scripts/neomutt-icat.sh`.
  The picture stays until Enter. Other types still use `/etc/mailcap`.
- lynx, neovim, caligula, valvefm, and steam-tui do not draw images.

## 2026-10-14 — screensavers removed

- Idle no longer launches a saver. Noctalia's screensaver behavior
  is gone. The niri window rule for it is gone.
- Removed `configs/niri-screensaver` and the Novalis saver scripts
  (`novalis-screensaver`, tunnel, bloom, clock, rain).
- Super+L is still the Noctalia lock. Hyprland still locks at 10
  minutes and blanks the screens at 15. Lid close still locks.
- `niri-screensaver` removed from `packages/aur.txt`. The
  installed package is still on the machine. `paru -Rns niri-screensaver`
  needs a sudo password this session cannot type. Until then the
  launcher entry and the `niri-screensaver` command still exist.
  Idle does not call them.

## 2026-10-14 — temperatures off the bar

- CPU, disk, and GPU chips show a percent. The temperature is off
  the bar. Memory was already a percent.
- At 175°F that chip shows the temperature instead, in red. A
  percent of 90 or more is still red. 140°F through 174°F stays a
  percent and turns yellow-green.
- Left click on CPU, memory, disk, or GPU opens every device value
  in Fuzzel. Right click on the disk chip still cycles root, TB1,
  and TB2.

## 2026-10-14 — network chip is the address

- The network chip shows the address and the link icon. Upload and
  download speeds are off the chip. Hover still shows both speeds.

## 2026-10-14 — bar order

- Now playing sits at the end of the left side, after the workspace
  numbers. The clock is in the center.
- On the right, the update count is just before the CPU chip. The
  GPU chip is just before the disk chip.

## 2026-10-15 — network on the device list

- Clicking the network chip opens the same device list as CPU,
  memory, disk, and GPU. The list adds the link name, address,
  gateway, and a short up and down sample.
- The meter chips no longer reserve three digits. Now playing,
  language, and keyboard-state no longer have a CSS minimum width.
- The GPU chip no longer keeps spaces after the card icon.

## 2026-10-15 — Noctalia removed

- The shell config, its plugins list, and the live
  `~/.config/noctalia` link are gone. niri no longer starts it.
- Super+L is hyprlock. hypridle still locks at 10 minutes and blanks
  the screens at 15.
- niri's old shell keys now use Fuzzel, the clipboard list, and
  PipeWire. Control center, settings, and the weather tab are
  unbound. The screens have no backlight.
- `noctalia` and the `cachyos-niri-noctalia` metapackage are still
  installed. Removing the metapackage with `-Rns` would also take
  niri. The safe removal is `sudo pacman -R cachyos-niri-noctalia`
  and then `sudo pacman -Rns noctalia`. This session cannot type
  the sudo password.
- Mango is a later idea. Nothing was installed.

## 2026-10-15 — niri removed

- The niri config, the stock snapshot, the niri portal file, and
  `scripts/lock.sh` are gone. The live `~/.config/niri` link is gone.
- Hyprland is the session. App keys focus an open window with
  hyprctl. Dropbox, Waybar, mako, hypridle, and the wallpaper still
  start from `hyprland.lua`. tty1 stays a shell. Type `start-hyprland`.
- `niri`, `noctalia`, and `cachyos-niri-noctalia` are still installed.
  Do not remove the metapackage with `-Rns`. That would also take
  packages Hyprland still uses, such as the GTK portal and the
  keyring, when nothing else requires them. The removal is
  `sudo pacman -R cachyos-niri-noctalia` and then
  `sudo pacman -Rns noctalia niri`. `xwayland-satellite` is only
  required by the metapackage, so it stays until
  `sudo pacman -Rns xwayland-satellite`. Hyprland has its own
  Xwayland. This session cannot type the sudo password.
- Mango was not installed.

## 2026-10-15 — installed yazi

- requested: yazi
- repos (pacman): yazi
- AUR (paru): (none)

## 2026-10-15 — kitty is the terminal

- Super+Return opens kitty. Fuzzel's `terminal` is `kitty -e`.
  The session exports `TERMINAL=kitty`.
- btop and the update window open in kitty. The picture apps still
  launch kitty themselves so their window class stays theirs.
- `configs/kitty/kitty.conf` sets `remember_window_size no`, so a
  new kitty does not reopen maximized. Alacritty stays installed.

## 2026-10-16 — bar order

- The eye is the first chip in the center, before the clock. Caps
  and Num Lock are the last chip in the center, after the clock.
- The update count is the first chip on the right.

## 2026-10-16 — installed hyprlock hypridle

- requested: hyprlock hypridle
- repos (pacman): hyprlock 0.9.6-3.1, hypridle 0.1.8-2.1
- AUR (paru): (none)
- The blurred screenshot lock in `configs/hypr/hyprlock.conf` is unchanged.
  hypridle is running. It locks at 10 minutes and blanks the screens at 15.

## 2026-10-16 — weather places

- The weather chip uses five fixed places. Right click cycles
  Citrus Heights, Sugar Bowl, Nevada City, Tahoe, and San Francisco.
  It starts at Citrus Heights.
- Hover is still that place's condition, temperature, high, and low.
- Left click and Super+W open that place's week in Fuzzel. The other
  places are lines under it: city, condition, temperature, feels-like,
  and "See forecast" on the right. Choosing one opens that week the
  same way. The window fits the list. The chip stays on the place
  right-click selected. Chrome stays on Super+Shift+W.
- Sugar Bowl is the Norden resort. Tahoe is the lake.
- Each Fuzzel row is padded out to the menu's 78 characters.

## 2026-10-16 — CPU chip

- k10temp Tctl is connected. The chip shows that temperature only
  above 175°F. Below that, the number is usage from `/proc/stat`.
- The usage sample stores idle, total, and the last percent. The
  reader unpacked every field into idle and total, failed, and
  drew 0%. It now reads the first two fields. A refresh on the
  other screen in the same moment reuses that percent.

## 2026-10-16 — device list

- The device menu lists the 12 logical-processor percentages on one
  line labeled Cores. The first percent sits in the percent column.
  Package temperature stays on the CPU line. There is no per-core
  temperature. Memory's size and the network address sit one space
  further right so they meet that same column.
- Memory shows used and total. The modules have no name without
  root, and no temperature.
- GPU is above the drives. The card name is at the end of the line.
  The drive section is headed "Drives". Each row ends with the
  disk model.
- Network order is address, down and up, adapter, then via.
- The window shrinks to the list.
- Super+Escape opens that menu. Left click on the chips still does too.
- Return opens a tool. CPU, cores, and memory open a tiled btop.
  Super+Ctrl+T opens its own tiled btop. A mounted drive opens
  yazi at that mount. TB2 does nothing while it is unmounted.
  The GPU opens a tiled nvtop. A connected network opens its
  gateway in the browser. A down link opens a tiled nmtui.

## 2026-10-16 — center chips

- Caps and Num Lock are the first chip in the center. The eye and
  the clock follow. Weather is the last chip in the center.
- The right side starts with the update count, then the tray.

## 2026-10-16 — installed nvtop

- requested: nvtop
- repos (pacman): nvtop
- AUR (paru): (none)

## 2026-10-16 — screenshots

- Print and the Keychron crop key drag a region. Alt+Print grabs
  the focused window. Super+Print grabs both screens.
- `scripts/hypr-screenshot.sh` copies the image and saves it under
  `~/Pictures/Screenshots`. Escape, or a click without a drag,
  cancels the region.
- Packages: grim 1.5.0-2.1 and slurp 1.5.0-2.1, via `./scripts/pkg-add.sh`.

## 2026-10-16 — keybind pass

- Super+Shift+Up/Down carries the window onto the previous or next
  workspace when it is already the top or bottom window.
- Removed Super+Alt+arrows and the Super+Ctrl+arrow chords.
  Ctrl+Shift+F2 is unbound. The circle key sends Super+N.
- App chords: Music/YouTube, Neovim/VS Code, Thunderbird compose,
  Lynx, Grok Bot/Grok, btop/nvtop, Obsidian, Concord. Alt+F4
  closes the window. Cover-the-screen is Super+Ctrl+F2.
- VLC is still unbound.

## 2026-10-16 — screenshot opens in yazi

- Clicking the screenshot notification opens that file in yazi.
  Super+N does the same, including after the popup has expired.
  The popup stays up for 15 seconds.

## 2026-10-16 — installed grim slurp

- requested: grim slurp
- repos (pacman): grim slurp
- AUR (paru): (none)

## 2026-10-16 — fast fade, slow slide

- Window opacity uses `fadeIn` and `fadeOut` at speed 1, so 100ms.
  The `gnomed` shade stays at 300ms.
- Workspace changes use `slidevert`. The desk stays solid and still
  slides a full screen height over 300ms.
- The dim on an unfocused window is unchanged.
- Applied with `hyprctl eval` while autoreload was off.

## 2026-10-16 — gnomed windows, vertical workspace slide

- Windows open and close with `gnomed`: a horizontal line through
  the middle opens up and down. Closing reverses it.
- Workspace changes use `slidefadevert`. The desk slides a full
  screen height and fades.
- Both take 300ms. Moving a tile stays a plain move.
- Applied with `hyprctl eval` while autoreload was off.

## 2026-10-16 — Super+E opens yazi

- Super+E focuses an open yazi, or starts one in kitty.
  The window class is `yazi`, so a screenshot opened in yazi
  is left alone.
- Nautilus is no longer on that key.

## 2026-10-16 — empty workspace on Shift+Up/Down

- Super+Shift+Up/Down still moves the window inside the workspace.
  At the top or bottom it steps one workspace number on this screen.
  That number can be empty. The step stops at 1 and at 10.
- Super+Up/Down still goes to the previous or next occupied workspace.
