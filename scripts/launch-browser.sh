#!/usr/bin/env bash
# Open a link in the default browser and focus that window.
# The desktop portal starts the browser with no activation token, so a new
# tab in an already-open Chrome never comes forward. Hyprland focuses a
# window only when something asks. This handler asks.
# usage: launch-browser.sh [url...]
set -euo pipefail

# mimeapps.list names the browser. The Hyprland list names this script.
browser="$(env -u BROWSER XDG_CURRENT_DESKTOP= xdg-mime query default x-scheme-handler/https 2>/dev/null || true)"
if [[ -z $browser || $browser == novalis-browser.desktop ]]; then
  browser="$(env -u BROWSER XDG_CURRENT_DESKTOP= xdg-mime query default x-scheme-handler/http 2>/dev/null || true)"
fi
if [[ -z $browser || $browser == novalis-browser.desktop ]]; then
  browser="google-chrome.desktop"
fi

bin=""
for dir in "${XDG_DATA_HOME:-$HOME/.local/share}" "$HOME/.nix-profile/share" /usr/share; do
  desktop="$dir/applications/$browser"
  if [[ -f $desktop ]]; then
    bin="$(sed -n 's/^Exec=\([^ ]*\).*/\1/p' "$desktop" | head -1)"
    [[ -n $bin ]] && break
  fi
done

if [[ -z $bin ]] && command -v google-chrome-stable >/dev/null 2>&1; then
  bin="google-chrome-stable"
fi

if [[ -z $bin ]]; then
  echo "launch-browser: no browser for $browser" >&2
  exit 1
fi

case "$(basename "$bin")" in
  google-chrome | google-chrome-stable) class_rx='^google-chrome$' ;;
  chromium | chromium-browser) class_rx='^chromium$' ;;
  brave | brave-browser) class_rx='^brave-browser$' ;;
  microsoft-edge | microsoft-edge-stable) class_rx='^microsoft-edge$' ;;
  firefox | firefox-bin) class_rx='^firefox$' ;;
  *) class_rx="^$(basename "$bin")$" ;;
esac

window_address() {
  CLASS_RX="$class_rx" python3 - <<'PY' || true
import json, os, re, subprocess, sys

try:
    rx = re.compile(os.environ["CLASS_RX"], re.I)
    windows = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
except (OSError, subprocess.CalledProcessError, json.JSONDecodeError, re.error):
    sys.exit(1)

matches = [w for w in windows if rx.fullmatch(w.get("class") or "")]
if not matches:
    sys.exit(1)
matches.sort(key=lambda w: w.get("focusHistoryID") if isinstance(w.get("focusHistoryID"), int) else 10**9)
address = matches[0].get("address") or ""
if not address:
    sys.exit(1)
print(address)
PY
}

focus_address() {
  local address="$1"
  [[ -n $address ]] || return 1
  hyprctl dispatch "hl.dsp.focus({ window = \"address:${address}\" })" >/dev/null
}

# The window Chrome already has is the one that receives the tab.
# Wait for that handoff, then focus it. A cold start keeps running, so
# detach that one and focus the window once it maps.
existing="$(window_address)"
if [[ -n $existing ]]; then
  if (($#)); then
    timeout 5 "$bin" "$@" >/dev/null 2>&1 || true
  fi
  focus_address "$(window_address)" || focus_address "$existing" || true
  exit 0
fi

setsid -f "$bin" "$@" >/dev/null 2>&1 || true
for _ in $(seq 1 60); do
  existing="$(window_address)"
  if [[ -n $existing ]]; then
    focus_address "$existing" || true
    exit 0
  fi
  sleep 0.05
done
exit 0
