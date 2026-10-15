#!/usr/bin/env bash
# Show one mail attachment in the current kitty. Neomutt redraws when
# this returns, which clears the picture, so wait before exiting.
if [[ $# -ne 1 || ! -f $1 ]]; then
  printf 'neomutt-icat: need an image file\n' >&2
  exit 1
fi
if [[ -z ${KITTY_WINDOW_ID:-} ]]; then
  printf 'Image preview needs kitty. This terminal cannot draw it.\n' >&2
  read -r -p "Press Enter to return. "
  exit 1
fi
kitty +kitten icat --silent --transfer-mode=stream --stdin=no -- "$1"
printf '\n'
read -r -p "Press Enter to return. "
