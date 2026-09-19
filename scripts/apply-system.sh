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

UDEV_SRC="$CONFIGS_DIR/udev/99-keychron-v6-via.rules"
UDEV_DEST="/etc/udev/rules.d/99-keychron-v6-via.rules"
if [[ -f "$UDEV_SRC" ]]; then
  log "installing $UDEV_DEST"
  sudo install -m644 "$UDEV_SRC" "$UDEV_DEST"
  sudo udevadm control --reload-rules
  sudo udevadm trigger --subsystem-match=hidraw --action=add
fi

VIA_SCRIPT="$REPO_ROOT/scripts/keychron-v6-via.py"
if [[ -x "$VIA_SCRIPT" ]] || [[ -f "$VIA_SCRIPT" ]]; then
  chmod +x "$VIA_SCRIPT"
  log "programming Keychron V6 VIA keymap (Windows layer)"
  if sudo python3 "$VIA_SCRIPT"; then
    log "V6 keymap written"
  else
    warn "V6 VIA write failed; run: sudo python3 $VIA_SCRIPT"
  fi
fi

if systemctl list-unit-files systemd-timesyncd.service >/dev/null 2>&1; then
  log "enabling systemd-timesyncd (Xbox Live / HTTPS need a sane clock)"
  sudo systemctl enable --now systemd-timesyncd.service
fi

# Hovercraft nameplate. Pretty hostname is Novalis; /etc/hosts 127.0.1.1
# must match or sudo and some local TLS break.
if [[ "$(hostname)" != "Novalis" ]]; then
  log "setting hostname Borg -> Novalis"
  sudo hostnamectl set-hostname Novalis
fi
if grep -qE '(^|[[:space:]])Borg([[:space:]]|$)' /etc/hosts; then
  log "rewriting Borg -> Novalis in /etc/hosts"
  sudo sed -i -E 's/(^|[[:space:]])Borg([[:space:]]|$)/\1Novalis\2/g' /etc/hosts
fi

log "system configs applied"
