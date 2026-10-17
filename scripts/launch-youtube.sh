#!/usr/bin/env bash
# Super+Shift+Y focuses or launches YouTube Music.
# Super+Shift+Ctrl+Y focuses or launches YouTube.
# usage: launch-youtube.sh music|youtube
set -euo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
mode="${1:-music}"

case "$mode" in
  music)
    exec "$ROOT/launch-or-focus-webapp.sh" 'chrome-music\.youtube\.com' 'https://music.youtube.com/'
    ;;
  youtube)
    exec "$ROOT/launch-or-focus-webapp.sh" 'chrome-(www\.)?youtube\.com' 'https://www.youtube.com/'
    ;;
  *)
    echo "usage: $0 music|youtube" >&2
    exit 1
    ;;
esac
