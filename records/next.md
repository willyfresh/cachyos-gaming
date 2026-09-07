# Next

Scratch notes from `os-notes.txt` land here after triage.
Dump obstacles in that file, then hand it over. This page is the working
list. Done items move into `journal.md` / `gaming.md` / `hardware.md` and
come off this page.

| Want | Who | Status |
|------|-----|--------|
| Halo Infinite Xbox Live login | you | tabled |
| Board Game Arena freezes in the WebKit window | you | superseded: Chrome --app |
| Steam menus flash and close | you | accepted / tabled |
| Fullscreen windows swap on a mouse overshoot | you confirm | applied `max-scroll-amount="0%"` |
| For Honor / Ubisoft Connect | you | tabled |
| Super+Ctrl+Alt size, Super+drag, windowed fullscreen | you confirm | applied 2026-09-06 |
| Webapp Chrome login (BGA / Messages / …) | you | sign in once in a webapp |
| Super-letter app keys (Windows pass) | you | waiting; table in `records/keybinds.md` |

## Halo Infinite Xbox Live login

Titled **Steam Big Picture Mode** (1280×800), not a Halo window. Keep that
overlay focused on the left (primary) monitor; do not exclusive-fullscreen
Halo while signing in. Launch options and the NVIDIA/Xalia notes live in
`gaming.md`. Pick this back up when you want another pass.

## Board Game Arena (Chrome --app, was WebKit freeze)

WebKit wrapper is parked (`scripts/board-game-arena`). Live launcher is
`scripts/launch-webapp.sh` — title-less Chrome `--app=URL` with a dedicated
profile at `~/.local/share/borg/chrome-webapps` (Default). Same trick as
Delorean; do not use `--app-id` (PWA CSD title bar). Super+Shift+B focuses
or launches. Sign in once; cookies survive closing the window. WebKit login
cookies do not carry over.

## Steam menus flash and close

xwayland-satellite + the 2026-09-01 Steam client. `clip-to-geometry false`
on Steam windows; do **not** add `-cef-disable-gpu-compositing` (Halo's
Xbox login needs GPU web views). Lived-with for now.

## Fullscreen windows swap on a mouse overshoot

niri's FAQ: bare `focus-follows-mouse` treats CSD resize slivers at a
monitor edge as the next column, so a slight overshoot swaps the
fullscreen/maximized window. Applied:

```
focus-follows-mouse max-scroll-amount="0%"
```

That follows the pointer only when it will not scroll the strip. Crossing
the bezel onto the other monitor still focuses that output (intended).
niri has no focus-delay yet (PR #3854). If 0% is still too twitchy in
games, next knobs are disable FFM or wrap the game in gamescope.

Confirm by aiming at something near a screen edge in a fullscreen window.

## For Honor / Ubisoft Connect

Epic title Sundrop, prefix
`/run/media/willyfresh/TB1/Heroic/Prefixes/For Honor`. Distro `wine-mono`
is installed. wine-11.16 got Connect on screen then hung in CEF. After
Heroic was restarted, `proton-cachyos-slr` (umu) did launch (`upc.exe` +
`UplayWebCore.exe` + xalia) but **no window appeared**. Ubisoft drops
Linux / Steam Deck for this title on **2026-09-10**. Pick it back up with
Halo if you still care before then.

## Super+Ctrl+Alt size, Super+drag, windowed fullscreen

Applied this round. Confirm:

- Super+Ctrl+Alt+Left/Right: this column thinner/wider by 10% of the
  screen. Up/Down is height. Super+Ctrl+Alt+scroll is width (wheel up =
  bigger, down = smaller; tilt left/right still thinner/wider). Super+/-
  stays the keyboard version. If +/- still feels wrong, the column is
  maximized or on a preset (`Super+R`), not the action.
- Super+hold, then left-drag: moves the window. keyd now sees the
  Glorious Model D / Keychron pointer so Super+click is a hold, not a
  launcher tap. ~200ms Super-hold without a tap does not open the
  launcher. niri has no extra delay on the drag itself (pixel threshold
  only). If the pointer dies, drop the mouse IDs from
  `configs/keyd/default.conf` and rerun `scripts/apply-system.sh`.
- Super+Ctrl+F on a website: the page goes fullscreen *inside* the niri
  tile (browser chrome gone). Super+Shift+F is still exclusive
  fullscreen. Super+Alt+F took the old expand-column bind.

## Webapp Chrome login

Profile is `~/.local/share/borg/chrome-webapps`. First launch of BGA /
Gmail / Messages / Maps / Calendar / YouTube Music will look logged out.
Sign in there once. Links out of those windows stay in that Default.
`scripts/collapse-webapp-profile.sh` is only needed if a second named
profile appears.

## Homogeny: Borg niri vs Delorean Hyprland

Already the same muscle: Super tap / Super+Space launcher, Super+Q close,
Super+Return terminal, Super+E files, Super+V clipboard, Super+Tab
overview, Super+Shift+Tab previous desk, Alt+Tab recent windows, Super+K
cheatsheet, Super+arrows with Shift = move, Super+/- this-column width,
Super+Ctrl+F windowed fullscreen, Super+Shift+B BGA, Super+D Discord,
Super+L lock.

Intentionally **not** copied: Omarchy Super+/- is left-edge resize; Borg
keeps `set-column-width ±10%`. Super+Ctrl+arrows is workspace on niri
(scroll layout) and swap-neighbor on Hyprland (dwindle). Leave that split.

Still different. Super+D is Discord and Super+L is lock (Super+Alt+L still
locks too). The rest wait on a Windows Super-letter pass:

| Key | Delorean | Borg today | Notes |
|-----|----------|------------|-------|
| Super+T | VS Code | toggle float | `Super+Shift+V` is float/tile focus |
| Super+W | browser | tabbed column | |
| Super+B | (browser is Super+W) | Firefox | |
| Super+Shift+Return | Messages | wallpaper picker | |

Do not steal those niri defaults until the Windows combos say what they
should be.
