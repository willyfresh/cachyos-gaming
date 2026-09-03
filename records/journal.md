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
