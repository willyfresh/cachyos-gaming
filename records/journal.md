# Journal

A running record of installs and config changes. Package names that should survive a reinstall also live in `packages/extra.txt`. Config diffs live in git.

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
