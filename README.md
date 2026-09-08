# cachyos-gaming

Dotfiles and rebuild notes for **niri on CachyOS** (hostname: Novalis).

If this machine is wiped, install CachyOS again with the niri + noctalia desktop, clone or copy this repo, then run:

```bash
cd ~/Projects/cachyos-gaming
./setup.sh
```

That installs `packages/extra.txt` (CachyOS/Arch repos) and `packages/aur.txt` (via paru), then points `~/.config/niri` and `~/.config/noctalia` at the copies in this repo.

## Layout

| Path | What it is |
| --- | --- |
| `setup.sh` | Fresh-install bootstrap |
| `configs/niri` | niri config (live, via symlink) |
| `configs/noctalia` | noctalia-shell config (live, via symlink) |
| `configs/noctalia/palettes/Novalis.json` | Gunmetal + energy-green palette |
| `configs/noctalia/wallpapers/` | Rain, ship, dock, construct, blue flower |
| `configs/niri-screensaver` | Falling-code screensaver (TTE Matrix) |
| `configs/keyd` | Super-tap → launcher (`/etc/keyd/default.conf`) |
| `packages/extra.txt` | Extra **repo** packages (pacman), including `paru` |
| `packages/aur.txt` | Extra **AUR** packages (`google-chrome`, `visual-studio-code-bin`, …) |
| `packages/baseline/` | Snapshot of explicitly installed packages on day 0 |
| `records/journal.md` | Human log of installs and setup runs |
| `records/hardware.md` | This machine's hardware |
| `records/gaming.md` | Steam / Heroic / Proton notes |
| `records/next.md` | Working list; dump obstacles in `os-notes.txt` |
| `records/keybinds.md` | Super-key table: Windows, Novalis, Delorean |
| `os-notes.txt` | Scratch inbox, emptied after triage |
| `scripts/pkg-add.sh` | Install a package *and* record it |
| `scripts/launch-webapp.sh` | Title-less Chrome `--app=URL` (profile still under `~/.local/share/borg`) |
| `scripts/launch-or-focus-webapp.sh` | Focus that window, or launch it |
| `scripts/launch-discord.sh` | Super+D: focus Discord, skip the updater splash |
| `scripts/launch-btop.sh` | Super+Ctrl+T: floating btop (focus, or close if focused) |
| `scripts/launch-grok-bot.sh` | Super+Shift+Alt+A: focus or launch Grok Bot |

## Day-to-day

**Install something you want on the next rebuild:**

```bash
./scripts/pkg-add.sh steam gamemode
```

Repo packages go through pacman into `packages/extra.txt`. Anything not in a sync database is treated as AUR, installed with paru, and recorded in `packages/aur.txt`.

**Edit niri / noctalia:** change files under `configs/`. They are the live configs. Commit when it feels right.

**Wallpapers:** Super+Shift+Return opens the picker. Files live in
`configs/noctalia/wallpapers/` (rain, ship, dock, construct, blue flower,
and the extra rain/ship stills). Old Borg stills are in
`configs/noctalia/archive-borg-wallpapers/`.

**OS notes:** dump obstacles and wants in `os-notes.txt` (plain text, no
structure). Hand the file over; they get triaged into `records/next.md`.
Done items move into `journal.md` / `gaming.md` / `hardware.md` and come
off `next.md`. The inbox is emptied after that. Same loop as
[omarchy-delorean](https://github.com/willyfresh/omarchy-delorean), with
`records/` instead of `docs/`.

**Refresh the package snapshot** (optional, for comparison later):

```bash
./scripts/snapshot-packages.sh
```

**If you ever copy live configs back into the repo** (only needed if the symlinks were replaced):

```bash
./scripts/pull-configs.sh
./scripts/apply-configs.sh
```

## Start-over checklist

1. Install CachyOS, niri + noctalia desktop, NVIDIA open drivers (this box is an RTX 2060).
2. Create user `willyfresh`, put this repo at `~/Projects/cachyos-gaming`.
3. `./setup.sh`
4. Log in on niri and confirm both ASUS VE247 monitors come up (see `records/hardware.md`).
