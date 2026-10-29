#!/usr/bin/env bash
# Super+Shift+Return. Pick any image. The path is stored outside the repo.
set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
state_file="$state_dir/wallpaper"
wallpaper_py="/home/willyfresh/Projects/cachyos-gaming/configs/hypr/wallpaper.py"
pictures="${HOME}/Dropbox/Pictures/Wallpaper"

wallpaper_pids() {
    ps -C python3 -o pid=,args= | awk '/\/configs\/hypr\/wallpaper\.py/ {print $1}'
}

apply() {
    local path=$1
    if [[ ! -f $path ]]; then
        echo "not a file: $path" >&2
        exit 1
    fi
    path=$(realpath "$path")
    mkdir -p "$state_dir"
    printf '%s\n' "$path" >"$state_file"
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
    apply "$1"
    exit 0
fi

if [[ ! -d $pictures ]]; then
    pictures="${HOME}/Dropbox"
fi

choice=$(
    zenity --file-selection \
        --title="Wallpaper" \
        --filename="${pictures}/" \
        --file-filter="Images | *.png *.jpg *.jpeg *.webp *.gif *.PNG *.JPG *.JPEG *.WEBP *.GIF" \
        --file-filter="All | *"
) || exit 0

apply "$choice"
