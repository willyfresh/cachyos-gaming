#!/usr/bin/env bash
# Super+Shift+Return. Pick a color of the fractal wallpaper.
# Same chord as niri's wallpaper picker. This one does not start Noctalia.
set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
state_file="$state_dir/wallpaper"
wallpaper_py="/home/willyfresh/Projects/cachyos-gaming/configs/hypr/wallpaper.py"

wallpaper_pids() {
    ps -C python3 -o pid=,args= | awk '/\/configs\/hypr\/wallpaper\.py/ {print $1}'
}

apply() {
    local name=$1
    mkdir -p "$state_dir"
    printf '%s\n' "$name" >"$state_file"
    local pid
    for pid in $(wallpaper_pids); do
        kill "$pid" 2>/dev/null || true
    done
    local _try
    for _try in $(seq 1 50); do
        [[ -z $(wallpaper_pids) ]] && break
        sleep 0.1
    done
    hyprctl dispatch "hl.dsp.exec_cmd(\"python3 $wallpaper_py\")" >/dev/null
}

if [[ $# -gt 0 ]]; then
    case $1 in
        fall | greens | sky | relaxing) apply "$1" ;;
        *)
            echo "usage: hypr-wallpaper.sh [fall|greens|sky|relaxing]" >&2
            exit 1
            ;;
    esac
    exit 0
fi

current=fall
if [[ -f $state_file ]]; then
    current=$(tr -d '[:space:]' <"$state_file")
fi

mark() {
    if [[ $1 == "$current" ]]; then
        printf '%s  (on)\n' "$2"
    else
        printf '%s\n' "$2"
    fi
}

choice=$(
    {
        mark fall Fall
        mark greens Greens
        mark sky Sky
        mark relaxing Relaxing
    } | fuzzel --dmenu --prompt "Wallpaper  " --placeholder "color" --width 28 --lines 4
) || exit 0

case ${choice%%  (on)} in
    Fall) apply fall ;;
    Greens) apply greens ;;
    Sky) apply sky ;;
    Relaxing) apply relaxing ;;
    *) exit 0 ;;
esac
