#!/usr/bin/env bash
# Bootstrap this CachyOS niri setup after a reinstall.
#
# Usage:
#   ./setup.sh                 # install extra packages + apply configs
#   ./setup.sh --packages-only
#   ./setup.sh --configs-only
#   ./setup.sh -h

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$REPO_ROOT/scripts/lib.sh"

usage() {
  cat <<'EOF'
Bootstrap cachyos-gaming on a CachyOS niri install.

  ./setup.sh                 install extra packages and apply configs
  ./setup.sh --packages-only install packages listed in packages/extra.txt
  ./setup.sh --configs-only  symlink configs/ into ~/.config
  ./setup.sh -h              show this help

Assumes CachyOS was installed with the niri + noctalia desktop. This script
does not reinstall the base system — only extras and your configs.

To add packages later:  ./scripts/pkg-add.sh <packages...>
EOF
}

do_packages=1
do_configs=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --packages-only) do_configs=0 ;;
    --configs-only)  do_packages=0 ;;
    -h|--help)       usage; exit 0 ;;
    *)               die "unknown argument: $1 (see --help)" ;;
  esac
  shift
done

if ((do_packages)); then
  need_cmd pacman
  mapfile -t pkgs < <(read_pkg_list "$EXTRA_PKGS")
  if ((${#pkgs[@]} == 0)); then
    log "no extra packages in packages/extra.txt"
  else
    log "installing extra packages: ${pkgs[*]}"
    sudo pacman -S --needed "${pkgs[@]}"
  fi
fi

if ((do_configs)); then
  "$REPO_ROOT/scripts/apply-configs.sh"
fi

journal_append "ran setup.sh" "$(cat <<EOF
- packages: $( ((do_packages)) && echo yes || echo skipped )
- configs: $( ((do_configs)) && echo yes || echo skipped )
- host: $(hostname)
EOF
)"

log "done. extra packages and config links are in place."
log "journal: $JOURNAL"
