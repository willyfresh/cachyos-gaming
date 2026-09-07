#!/usr/bin/env bash
# Title-less Chrome --app window with a persistent profile.
# Default-profile --app windows are throwaway: Chrome drops their site data
# when that window closes. A dedicated user-data-dir keeps cookies on disk.
# Do not attach to the running Super+B browser — a second process is required
# so --user-data-dir / --app actually take effect.
# Never use --app-id: real PWAs draw a CSD title bar niri cannot strip.
set -euo pipefail

if (($# < 1)); then
  echo "Usage: $0 <url> [chrome-flags...]" >&2
  exit 1
fi

profile="${BORG_CHROME_WEBAPP_DIR:-$HOME/.local/share/borg/chrome-webapps}"
mkdir -p "$profile"

browser=$(xdg-settings get default-web-browser 2>/dev/null || true)
case $browser in
  google-chrome* | brave* | microsoft-edge* | opera* | vivaldi* | helium* | chromium*) ;;
  *) browser="google-chrome.desktop" ;;
esac

bin=""
for dir in "${XDG_DATA_HOME:-$HOME/.local/share}" "$HOME/.nix-profile/share" /usr/share; do
  desktop="$dir/applications/$browser"
  if [[ -f $desktop ]]; then
    bin=$(sed -n 's/^Exec=\([^ ]*\).*/\1/p' "$desktop" | head -1)
    [[ -n $bin ]] && break
  fi
done

if [[ -z $bin ]] && command -v google-chrome-stable >/dev/null 2>&1; then
  bin="google-chrome-stable"
fi

if [[ -z $bin ]]; then
  echo "No Chrome-family browser on PATH" >&2
  exit 1
fi

# Default in this user-data-dir is the signed-in webapp session.
# Links out of --app windows open here. Window class suffix is
# chrome-*.Default — distinct from Super+B because this is a
# different user-data-dir.
exec setsid "$bin" \
  --user-data-dir="$profile" \
  --profile-directory=Default \
  --no-first-run \
  --no-default-browser-check \
  --hide-crash-restore-bubble \
  --app="$1" \
  "${@:2}"
