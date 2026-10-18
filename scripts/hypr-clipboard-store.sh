#!/usr/bin/env bash
# One cliphist row per copy. A raster image is kept and the text that
# came with it is skipped. Text is stored as UTF-8.
#   wl-paste --watch hypr-clipboard-store.sh
#   hypr-clipboard-store.sh --menu       clean the Fuzzel list
#   hypr-clipboard-store.sh --normalize  UTF-16 bytes in, UTF-8 out
set -euo pipefail

python_filter() {
  # The program is an argument so stdin stays the clipboard bytes.
  local program
  program=$(cat <<'PY'
import subprocess
import sys

mode = sys.argv[1]


def looks_utf16(data, high_odd):
    if len(data) < 4 or len(data) % 2:
        return False
    chars = len(data) // 2
    odd = sum(data[i] == 0 for i in range(1, len(data), 2))
    even = sum(data[i] == 0 for i in range(0, len(data), 2))
    if high_odd:
        return odd >= chars * 0.6 and even <= chars * 0.2
    return even >= chars * 0.6 and odd <= chars * 0.2


def to_utf8(data, mime):
    mime = (mime or "").lower().replace(" ", "")
    try:
        if data.startswith(b"\xff\xfe") or data.startswith(b"\xfe\xff"):
            return data.decode("utf-16").encode()
        if "utf-16be" in mime or "utf-16-be" in mime:
            return data.decode("utf-16-be").encode()
        if "utf-16" in mime or looks_utf16(data, True):
            return data.decode("utf-16-le").encode()
        if looks_utf16(data, False):
            return data.decode("utf-16-be").encode()
    except UnicodeError:
        return data
    return data


def preview(data):
    text = to_utf8(data, "").decode("utf-8", "replace")
    text = " ".join(text.split())
    if len(text) > 100:
        text = text[:100] + "…"
    return text.encode()


if mode == "normalize":
    mime = sys.argv[2] if len(sys.argv) > 2 else ""
    sys.stdout.buffer.write(to_utf8(sys.stdin.buffer.read(), mime))
elif mode == "menu":
    raw = sys.stdin.buffer.read()
    for line in raw.split(b"\n"):
        if not line:
            continue
        if b"\x00" not in line:
            sys.stdout.buffer.write(line + b"\n")
            continue
        ident, _, _ = line.partition(b"\t")
        full = subprocess.check_output(["cliphist", "decode"], input=line + b"\n")
        sys.stdout.buffer.write(ident + b"\t" + preview(full) + b"\n")
PY
)
  python3 -c "$program" "$@"
}

choose_mime() {
  local types="$1"
  shift
  local want line
  for want in "$@"; do
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ -z "$line" ]] && continue
      if [[ "${line,,}" == "${want,,}" ]]; then
        printf '%s\n' "$line"
        return 0
      fi
    done <<<"$types"
  done
  return 1
}

if [[ "${1:-}" == "--normalize" ]]; then
  python_filter normalize "${CLIP_MIME:-}"
  exit 0
fi

if [[ "${1:-}" == "--menu" ]]; then
  python_filter menu
  exit 0
fi

# The watch pipe is one offered type. Drain it before asking again.
cat >/dev/null || true

case "${CLIPBOARD_STATE:-data}" in
  sensitive | nil)
    exit 0
    ;;
  clear)
    cliphist store
    exit 0
    ;;
esac

types=$(wl-paste --list-types 2>/dev/null || true)
[[ -n "$types" ]] || exit 0

image_mime=$(choose_mime "$types" \
  image/png image/jpeg image/jpg image/webp image/gif image/bmp image/tiff) || true
if [[ -n "$image_mime" ]]; then
  wl-paste --no-newline --type "$image_mime" | cliphist store
  exit 0
fi

text_mime=$(choose_mime "$types" \
  'text/plain;charset=utf-8' \
  'UTF8_STRING' \
  'text/plain' \
  'text/plain;charset=utf-16le' \
  'text/plain;charset=utf-16' \
  'text/plain;charset=utf-16be' \
  'text/html') || true
if [[ -z "$text_mime" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "${line,,}" == text/* ]]; then
      text_mime=$line
      break
    fi
  done <<<"$types"
fi
[[ -n "$text_mime" ]] || exit 0

wl-paste --no-newline --type "$text_mime" \
  | python_filter normalize "$text_mime" \
  | cliphist store
