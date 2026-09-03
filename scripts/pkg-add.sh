#!/usr/bin/env bash
# Install packages with pacman, add them to packages/extra.txt, and journal it.
#
# Usage: ./scripts/pkg-add.sh steam lutris gamemode

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [[ $# -lt 1 ]]; then
  die "usage: $0 <package> [package...]"
fi

need_cmd pacman
mkdir -p "$PACKAGES_DIR"
touch "$EXTRA_PKGS"

mapfile -t existing < <(read_pkg_list "$EXTRA_PKGS")
declare -A have=()
for p in "${existing[@]+"${existing[@]}"}"; do
  [[ -n "$p" ]] && have["$p"]=1
done

new=()
for p in "$@"; do
  if [[ -n "${have[$p]:-}" ]]; then
    log "already in extra.txt: $p"
  else
    new+=("$p")
  fi
done

log "installing: $*"
sudo pacman -S --needed "$@"

if ((${#new[@]})); then
  {
    printf '\n# %s\n' "$(date +%F)"
    printf '%s\n' "${new[@]}"
  } >> "$EXTRA_PKGS"
  log "appended to extra.txt: ${new[*]}"
fi

journal_append "installed $*" "$(printf -- '- pacman -S --needed %s\n' "$*")"
log "journaled in $JOURNAL"
