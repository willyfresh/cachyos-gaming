#!/usr/bin/env python3
"""Program Keychron V6 VIA keymap (Windows layers) over hidraw.

Windows mode stays on. Writes:
  Fn+F4  -> Super+Space (launcher), Super+E stays files
  Fn+F8  -> F18 (niri media toggle; Chrome steals Play)
  side cluster (crop/mic/light/circle/triangle/square/X)
         -> Print, F20 (mic mute), F13-F17

Needs write access to the VIA hidraw node (udev or sudo).
"""

from __future__ import annotations

import argparse
import glob
import os
import sys
import time

VIA_USAGE_PAGE = bytes((0x06, 0x60, 0xFF))
REPORT_LEN = 32
CMD_GET_PROTOCOL = 0x01
CMD_GET_KEYCODE = 0x04
CMD_SET_KEYCODE = 0x05

# QMK 16-bit keycodes
KC_NO = 0x0000
KC_SPC = 0x002C
KC_PSCR = 0x0046
KC_F13 = 0x0068
KC_F14 = 0x0069
KC_F15 = 0x006A
KC_F16 = 0x006B
KC_F17 = 0x006C
KC_F18 = 0x006D
KC_F20 = 0x006F
QK_LGUI = 0x0800
LGUI_SPC = QK_LGUI | KC_SPC  # Super+Space
LGUI_E = QK_LGUI | 0x0008  # Super+E, stock Fn+F4

# Layers: 0 Mac, 1 Mac-Fn, 2 Win, 3 Win-Fn
WIN = 2
WIN_FN = 3

# LAYOUT_ansi_109 top row (see qmk v6 ansi_encoder keyboard.json)
POS_F4 = (0, 4)
POS_F8 = (0, 8)
POS_CROP = (0, 14)  # Print Screen
POS_MIC = (0, 15)
POS_LIGHT = (0, 16)
POS_CIRCLE = (0, 19)
POS_TRI = (1, 19)
POS_SQUARE = (2, 19)
POS_X = (3, 19)

WANTED = [
    (WIN_FN, *POS_F4, LGUI_SPC, "Fn+F4 launcher (Super+Space)"),
    (WIN_FN, *POS_F8, KC_F18, "Fn+F8 play/pause (F18, not Chrome media-play)"),
    (WIN, *POS_CROP, KC_PSCR, "crop / Print Screen"),
    (WIN, *POS_MIC, KC_F20, "mic / F20 (XF86AudioMicMute)"),
    (WIN, *POS_LIGHT, KC_F13, "light / F13"),
    (WIN, *POS_CIRCLE, KC_F14, "circle / F14"),
    (WIN, *POS_TRI, KC_F15, "triangle / F15"),
    (WIN, *POS_SQUARE, KC_F16, "square / F16"),
    (WIN, *POS_X, KC_F17, "X / F17"),
]


def find_via_hidraw() -> str:
    for path in sorted(glob.glob("/sys/class/hidraw/hidraw*/device/report_descriptor")):
        data = open(path, "rb").read()
        if VIA_USAGE_PAGE not in data:
            continue
        hidraw = "/dev/" + path.split("/")[4]
        if os.access(hidraw, os.R_OK | os.W_OK):
            return hidraw
        # still return so the caller can explain permissions
        return hidraw
    raise SystemExit("no Keychron VIA hidraw (usage page FF60) found")


def xfer(fd: int, payload: bytes) -> bytes:
    buf = payload.ljust(REPORT_LEN, b"\x00")
    os.write(fd, buf)
    time.sleep(0.02)
    return os.read(fd, REPORT_LEN)


def get_keycode(fd: int, layer: int, row: int, col: int) -> int:
    r = xfer(fd, bytes((CMD_GET_KEYCODE, layer, row, col)))
    return (r[4] << 8) | r[5]


def set_keycode(fd: int, layer: int, row: int, col: int, kc: int) -> None:
    xfer(fd, bytes((CMD_SET_KEYCODE, layer, row, col, (kc >> 8) & 0xFF, kc & 0xFF)))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    node = find_via_hidraw()
    if not os.access(node, os.R_OK | os.W_OK):
        print(f"no permission on {node}; run with sudo or install the udev rule", file=sys.stderr)
        return 2

    fd = os.open(node, os.O_RDWR)
    try:
        proto = xfer(fd, bytes((CMD_GET_PROTOCOL,)))
        print(f"VIA {node} protocol {proto[1]}.{proto[2]}")
        for layer, row, col, kc, label in WANTED:
            before = get_keycode(fd, layer, row, col)
            print(f"  {label}: layer {layer} [{row},{col}] 0x{before:04x} -> 0x{kc:04x}")
            if args.dry_run or before == kc:
                continue
            set_keycode(fd, layer, row, col, kc)
            after = get_keycode(fd, layer, row, col)
            if after != kc:
                print(f"    write failed (now 0x{after:04x})", file=sys.stderr)
                return 1
        print("keymap written")
        return 0
    finally:
        os.close(fd)


if __name__ == "__main__":
    raise SystemExit(main())
