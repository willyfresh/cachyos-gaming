#!/usr/bin/env bash
# Refresh the package snapshots under packages/baseline/.

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

need_cmd pacman
mkdir -p "$PACKAGES_DIR/baseline"

pacman -Qqe > "$PACKAGES_DIR/baseline/explicit.txt"
pacman -Qe  > "$PACKAGES_DIR/baseline/explicit-versions.txt"
pacman -Qqm > "$PACKAGES_DIR/baseline/foreign.txt" || true

log "wrote $PACKAGES_DIR/baseline/"
log "explicit: $(wc -l < "$PACKAGES_DIR/baseline/explicit.txt") packages"
