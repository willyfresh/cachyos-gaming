# Next

Scratch notes from `os-notes.txt` land here after triage.
Dump obstacles in that file, then hand it over. This page is the working
list. Done items move into `journal.md` / `gaming.md` / `hardware.md` and
come off this page.

| Want | Who | Status |
|------|-----|--------|
| Halo Infinite Xbox Live login | you | tabled |
| Board Game Arena freezes in the WebKit window | you | tabled |
| Steam menus flash and close | you | accepted / tabled |
| Fullscreen windows swap on a mouse overshoot | you confirm | applied `max-scroll-amount="0%"` |
| For Honor / Ubisoft Connect | you | tabled |

## Halo Infinite Xbox Live login

Titled **Steam Big Picture Mode** (1280×800), not a Halo window. Keep that
overlay focused on the left (primary) monitor; do not exclusive-fullscreen
Halo while signing in. Launch options and the NVIDIA/Xalia notes live in
`gaming.md`. Pick this back up when you want another pass.

## Board Game Arena freezes in the WebKit window

The chrome-less window is `scripts/board-game-arena` (GTK4 + WebKit), not
Chrome. Chrome PWAs always draw their own title bar and a custom tab bar
when the page is out of app scope; niri cannot strip those. Login cookies
are under `~/.local/share/board-game-arena/` (separate from Chrome). Frozen
page is tabled with Halo.

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
