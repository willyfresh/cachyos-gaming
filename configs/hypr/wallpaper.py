#!/usr/bin/env python3
"""Fractal wallpaper behind every Hyprland screen. One process, background layer.

The picture is chosen by ~/.local/state/hypr/wallpaper (fall, greens, sky,
relaxing). Super+Shift+Return writes that file and restarts this process.
"""

import fcntl
import os
import sys
from pathlib import Path

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, GdkPixbuf, Gtk, GtkLayerShell

WALLPAPERS = Path(__file__).resolve().parent / "wallpapers"
NAMES = {
    "fall": "fall-fractal.png",
    "greens": "greens-fractal.png",
    "sky": "sky-fractal.png",
    "relaxing": "relaxing-fractal.png",
}
STATE = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "hypr" / "wallpaper"
LOCK = Path("/tmp/hypr-fall-wallpaper.lock")


def chosen_image():
    name = "fall"
    try:
        picked = STATE.read_text(encoding="utf-8").strip()
    except OSError:
        picked = ""
    if picked in NAMES:
        name = picked
    path = WALLPAPERS / NAMES[name]
    if not path.is_file():
        path = WALLPAPERS / NAMES["fall"]
    return path


def already_running():
    handle = LOCK.open("w")
    try:
        fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return True
    # Held until this process exits.
    already_running.lock = handle
    return False


class Wall(Gtk.Window):
    def __init__(self, monitor, image):
        super().__init__()
        geo = monitor.get_geometry()
        pix = GdkPixbuf.Pixbuf.new_from_file_at_scale(
            str(image), geo.width, geo.height, False
        )
        self.add(Gtk.Image.new_from_pixbuf(pix))
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.BACKGROUND)
        GtkLayerShell.set_namespace(self, "wallpaper")
        GtkLayerShell.set_monitor(self, monitor)
        GtkLayerShell.set_exclusive_zone(self, -1)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.NONE)
        for edge in (
            GtkLayerShell.Edge.TOP,
            GtkLayerShell.Edge.BOTTOM,
            GtkLayerShell.Edge.LEFT,
            GtkLayerShell.Edge.RIGHT,
        ):
            GtkLayerShell.set_anchor(self, edge, True)


def main():
    if already_running():
        return
    image = chosen_image()
    display = Gdk.Display.get_default()
    for i in range(display.get_n_monitors()):
        Wall(display.get_monitor(i), image).show_all()
    Gtk.main()


if __name__ == "__main__":
    sys.exit(main())
