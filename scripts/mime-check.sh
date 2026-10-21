#! /bin/bash

file="configs/yazi/yazi.toml"

mime=$(xdg-mime query filetype "$file")
printf 'MIME type: %s\n' "$mime"

# xdg-mime query default "$mime"
# xdg-open "$file"
gio launch /usr/share/applications/nvim.desktop "$file"