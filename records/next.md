# Next

Scratch notes from `os-notes.txt` land here after triage.
Dump obstacles in that file, then hand it over. This page is the working
list. Done items move into `journal.md` / `gaming.md` / `hardware.md` and
come off this page.

**Pace (2026-09-08):** backlog only. Grok Bot work is eating SuperGrok
quota, so nothing starts until you pick **one, maybe two** items from
this page. Do not implement a dump just because the inbox was handed
over.

| Want | Who | Status |
|------|-----|--------|
| tty1 stays a shell | you confirm next boot | applied 2026-09-22 |
| Windows Super-letter binds | you confirm | applied 2026-09-22: A I N W; B and D unbound |
| Halo Infinite Xbox Live login | you | tabled |
| Board Game Arena freezes in the WebKit window | you | superseded: Chrome --app |
| Steam menus flash and close | you | accepted / tabled |
| Fullscreen windows swap on a mouse overshoot | you confirm | applied `max-scroll-amount="0%"` |
| For Honor / Ubisoft Connect | you | tabled |
| Super+Ctrl+Alt size, Super+drag, windowed fullscreen | you confirm | applied 2026-09-06 |
| Webapp Chrome login (BGA / Messages / …) | you | sign in once in a webapp |
| Super-letter app keys (Windows pass) | you confirm | applied 2026-09-22; Shift+letter apps too |
| Matrix theme + falling-code screensaver | you confirm | applied 2026-09-07 |
| Rename host to Novalis | you (new login picks it up everywhere) | applied 2026-09-07 |
| Grok Bot desktop app | you (sign in) | installed; Super+Shift+Alt+A |
| Super+Ctrl+T floating btop | you confirm | applied 2026-09-07 |
| Screensaver vs lock split | you confirm | applied 2026-09-08; Super+L is a normal lock |
| Dropbox missing | you (sign in) | installed; autostart |
| ASCII screensaver catalog | you pick | backlog |
| Deep ASCII: skull + butterfly + countdowns | you pick | timers applied; skull/butterfly backlog |
| `niri-screensaver` CLI is still Omarchy TTE | you pick | backlog |
| Super+F maximize on both machines | you confirm (Delorean: `hyprctl reload`) | applied 2026-09-08 |
| Keychron V6 special keys | you | applied; X unassigned; mic may become voice |
| Thunderbird | you (add Gmail + Dreamhost IMAP) | installed |
| Photoshop-type editor (Photopea is unusable) | you confirm | GIMP installed |
| Vector editor: is Inkscape the one? | you confirm | Inkscape installed |

## tty1 stays a shell

Applied 2026-09-22. `configs/bash_profile` no longer starts niri.
Switch to tty1 (Ctrl+Alt+F1), log in, and you get a prompt. The
desktop is `niri-session` from that prompt. This tty3 session is
untouched.

Confirm on the next real boot: tty1 shows a login, then a shell,
and does not sit there spinning.

## Windows Super-letter binds

Applied 2026-09-22.

| Key | Job |
|-----|-----|
| Super+A | Control center (Super+S still does this too) |
| Super+I | Noctalia settings (Super+Shift+S still does this too) |
| Super+N | Notification history (Keychron circle still does this too) |
| Super+W | Weather tab of the control center |
| Super+B | unbound (was Firefox) |
| Super+D | unbound (was Discord) |

Super+W used to toggle a tabbed column. That action has no key now.
Weather is enabled in `configs/noctalia/config.toml`. It needs a
location (Settings → Location) before the forecast fills in.

## Omarchy letters worth absorbing

Applied 2026-09-22. Super+Shift+letter launches and focuses. Same chord
as Delorean where that key was free. Scratchpad stays on Delorean.
Tabbed columns stay unbound.

| Key | App |
|-----|-----|
| Super+Shift+C | Google Calendar |
| Super+Shift+D | Discord |
| Super+Shift+E | Thunderbird |
| Super+Shift+Alt+E | Thunderbird compose |
| Super+Shift+G | Gmail |
| Super+Shift+L | Google Maps |
| Super+Shift+M | Google Messages |
| Super+Shift+O | LibreOffice |
| Super+Shift+T | VS Code (Delorean uses bare Super+T; that key still floats) |
| Super+Shift+W | Chrome (the main browser, not a webapp) |
| Super+Shift+Y | YouTube Music, then YouTube |
| Super+Shift+B | Board Game Arena (already) |

Left where they were:

| Key | Delorean | Novalis |
|-----|----------|---------|
| Super+M | YouTube Music | Maximize to edges |
| Super+D | Discord | unbound; Discord is Super+Shift+D |
| Super+Shift+Return | Messages | Wallpaper picker |
| Super+W | Browser | Weather; Chrome is Super+Shift+W |

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

## Homogeny: Novalis niri vs Delorean Hyprland

Already the same muscle: Super tap / Super+Space launcher, Super+Q close,
Super+Return terminal, Super+E files, Super+V clipboard, Super+Tab
overview, Super+Shift+Tab previous desk, Alt+Tab recent windows, Super+K
cheatsheet, Super+arrows with Shift = move, Super+/- this-column width,
Super+Ctrl+F windowed fullscreen, Super+Ctrl+T btop, Super+Shift+B BGA,
Super+Shift+C Calendar, Super+Shift+D Discord, Super+Shift+E Thunderbird,
Super+Shift+G Gmail, Super+Shift+L Maps, Super+Shift+M Messages,
Super+Shift+O LibreOffice, Super+Shift+W Chrome, Super+Shift+Y Music then YouTube,
Super+L lock, Super+Shift+Alt+A Grok.

Intentionally **not** copied: Omarchy Super+/- is left-edge resize; Novalis
keeps `set-column-width ±10%`. Super+Ctrl+arrows is workspace on niri
(scroll layout) and swap-neighbor on Hyprland (dwindle). Leave that split.

Still different. Super+D is unbound here and Discord on Delorean.
Super+T floats here; VS Code is Super+Shift+T. Super+L is lock
(Super+Alt+L still locks too).

| Key | Delorean | Novalis today | Notes |
|-----|----------|------------|-------|
| Super+T | VS Code | toggle float | VS Code is Super+Shift+T |
| Super+W | browser | weather | tabbed column has no key |
| Super+B | (browser is Super+W) | unbound | was Firefox |
| Super+Shift+Return | Messages | wallpaper picker | Messages is Super+Shift+M |

Super+Ctrl+T is now Activity (btop) on both machines. Super+Shift+Alt+A
is Grok Bot on Novalis and Grok on Delorean.

## Matrix theme, screensaver, hostname

Applied 2026-09-07. Ship name is **Novalis** (Tirant's hovercraft,
Zion dock pad 4). Palette `Novalis.json` is the same gunmetal +
`#5CFF6B`. Bar chip is `NOVALIS`. Wallpapers: rain, hull, dock, construct, then
close rain / code skyline / phone booth / operator core / cockpit /
pad hero / broadcast depth / blue flower.

Screensaver is `niri-screensaver` with TTE effects `matrix,rain,decrypt`,
Novalis wordmark, both monitors mirrored. Idle: 150s screensaver, 300s
lock. Package and hostname applied 2026-09-07.

Chrome webapp cookies stay at `~/.local/share/borg/chrome-webapps` on
purpose (moving that dir would look logged out).

## Grok Bot desktop app

AUR `grok-bot-bin` 0.43.0 is installed. Super+Shift+Alt+A focuses or
launches (`scripts/launch-grok-bot.sh`). Sign in with the same Cursor /
SuperGrok account used on Android and Delorean.

## Screensaver vs lock split

Applied 2026-09-08, then Super+L dropped the saver the same day.

- Idle 150s: screensaver only. `[idle.behavior.lock]` is off.
- Super+L / Super+Alt+L: kill any saver, then a normal Noctalia lock
  (wallpaper + password). niri cannot play a live saver *over* the
  lock (`ext-session-lock-v1` blanks windows).
- Lid close / suspend still locks (`lock_before_suspend = true`).

Confirm: wait past 150s with no lock; Super+L should be wallpaper +
PAM, no animation.

## Dropbox missing

AUR `dropbox`, autostart `dropbox start -i` in
`configs/niri/cfg/autostart.kdl`. Sign in on first run (tray).

## ASCII screensaver catalog

Day-of-year dropped 2026-09-08 (did not make sense). Still backlog:
flying toasters, 3D pipes, beziers, real 3D Novalis text. Stock
`niri-screensaver` in a terminal is still Omarchy TTE.

## Deep ASCII: skull + butterfly + countdowns

Rain never stops. Facts are one line, all caps, decade first, Bex last
(`YOUR 40S: 8 YEARS | 428 WEEKS | 2995 DAYS`); separators vary.
Digits scramble 4–7 hits then lock white; after the hold, glyphs
dissolve down. NOVALIS reveal rotates: touch (first-hit lock), light
scramble, or top-down drip.

- Bex 18: born **2017-11-07** → 2035-11-07
- Decades: your **1984-11-20**, currently 40s, then 50s, 60s
- 65: 2049-11-20
- 90: 2074-11-20
- Winters / stop-snowboarding: skipped. Dad is 68 and still going.

Skull + butterfly still backlog.

## `niri-screensaver` CLI is still Omarchy TTE

Typing `niri-screensaver` in Alacritty runs the packaged TTE set, same
family as Omarchy. Expected until the CLI is pointed at
`scripts/novalis-screensaver` or the catalog above replaces it.

## Super+F maximize on both machines

Applied 2026-09-08. Super+F toggles maximize on both:

- Novalis: already `maximize-column` (unchanged). Exclusive fullscreen
  stays Super+Shift+F; windowed fullscreen stays Super+Ctrl+F.
- Delorean: was Omarchy exclusive fullscreen; now
  `fullscreen({ mode = "maximized", action = "toggle" })`. Super+Ctrl+F
  stays windowed fullscreen, Super+Alt+F stays full width, Super+Shift+F
  stays files. Reload Hyprland on Delorean (`hyprctl reload`) to pick it
  up.

## Keychron V6 special keys

Windows mode stays. Applied 2026-09-09:

- **Fn+F4** (six-pack): VIA remaps from Super+E to Super+Space so it
  opens the launcher. Super+E is still Nautilus.
- **Fn+F8** play/pause: VIA sends F18; keyd turns that into
  Ctrl+Shift+F8; niri toggles Noctalia media. HID Play is resume-only
  and Chrome needs it for MPRIS, so we do not send Play.
- **Knob cluster:** crop = region screenshot, mic = mute (maybe voice
  input later), light = control center. Circle / triangle / square / X
  (F14–F17): circle = notification history, triangle = Grok Bot,
  square = cycle Steam/Heroic. X still unassigned. Mic stays mute
  until voice input.

Script: `scripts/keychron-v6-via.py`. udev:
`configs/udev/99-keychron-v6-via.rules`. `scripts/apply-system.sh`
installs both (sudo).

## Thunderbird

Installed (`thunderbird` 155.0.1). Unified inbox for Gmail + Dreamhost
IMAP. No Gmail category tabs. Not a website. Add accounts when you pick.

## Photoshop-type editor (Photopea is unusable)

Photopea is a browser Photoshop clone; if it is unresponsive here, stay
native. Pick one:

- **GIMP** — closest FOSS Photoshop (layers, masks, plugins). Repo
  `gimp`.
- **Krita** — painting-first, still does photo/layers. Often smoother
  on a GPU. Repo `krita`.

Neither is Adobe. Wine/Bottles Photoshop is a later, painful option.
Agent installs whichever you name.

## Vector editor: is Inkscape the one?

For Linux FOSS, **yes**. Illustrator/Affinity have no native Linux
build. Figma/Penpot are web (same class of problem as Photopea). Boxy
SVG is simpler and Electron. Inkscape is the one people actually ship
work in. Install is `./scripts/pkg-add.sh inkscape` if you want it.
