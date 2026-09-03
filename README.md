# cachyos-gaming

Dotfiles and rebuild notes for **niri on CachyOS** (hostname: Borg).

If this machine is wiped, install CachyOS again with the niri + noctalia desktop, clone or copy this repo, then run:

```bash
cd ~/Projects/cachyos-gaming
./setup.sh
```

That installs whatever is listed in `packages/extra.txt` and points `~/.config/niri` and `~/.config/noctalia` at the copies in this repo.

## Layout

| Path | What it is |
| --- | --- |
| `setup.sh` | Fresh-install bootstrap |
| `configs/niri` | niri config (live, via symlink) |
| `configs/noctalia` | noctalia-shell config (live, via symlink) |
| `packages/extra.txt` | Extra packages to install on top of stock CachyOS niri |
| `packages/baseline/` | Snapshot of explicitly installed packages on day 0 |
| `records/journal.md` | Human log of installs and setup runs |
| `records/hardware.md` | This machine's hardware |
| `scripts/pkg-add.sh` | Install a package *and* record it |

## Day-to-day

**Install something you want on the next rebuild:**

```bash
./scripts/pkg-add.sh steam gamemode
```

That runs `pacman -S --needed`, appends the name to `packages/extra.txt`, and writes a journal entry.

**Edit niri / noctalia:** change files under `configs/`. They are the live configs. Commit when it feels right.

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
