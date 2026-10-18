# cachyos-gaming

Dotfiles and rebuild notes for **Hyprland on CachyOS** (hostname: Novalis).

If this machine is wiped, install CachyOS again, clone or copy this repo, then run:

```bash
cd ~/Projects/cachyos-gaming
./setup.sh
```

That installs `packages/extra.txt` (CachyOS/Arch repos) and `packages/aur.txt` (via paru), then points `~/.config` at the copies in this repo.

## Layout

| Path | What it is |
| --- | --- |
| `setup.sh` | Fresh-install bootstrap |
| `configs/xdg-desktop-portal/hyprland-portals.conf` | GTK file chooser when the desktop is Hyprland |
| `configs/hypr/hyprland.lua` | Hyprland dwindle config (live file symlink) |
| `configs/waybar` | Hyprland bar (live, via symlink). Bottom of both screens |
| `scripts/install-hyprland.sh` | From the tty prompt: install Hyprland and link that config |
| `configs/bash_profile` | tty1 login stays a shell (live `~/.bash_profile`, via symlink). Type `start-hyprland` |
| `configs/hypr/wallpapers/` | Fractal wallpapers. Super+Shift+Return picks one |
| `configs/keyd` | Keychron media and knob keys (`/etc/keyd/default.conf`). Super alone does nothing |
| `configs/nvim` | LazyVim (live `~/.config/nvim`, via symlink). Plugin downloads stay in `~/.local/share/nvim` |
| `configs/mimeapps.list` | Default apps: Zathura for PDFs, swayimg for images, Chrome for the web |
| `configs/lsfg-vk/conf.toml` | Frame-generation profiles (live file symlink) |
| `configs/MangoHud/MangoHud.conf` | In-game HUD (live file symlink) |
| `packages/extra.txt` | Extra **repo** packages (pacman), including `paru` |
| `packages/aur.txt` | Extra **AUR** packages (`google-chrome`, `visual-studio-code-bin`, …) |
| `packages/baseline/` | Snapshot of explicitly installed packages on day 0 |
| `records/journal.md` | Decisions that still matter. New installs append here |
| `records/hardware.md` | This machine's hardware |
| `records/gaming.md` | Steam / Heroic / Proton notes |
| `records/next.md` | Open work only. Dump obstacles in `os-notes.txt` |
| `records/keybinds.md` | Super-key table: Windows, Novalis, Delorean |
| `os-notes.txt` | Scratch inbox, emptied after triage |
| `scripts/pkg-add.sh` | Install a package *and* record it |
| `scripts/launch-webapp.sh` | Title-less Chrome `--app=URL` (profile still under `~/.local/share/borg`) |
| `scripts/launch-or-focus-webapp.sh` | Focus a title-less webapp, or launch it |
| `scripts/launch-or-focus-app.sh` | Focus a native app by window class, or launch it |
| `scripts/launch-discord.sh` | Super+Shift+D: focus Discord, skip the updater splash |
| `scripts/launch-youtube.sh` | Super+Shift+Y YouTube Music. Super+Shift+Ctrl+Y YouTube |
| `scripts/launch-steam.sh` | Super+Shift+S: focus Steam, skip notification toasts |
| `scripts/launch-btop.sh` | Super+Ctrl+T and Super+Shift+T: tiled btop. Super+Shift+Ctrl+T: nvtop |
| `scripts/launch-grok-bot.sh` | Super+Shift+A, and the Keychron triangle: focus or launch Grok Bot |

## Day-to-day

**Install something you want on the next rebuild:**

```bash
./scripts/pkg-add.sh package-name
```

Repo packages go through pacman into `packages/extra.txt`. Anything not in a sync database is treated as AUR, installed with paru, and recorded in `packages/aur.txt`.

**Edit configs:** change files under `configs/`. The linked ones are live. Commit when it feels right.

**Wallpapers:** Super+Shift+Return opens the picker. Files live in
`configs/hypr/wallpapers/`.

**OS notes:** dump obstacles and wants in `os-notes.txt` (plain text, no
structure). Hand the file over. Open items go on `records/next.md` and
come off when they are done. A decision that the configs do not already
show goes in `journal.md`, `gaming.md`, or `hardware.md`. The inbox is
emptied after that. Same loop as
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

1. Install CachyOS with NVIDIA open drivers (this box is an RTX 2060).
2. Create user `willyfresh`, put this repo at `~/Projects/cachyos-gaming`.
3. `./setup.sh`
4. Confirm both ASUS VE247 monitors come up (see `records/hardware.md`).
5. `./setup.sh` links `~/.bash_profile` at `configs/bash_profile`. tty1 is a shell. Type `start-hyprland`. Waybar starts with Hyprland. Do not `exec` that command from `bash_profile`.
