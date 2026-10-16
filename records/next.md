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
| Matrix theme + falling-code screensaver | — | theme kept; screensaver removed 2026-10-14 |
| Rename host to Novalis | you (new login picks it up everywhere) | applied 2026-09-07 |
| Grok Bot desktop app | you (sign in) | installed; Super+Shift+Alt+A |
| Super+Ctrl+T floating btop | you confirm | applied 2026-09-07 |
| Screensaver vs lock split | you confirm | applied 2026-09-08; Super+L is a normal lock |
| Dropbox missing | you (sign in) | installed; autostart |
| ASCII screensaver catalog | — | removed 2026-10-14 |
| Deep ASCII: skull + butterfly + countdowns | — | removed 2026-10-14 |
| `niri-screensaver` CLI is still Omarchy TTE | — | removed 2026-10-14 |
| Super+F maximize on both machines | you confirm (Delorean: `hyprctl reload`) | applied 2026-09-08 |
| Keychron V6 special keys | you | applied; X unassigned; mic may become voice |
| Thunderbird accounts | you | signed in 2026-09-26 |
| Bar network: icon only | you confirm | applied 2026-09-26 |
| Obsidian | you (open the vault) | installed 2026-09-26 |
| Bitwarden desktop | you | signed in 2026-09-26 |
| VLC | you | installed 2026-10-01 |
| Photoshop-type editor (Photopea is unusable) | you confirm | GIMP installed |
| Vector editor: is Inkscape the one? | you confirm | Inkscape installed |
| Switch to tiling windows | — | dropped: niri only scrolls |
| Terminal apps, mouse optional | you | installed 2026-10-08, no keys |
| Super alone does nothing | you confirm | applied 2026-10-07 |
| Hyprland bar | you confirm | applied 2026-10-09 |
| Waybar, second pass | you confirm | applied 2026-10-12 |
| croft instead of neovim | — | superseded 2026-10-14: LazyVim |
| Keychron keys on Hyprland | you confirm | volume, mic, and play applied 2026-10-12; panels still open nothing |
| Login keyring stays locked | you | backlog |
| Active window green border | you confirm | applied 2026-10-14 |
| Quieter Hyprland animations | you pick | backlog |
| LazyVim and tmux | you | applied 2026-10-14 |
| Image TUIs open in kitty | you confirm | applied 2026-10-14 |
| Update needs a restart | you confirm | applied 2026-10-14, mark on the Fuzzel row |
| Fuzzel matches Novalis | you confirm | applied 2026-10-14 |
| Kitty opens maximized | you | answered: kitty remembered it |
| Noctalia | — | removed 2026-10-15 |
| niri | — | removed 2026-10-15 |
| Mango | you | later |
| Stow layout | you pick | backlog |
| Matrix rain on the lock and on SDDM | you pick | hyprlock and hypridle installed 2026-10-16; rain and SDDM still backlog |

## Stow layout

Backlog, from the 2026-10-16 inbox prompt. Nothing was moved.

This repo is already the dotfiles repo. `./setup.sh` installs the
package lists, and `scripts/apply-configs.sh` symlinks the live
files. `hyprland.lua` is linked as one file so Hyprland's runtime
files stay out of the repo. Scripts go to `~/.local/bin`. Desktop
entries go to `~/.local/share/applications`.
`scripts/apply-system.sh` copies keyd, udev, and the Limine hook
into `/etc` with sudo. GNU Stow is not installed. A Stow tree would
replace those two scripts. The current links already come back from
`./setup.sh`.

## Matrix rain on the lock and on SDDM

hyprlock 0.9.6-3.1 and hypridle 0.1.8-2.1 are installed. The lock
stays the blurred screenshot. Rain and SDDM are still backlog.

The prompt asks for green falling-code rain on the lock screen and
on the SDDM login.

SDDM 0.21.0-8 is installed. `sddm.service` is disabled and inactive.
`/etc/sddm.conf` is an empty `[Autologin]` section. The themes on
disk are elarun, maldives, and maya. tty1 stays a shell. Type
`start-hyprland`. A greeter theme stays unseen until SDDM is the
display manager. Turning SDDM on replaces that tty login.

The lock file is `configs/hypr/hyprlock.conf`: Novalis green, a
blurred screenshot, and the bar's date format. Super+L and
Super+Alt+L call `hyprlock`. `hyprland.lua` starts `hypridle`,
which is set to lock at 10 minutes and blank the screens at 15.
Both are in `packages/extra.txt`. Super+L runs hyprlock.
hyprlock paints its own background, so the desktop wallpaper does
not show on the lock. The background path takes a still image.

The falling-code screensaver was removed 2026-10-14. This prompt
leaves idle savers off.

When you want one of these built:

- Point the hyprlock background at a rain still.
- Enable SDDM with a rain greeter. That becomes the login.

## Active window green border

Applied 2026-10-14. Hyprland draws a 2px border. The focused window
is `#5CFF6B`. Unfocused borders are fully transparent, so they show
no edge. The 2px stays reserved on every window, so focus does not
resize them. Unfocused windows are still 70% opaque.

Fuzzel cannot color one update row. A list is one text color. The
`reboot` word stays on the line.

## Quieter Hyprland animations

Backlog. Nothing in `hyprland.lua` sets an animation, so Hyprland
0.56 is on its defaults. Windows scale in (`popin`) and workspaces
slide. `hl.animation()` takes a leaf, and speed is in tenths of a
second (1 is 100ms).

- Off. `leaf = "global"` disabled. Windows appear, workspaces cut.
- Fade only. Disable `windows` and `workspaces`. Opacity still eases.
- Shorter. Keep the motion, drop the speed toward 1.
- Different motion. `windows` styles are `slide`, `popin`, and
  `gnomed`. Pop-in is the loud one.

Niri's set is separate and already short (200ms). This note is the
Hyprland session.

## LazyVim and tmux

LazyVim applied 2026-10-14. The starter is `~/.config/nvim`, cloned
from https://github.com/LazyVim/starter with `.git` removed. It is
not a pacman package and it is not in this repo. Plugins are
synced. Mason installed `tree-sitter-cli` and `stylua`. `nvim` is
that config. No key. Super+Return opens kitty. VS Code extras
are still off. `:LazyExtras` is where those get turned on.

tmux 3.8-1.1 is installed. `packages/extra.txt` has it. No key.

## Image TUIs open in kitty

Applied 2026-10-14 for the three picture apps. As of 2026-10-15,
Fuzzel's terminal is kitty and Super+Return opens kitty. Those three
still launch kitty themselves, with `Terminal=false`, so the window
class stays theirs.

- superfile: `kitty --class superfile -e spf`
- concord: `kitty --class concord -e concord`
- neomutt: `kitty --class neomutt -e neomutt`

Neomutt's mailcap sends an image attachment to `neomutt-icat.sh`.
The picture stays until Enter, because neomutt clears the screen
when the viewer returns. It does not pop an image up on every
message. Other attachment types still use `/etc/mailcap`.

lynx, neovim, caligula, valvefm, and steam-tui do not draw images.
yazi 26.9.1-2.1 is installed. Its desktop entry is `Terminal=true`,
so Fuzzel opens it in kitty. LazyVim's image plugins are still off.

## Update needs a restart

Applied 2026-10-14. The chip is still the count and the download
icon. In the Fuzzel list, a row ends in `reboot *` when that package
is unused until the next boot. The "update all" line says `reboot *`
when any row does.

Marked: `linux-cachyos`, `linux-cachyos-lts`, the matching
`linux-cachyos-nvidia-open` packages, `nvidia-utils`,
`lib32-nvidia-utils`, `linux-firmware` and its splits,
`amd-ucode`, `intel-ucode`, and `limine`. Not marked: kernel
headers, `linux-firmware-whence`, and the Limine hook. Restarting
services after a library update is still unmarked.

## Fuzzel matches Novalis

Applied 2026-10-14 in `configs/fuzzel/fuzzel.ini`. The background is
`#0A0D0B`, near black with a green cast, not `#000000`. Text is
`#C8D4C8`. The border, the prompt, and a typed match are `#5CFF6B`.
The selected row is that green with `#07100A` text. Square corners,
2px border, Meslo at 14px.

The bottom bar on both screens was already that plate and that
green. `style.css` still has stock `#64727D` rules, and a later
block in the same file overrides them for the modules that are
actually on the bar. Fuzzel was the window still on Solarized cream.

## Kitty opens maximized

Answered 2026-10-14. Nothing in this repo fullscreen's kitty,
and Hyprland has no kitty rule.

Kitty remembers the OS window state. `~/.cache/kitty/main.json`
says `"window-state": "maximized"`, and the live window has
`fullscreenClient` set, which means kitty asked. A lone dwindle
window already fills the screen minus the 4px gap and the bar, so
maximized and "only window" look the same until a second window
opens. Chrome and VS Code on an empty workspace are that same size
with the flag off.

Applied 2026-10-15. `configs/kitty/kitty.conf` sets
`remember_window_size no`, linked at `~/.config/kitty/kitty.conf`.
A new kitty no longer reopens maximized.

## Hyprland bar

Applied 2026-10-09, reset to the stock Waybar the same day. Bottom
of both screens. Each screen has its own workspaces 1–10, and a
bar lists a number only while that workspace has a window.
Super+Space opens Fuzzel. Super+K opens the key list.
Super+Shift+Return opens the fractal wallpaper colors. The bar
plate is transparent. The Novalis chip is gone. The bar does not
print a key-mode name. Next pass can move this toward the Omarchy bar.

Lock is hyprlock. The clipboard is a Fuzzel list. Super+Shift+Q
still quits.

## Waybar, second pass

Applied 2026-10-12. The gray top border is gone. Language, power
profile, battery, and backlight are off the bar. The clock shows
`Sat 10-12  14:26` and a click no longer swaps it for the date.
The eye stays. Weather sits beside the clock in °F, and the
tooltip has the condition plus today's high and low. As of 2026-10-16
the place is no longer the public IP. Right click cycles Citrus
Heights, Sugar Bowl, Nevada City, Tahoe, and San Francisco.

## croft instead of neovim

Superseded 2026-10-14. The editor is LazyVim. See above.

[croft](https://codeberg.org/vitali87/croft) is a VS
Code-style terminal editor: explorer, editor, and a terminal pane.
It is not in the CachyOS repos. The only `croft` package hit is
Mycroft's `mimic1`. Neovim stays until croft is installed and you
say it replaces it. No key.

Fuzzel opened Neovim and Superfile in Alacritty as of 2026-10-09.
Superseded 2026-10-15: Fuzzel's terminal is kitty.

## Keychron keys on Hyprland

keyd is shared. Applied 2026-10-12 for the keys that have a
Hyprland action: volume up, down, and mute; mic mute
(Ctrl+Shift+F6); play/pause (Ctrl+Shift+F8 and the media key);
next and previous track.

Applied 2026-10-12 for the shell pieces that have a Hyprland program:

- Circle (Ctrl+Shift+F2) and Super+N open mako history in Fuzzel.
- Super+V opens cliphist in Fuzzel.
- Super+L locks with hyprlock. hypridle locks after 10 minutes.

Still nothing to open:

- Light (Ctrl+Shift+F1) was the control center.
- X (Ctrl+Shift+F5) was unbound on niri too.
- Weather and settings have no Hyprland app.

Brightness has no backlight on these screens.
Screenshots need grim and slurp, which are not installed.

## Login keyring stays locked

Backlog. gnome-keyring is running. Hyprland is started by typing
`start-hyprland` at the tty, so the login password never unlocks
the keyring. The first program that needs a secret asks to open
it. That is the "didn't open the keychain" dialog. Leave it until
you want the tty login to unlock the keyring.

## tty1 stays a shell

Applied 2026-09-22. `configs/bash_profile` does not start a
compositor. Switch to tty1 (Ctrl+Alt+F1), log in, and you get a
prompt. Type `start-hyprland` from that prompt. niri was removed
2026-10-15.

Confirm on the next real boot: tty1 shows a login, then a shell,
and does not sit there spinning.

## Windows Super-letter binds

Applied 2026-09-22.

| Key | Job |
|-----|-----|
| Super+A | unbound (was the Noctalia control center) |
| Super+I | unbound (was Noctalia settings) |
| Super+N | Notification history (Keychron circle still does this too) |
| Super+W | Weather Fuzzel (was the Noctalia weather tab) |
| Super+B | unbound (was Firefox) |
| Super+D | unbound (was Discord) |

Super+W opens the weather Fuzzel. It used to toggle a tabbed column.
The Noctalia control center, settings, and weather tab were removed
2026-10-15. Weather on the bar is the Waybar chip.

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
| Super+Shift+H | Heroic |
| Super+Shift+I | Inkscape |
| Super+Shift+L | Google Maps |
| Super+Shift+M | Google Messages |
| Super+Shift+O | LibreOffice |
| Super+Shift+P | GIMP |
| Super+Shift+S | Steam |
| Super+Shift+T | VS Code (Delorean uses bare Super+T; that key still floats) |
| Super+Shift+W | Chrome (the main browser, not a webapp) |
| Super+Shift+Y | YouTube Music, then YouTube |
| Super+Shift+B | Board Game Arena (already) |

Monitor power is Super+Alt+P. Settings stay on Super+I.

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
- Super+hold, then left-drag: moves the window. As of 2026-10-07 keyd
  does not remap Super and does not grab the mouse, so the compositor
  sees a normal modifier. niri has no extra delay on the drag itself
  (pixel threshold only).
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

Already the same muscle: Super+Space launcher, Super+Q close,
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

The falling-code screensaver was removed 2026-10-14. Hostname and
palette stayed.

Chrome webapp cookies stay at `~/.local/share/borg/chrome-webapps` on
purpose (moving that dir would look logged out).

## Grok Bot desktop app

AUR `grok-bot-bin` 0.43.0 is installed. Super+Shift+Alt+A focuses or
launches (`scripts/launch-grok-bot.sh`). Sign in with the same Cursor /
SuperGrok account used on Android and Delorean.

## Screensaver vs lock split

Removed 2026-10-14. Nothing idle-launches a saver. Super+L is
hyprlock. hypridle still locks at 10 minutes and turns the screens
off at 15. Lid close still locks.

## Dropbox missing

AUR `dropbox`, autostart `dropbox start -i` in
`configs/hypr/hyprland.lua`. Sign in on first run (tray).

## ASCII screensaver catalog

Removed 2026-10-14 with the rest of the savers. The catalog, the
rain, the countdowns, and the skull and butterfly are gone.

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
  Ctrl+Shift+F8; Hyprland sends that to playerctl. HID Play is resume-only
  and Chrome needs it for MPRIS, so we do not send Play.
- **Knob cluster:** crop = region screenshot, mic = mute (maybe voice
  input later). The light key was the Noctalia control center and is
  unbound. Circle / triangle / square / X
  (F14–F17): circle = notification history, triangle = Grok Bot,
  square = cycle Steam/Heroic. X still unassigned. Mic stays mute
  until voice input.

Script: `scripts/keychron-v6-via.py`. udev:
`configs/udev/99-keychron-v6-via.rules`. `scripts/apply-system.sh`
installs both (sudo).

## Thunderbird

Installed (`thunderbird` 155.0.1). Unified inbox, no Gmail category
tabs. The app is in. The accounts are not.

2026-09-26: four of your mailboxes, confirmed by you. Client
contacts under `People/` and `Clients/` stay in the vault.

| Address | Host |
|---------|------|
| `willyfresh@gmail.com` | Google |
| `will@billcompany.net` | DreamHost |
| `email@willyfresh.com` | DreamHost |
| `will@willfloyd.com` | DreamHost |

`willyfresh.com` and `willfloyd.com` receive at `mx1`/`mx2.dreamhost.com`.
`billcompany.net` receives through Mailchannels, with DreamHost still
in the SPF record. DreamHost IMAP for all three is `imap.dreamhost.com`
(993, SSL) and SMTP is `smtp.dreamhost.com` (465, SSL). Gmail stays
on Google's servers.

`tech@willyfresh.com` is the site contact address, not one of these
accounts. Passwords stay out of git.

Applied 2026-09-26 in the live profile
(`~/.config/thunderbird/java9occ.default-release`). Gmail was already
there. The three DreamHost accounts use normal password auth.
Sign-in confirmed the same day. The folder pane is the unified inbox.

## Bar network label

The ethernet chip on the bar does not need its text. That widget
lived in Noctalia, which was removed 2026-10-15. The Waybar network
chip shows the address.

## Obsidian

Installed 2026-09-26 (`obsidian` 1.13.7-2). The vault is already at
`~/Projects/Obsidian-Vault`. Open that folder. Nothing in the vault
has to move.

## Bitwarden desktop

Installed 2026-09-26 (`bitwarden` 2026.3.1-2.1, launcher
`bitwarden-desktop`). Signed in the same day. The browser extension
is still installed; say so if you want it removed.

## VLC

Installed 2026-10-01 (`vlc` 3.0.23_2-16.1, cachyos-extra-v3).
`vlc-plugins-all` was already on the machine. No key: Super+V is the
clipboard and Super+Shift+V switches floating and tiling.

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

## Switch to tiling windows

Dropped 2026-10-07. niri has no layout besides the scrolling strip.
A lone window opening full, then both shrinking to half, would need a
watcher. Left the strip alone. btop still floats.
Delorean can still toggle one desk to dwindle with Super+Ctrl+L.

## Terminal apps, leave the mouse

Installed 2026-10-08. No key yet. Nautilus, Chrome, Thunderbird,
Discord, and Steam stay until you say one of these replaces it.

| App | Command | Version |
|-----|---------|---------|
| superfile | `spf` | 1.6.0-1.1 |
| concord | `concord` | 2.6.1 (`concord-bin`) |
| lynx | `lynx` | 2.9.3-1.1 |
| neovim | `nvim` | 0.12.5-1.1 |
| caligula | `caligula` | 0.5.0-1.1 |
| neomutt | `neomutt` | 1:20260616-1.1 |
| valvefm | `valvefm` | 0.1.8, `/usr/local/bin` |
| steam-tui | `steam-tui` | 0.3.0b-6 |

valvefm is not packaged. The TUI-only binary's sha256 matched the
v0.1.8 release. steam-tui still starts the real Steam client for
games that need it. Run `steamcmd` once before the first `steam-tui`.
Super+Shift+D stays the Electron Discord app. Delorean was not
installed.

kitty 0.49.2-1.1 is the everyday terminal. Super+Return opens it,
and Fuzzel uses it for `Terminal=true` apps.

## Super alone does nothing

Applied 2026-10-07 on Novalis. keyd no longer turns a short Super
press into Super+Space, and it no longer grabs the mouse. Super+Space
still opens the launcher. The bar chip still opens it. The Keychron
F-key maps stay.

Delorean still opens the menu on Super release. That note is on
`omarchy-delorean/docs/next.md`.
