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

## 2026-09-04 — table For Honor

- proton-cachyos-slr/umu did run (`upc.exe` + WebCore + xalia) but no
  window. Killed the leftover tree. Tabled with Halo / BGA.
