#!/usr/bin/env python3
"""Fall fractal behind every Hyprland screen. One process, background layer."""

import fcntl
import sys
from pathlib import Path

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, GdkPixbuf, Gtk, GtkLayerShell

IMAGE = Path(__file__).resolve().parent / "wallpapers" / "fall-fractal.png"
LOCK = Path("/tmp/hypr-fall-wallpaper.lock")


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
    def __init__(self, monitor):
        super().__init__()
        geo = monitor.get_geometry()
        pix = GdkPixbuf.Pixbuf.new_from_file_at_scale(
            str(IMAGE), geo.width, geo.height, False
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
    display = Gdk.Display.get_default()
    for i in range(display.get_n_monitors()):
        Wall(display.get_monitor(i)).show_all()
    Gtk.main()


if __name__ == "__main__":
    sys.exit(main())
