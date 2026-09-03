#!/usr/bin/env bash
# Shared helpers for cachyos-gaming scripts.

set -euo pipefail

if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  _LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  _LIB_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
REPO_ROOT="$(cd "$_LIB_DIR/.." && pwd)"
unset _LIB_DIR

CONFIGS_DIR="$REPO_ROOT/configs"
PACKAGES_DIR="$REPO_ROOT/packages"
RECORDS_DIR="$REPO_ROOT/records"
BACKUP_DIR="$RECORDS_DIR/backups"
EXTRA_PKGS="$PACKAGES_DIR/extra.txt"
JOURNAL="$RECORDS_DIR/journal.md"

log()  { printf '==> %s\n' "$*"; }
warn() { printf '!!  %s\n' "$*" >&2; }
die()  { warn "$*"; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

# Read a package list file: one name per line, skip blanks and # comments.
read_pkg_list() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  awk 'NF && $1 !~ /^#/ { print $1 }' "$file" | sort -u
}

# Append a dated section to the journal.
journal_append() {
  local title="$1"
  local body="$2"
  local day
  day="$(date +%F)"
  mkdir -p "$RECORDS_DIR"
  if [[ ! -f "$JOURNAL" ]]; then
    printf '# Journal\n\nA running record of installs and config changes.\n' > "$JOURNAL"
  fi
  {
    printf '\n## %s — %s\n\n' "$day" "$title"
    printf '%s\n' "$body"
  } >> "$JOURNAL"
}

# If dest is already a symlink to src, do nothing. Otherwise back dest up
# (when it exists) and replace it with a symlink to src.
link_path() {
  local src="$1"
  local dest="$2"
  local stamp dest_name backup

  [[ -e "$src" || -L "$src" ]] || die "link source missing: $src"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink -f "$dest" || true)"
    local target
    target="$(readlink -f "$src" || true)"
    if [[ "$current" == "$target" ]]; then
      log "already linked: $dest -> $src"
      return 0
    fi
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    stamp="$(date +%Y%m%d-%H%M%S)"
    dest_name="$(basename "$dest")"
    backup="$BACKUP_DIR/$stamp/$dest_name"
    mkdir -p "$(dirname "$backup")"
    log "backing up $dest -> $backup"
    mv "$dest" "$backup"
  else
    mkdir -p "$(dirname "$dest")"
  fi

  log "linking $dest -> $src"
  ln -s "$src" "$dest"
}

# Copy a live config into the repo. If live is already a symlink into the
# repo, there is nothing to pull.
pull_path() {
  local live="$1"
  local dest="$2"

  if [[ ! -e "$live" && ! -L "$live" ]]; then
    warn "skip (missing): $live"
    return 0
  fi

  if [[ -L "$live" ]]; then
    local current target
    current="$(readlink -f "$live" || true)"
    target="$(readlink -f "$dest" || true)"
    if [[ "$current" == "$target" ]]; then
      log "live already points at repo: $live"
      return 0
    fi
  fi

  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    rm -rf "$dest"
  fi
  log "copying $live -> $dest"
  cp -a "$live" "$dest"
}
