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
  log "keyd is active (Keychron media and knob; Super alone does nothing)"
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

# Tailscale is in packages/extra.txt. The package does not enable the
# daemon. The operator is whoever runs this script, so later `tailscale up`
# needs no root. Joining the tailnet stays a browser login. No account
# name and no auth key are written down.
if pacman -Q tailscale >/dev/null 2>&1; then
  log "enabling tailscaled"
  sudo systemctl enable --now tailscaled.service
  if [[ -n "${USER:-}" && "$USER" != "root" ]]; then
    sudo tailscale set --operator="$USER"
  else
    warn "tailscaled is up; run tailscale set --operator as the login user before tailscale up"
  fi
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

# After a kernel update, refuse a quiet reboot if the Limine menu names
# a file that is not on /boot. The hook runs after limine-mkinitcpio.
LIMINE_CHECK="$REPO_ROOT/scripts/check-limine-boot.sh"
LIMINE_HOOK_SRC="$CONFIGS_DIR/pacman/hooks/99-limine-boot-files.hook"
if [[ -f "$LIMINE_CHECK" && -f "$LIMINE_HOOK_SRC" ]]; then
  log "installing Limine boot-file check"
  sudo install -m755 "$LIMINE_CHECK" /usr/local/bin/check-limine-boot.sh
  sudo install -d /etc/pacman.d/hooks
  sudo install -m644 "$LIMINE_HOOK_SRC" /etc/pacman.d/hooks/99-limine-boot-files.hook
fi

log "system configs applied"
