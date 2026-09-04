#!/usr/bin/env bash
# Install system-level files that cannot live as user symlinks (needs sudo).

set -euo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

need_cmd sudo

KEYD_SRC="$CONFIGS_DIR/keyd/default.conf"
KEYD_DEST="/etc/keyd/default.conf"

if [[ -f "$KEYD_SRC" ]]; then
  log "installing $KEYD_DEST"
  sudo install -d /etc/keyd
  sudo install -m644 "$KEYD_SRC" "$KEYD_DEST"
  sudo systemctl enable --now keyd.service
  sudo systemctl restart keyd.service
  log "keyd is active (Super tap -> launcher)"
fi

if systemctl list-unit-files systemd-timesyncd.service >/dev/null 2>&1; then
  log "enabling systemd-timesyncd (Xbox Live / HTTPS need a sane clock)"
  sudo systemctl enable --now systemd-timesyncd.service
fi

log "system configs applied"
