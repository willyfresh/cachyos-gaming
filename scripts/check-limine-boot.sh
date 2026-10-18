#!/usr/bin/env bash
# Fail if /boot/limine.conf names a boot file that is missing or whose
# BLAKE2b hash does not match. A kernel update rewrites those files.
# Run this before rebooting.

set -euo pipefail

conf=${LIMINE_CONF:-/boot/limine.conf}
fail=0

if [[ ! -f $conf ]]; then
    echo "limine: $conf is missing. Do not reboot." >&2
    exit 1
fi

if ! command -v b2sum >/dev/null 2>&1; then
    echo "limine: b2sum is not installed, so hashes cannot be checked." >&2
    exit 1
fi

while IFS= read -r spec; do
    [[ -n $spec ]] || continue
    rel=${spec#boot():}
    hash=
    if [[ $rel == *#* ]]; then
        hash=${rel#*#}
        rel=${rel%%#*}
    fi
    file=/boot${rel}
    if [[ ! -f $file ]]; then
        echo "limine: missing $file" >&2
        echo "        named by $spec" >&2
        fail=1
        continue
    fi
    if [[ -n $hash ]]; then
        got=$(b2sum "$file" | awk '{print $1}')
        if [[ $got != "$hash" ]]; then
            echo "limine: hash mismatch $file" >&2
            echo "        menu  $hash" >&2
            echo "        disk  $got" >&2
            fail=1
        fi
    fi
done < <(grep -oE 'boot\(\):/[^[:space:]]+' "$conf" || true)

if [[ $fail -ne 0 ]]; then
    echo "limine: the boot menu names a file that will not load. Do not reboot." >&2
    exit 1
fi

echo "limine: every file named in $conf is on /boot."
