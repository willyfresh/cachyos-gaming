#!/usr/bin/env bash
# Install packages, record them in extra.txt (repos) or aur.txt (AUR), and journal.
#
# Repo packages go through pacman. Anything not in a sync db is treated as AUR
# and installed with paru (installed from the CachyOS repos if missing).
#
# Usage: ./scripts/pkg-add.sh steam lutris google-chrome

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [[ $# -lt 1 ]]; then
  die "usage: $0 <package> [package...]"
fi

need_cmd pacman
mkdir -p "$PACKAGES_DIR"
touch "$EXTRA_PKGS"
touch "$AUR_PKGS"

repo_install=()
aur_install=()
repo_new=()
aur_new=()

for p in "$@"; do
  if pkg_is_repo "$p"; then
    repo_install+=("$p")
    if list_has_pkg "$EXTRA_PKGS" "$p"; then
      log "already in extra.txt: $p"
    else
      repo_new+=("$p")
    fi
  else
    aur_install+=("$p")
    if list_has_pkg "$AUR_PKGS" "$p"; then
      log "already in aur.txt: $p"
    else
      aur_new+=("$p")
    fi
  fi
done

if ((${#repo_install[@]})); then
  log "installing from repos: ${repo_install[*]}"
  sudo pacman -S --needed "${repo_install[@]}"
fi

if ((${#aur_install[@]})); then
  ensure_paru
  log "installing from AUR: ${aur_install[*]}"
  paru -S --needed --skipreview --removemake --sudoloop "${aur_install[@]}"
fi

for p in "${repo_new[@]+"${repo_new[@]}"}"; do
  [[ -n "$p" ]] || continue
  append_pkg "$EXTRA_PKGS" "$p"
  log "appended to extra.txt: $p"
done

for p in "${aur_new[@]+"${aur_new[@]}"}"; do
  [[ -n "$p" ]] || continue
  append_pkg "$AUR_PKGS" "$p"
  log "appended to aur.txt: $p"
done

journal_append "installed $*" "$(cat <<EOF
- requested: $*
- repos (pacman): ${repo_install[*]:-(none)}
- AUR (paru): ${aur_install[*]:-(none)}
EOF
)"
log "journaled in $JOURNAL"
