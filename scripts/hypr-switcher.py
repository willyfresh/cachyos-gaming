#!/usr/bin/env python3
"""Windows-style window switching on Hyprland.

Alt+Tab walks a frozen most-recent list and focuses when Alt is released.
Super+Tab shows every window, grouped by screen and workspace, and stays
up until you pick one or cancel.

Hyprland sends commands on socket2 as custom>>switcher>>...
"""

import fcntl
import json
import os
import socket
import subprocess
import sys
import traceback
from dataclasses import dataclass

PREFIX = "custom>>switcher>>"
MAX_ALT_WIDTH = 1680
ALT_TIMEOUT_S = 60


@dataclass
class Win:
    address: str
    klass: str
    app: str
    title: str
    hist: int
    workspace_id: int
    workspace_local: int
    screen: str
    screen_x: int


def screen_of(monitor):
    name = monitor.get("name") or ""
    x = monitor.get("x") or 0
    if name == "DP-1":
        return "Left", x
    if name == "HDMI-A-1":
        return "Right", x
    if x <= 0:
        return "Left", x
    return name or "Screen", x


def local_workspace(workspace_id, screen):
    # hyprsplit: Left is 1–10, Right is 11–20. Show the number on that screen.
    if screen == "Right" and workspace_id >= 11:
        return workspace_id - 10
    if screen == "Left" and 1 <= workspace_id <= 10:
        return workspace_id
    if workspace_id >= 1:
        return ((workspace_id - 1) % 10) + 1
    return workspace_id


def app_name(klass):
    known = {
        "google-chrome": "Chrome",
        "kitty": "Kitty",
        "concord": "Concord",
        "yazi": "Yazi",
        "grok-cli": "Grok",
        "thunderbird": "Thunderbird",
        "org.mozilla.thunderbird": "Thunderbird",
        "code": "Code",
        "Code": "Code",
        "obsidian": "Obsidian",
        "discord": "Discord",
        "heroic": "Heroic",
        "steam": "Steam",
        "inkscape": "Inkscape",
        "gimp": "GIMP",
        "libreoffice": "LibreOffice",
    }
    if klass in known:
        return known[klass]
    if klass.startswith("chrome-"):
        return "Chrome"
    tail = (klass or "Window").split(".")[-1].replace("-", " ")
    return tail[:18] or "Window"


def collect_windows(clients, monitors):
    by_id = {m.get("id"): m for m in monitors}
    found = []
    for client in clients:
        if not client.get("mapped") or client.get("hidden"):
            continue
        ws = client.get("workspace") or {}
        if not isinstance(ws, dict):
            continue
        ws_name = str(ws.get("name") or "")
        ws_id = ws.get("id")
        if not isinstance(ws_id, int) or ws_id < 0 or ws_name.startswith("special"):
            continue
        address = client.get("address") or ""
        if not address:
            continue
        monitor = by_id.get(client.get("monitor")) or {}
        screen, screen_x = screen_of(monitor)
        klass = client.get("class") or ""
        hist = client.get("focusHistoryID")
        if not isinstance(hist, int):
            hist = 10**9
        title = " ".join(str(client.get("title") or "").split())
        found.append(
            Win(
                address=address,
                klass=klass,
                app=app_name(klass),
                title=title or app_name(klass),
                hist=hist,
                workspace_id=ws_id,
                workspace_local=local_workspace(ws_id, screen),
                screen=screen,
                screen_x=screen_x,
            )
        )
    found.sort(key=lambda w: (w.hist, w.address))
    return found


def group_rows(windows):
    """Screens left to right, workspaces in number order, windows by recency."""
    buckets = {}
    for win in windows:
        key = (win.screen_x, win.screen, win.workspace_local, win.workspace_id)
        buckets.setdefault(key, []).append(win)
    rows = []
    for key in sorted(buckets):
        wins = sorted(buckets[key], key=lambda w: (w.hist, w.address))
        _x, screen, local, _wid = key
        rows.append({"screen": screen, "workspace": local, "windows": wins})
    return rows


def group_screens(windows):
    """One row per screen, windows in workspace order. Task View reads across."""
    screens = []
    for row in group_rows(windows):
        if not screens or screens[-1]["screen"] != row["screen"]:
            screens.append({"screen": row["screen"], "windows": []})
        screens[-1]["windows"].extend(row["windows"])
    return screens


def task_start(rows):
    """Task View opens on the window that already has focus."""
    for r, row in enumerate(rows):
        for c, win in enumerate(row["windows"]):
            if win.hist == 0:
                return r, c
    return 0, 0


def alt_open_index(count, direction):
    """First Tab lands on the previous window. Shift+Tab wraps to the far end."""
    if count < 2:
        return None
    if direction < 0:
        return count - 1
    return 1


def alt_move(index, count, direction):
    if count <= 0:
        return 0
    return (index + direction) % count


def task_step(rows, pos, direction):
    flat = [(r, c) for r, row in enumerate(rows) for c in range(len(row["windows"]))]
    if not flat:
        return pos
    try:
        i = flat.index(pos)
    except ValueError:
        i = 0
    return flat[(i + direction) % len(flat)]


def task_vert(rows, pos, direction):
    if not rows:
        return pos
    row, col = pos
    nxt = row + direction
    if nxt < 0 or nxt >= len(rows):
        return pos
    return nxt, min(col, len(rows[nxt]["windows"]) - 1)


def self_test():
    monitors = [
        {"id": 1, "name": "DP-1", "x": 0, "focused": True},
        {"id": 0, "name": "HDMI-A-1", "x": 1920, "focused": False},
    ]
    clients = [
        {
            "address": "a",
            "class": "google-chrome",
            "title": "Search",
            "focusHistoryID": 3,
            "mapped": True,
            "hidden": False,
            "workspace": {"id": 15, "name": "15"},
            "monitor": 0,
        },
        {
            "address": "b",
            "class": "yazi",
            "title": "yazi",
            "focusHistoryID": 1,
            "mapped": True,
            "hidden": False,
            "workspace": {"id": 10, "name": "10"},
            "monitor": 1,
        },
        {
            "address": "c",
            "class": "kitty",
            "title": "hidden",
            "focusHistoryID": 2,
            "mapped": True,
            "hidden": True,
            "workspace": {"id": 1, "name": "1"},
            "monitor": 1,
        },
        {
            "address": "d",
            "class": "scratch",
            "title": "pad",
            "focusHistoryID": 0,
            "mapped": True,
            "hidden": False,
            "workspace": {"id": -99, "name": "special:scratch"},
            "monitor": 1,
        },
        {
            "address": "e",
            "class": "grok-cli",
            "title": "grok",
            "focusHistoryID": 0,
            "mapped": True,
            "hidden": False,
            "workspace": {"id": 1, "name": "1"},
            "monitor": 1,
        },
    ]
    wins = collect_windows(clients, monitors)
    assert [w.address for w in wins] == ["e", "b", "a"], [w.address for w in wins]
    assert wins[0].screen == "Left" and wins[0].workspace_local == 1
    assert wins[1].workspace_local == 10
    assert wins[2].screen == "Right" and wins[2].workspace_local == 5
    assert app_name("chrome-boardgamearena.com__-Default") == "Chrome"
    rows = group_rows(wins)
    assert [(r["screen"], r["workspace"]) for r in rows] == [
        ("Left", 1),
        ("Left", 10),
        ("Right", 5),
    ]
    screens = group_screens(wins)
    assert [w.address for w in screens[0]["windows"]] == ["e", "b"]
    assert [w.address for w in screens[1]["windows"]] == ["a"]
    assert task_start(screens) == (0, 0)
    assert task_step(screens, (0, 0), 1) == (0, 1)
    assert task_vert(screens, (0, 1), 1) == (1, 0)
    assert alt_open_index(1, 1) is None
    assert alt_open_index(4, 1) == 1
    assert alt_open_index(4, -1) == 3
    assert alt_open_index(2, -1) == 1
    assert alt_move(1, 4, 1) == 2
    assert alt_move(3, 4, 1) == 0
    assert alt_move(0, 4, -1) == 3
    assert task_step(rows, (0, 0), 1) == (1, 0)
    assert task_step(rows, (2, 0), 1) == (0, 0)
    assert task_vert(rows, (0, 0), 1) == (1, 0)
    assert task_vert(rows, (0, 0), -1) == (0, 0)
    print("ok")


def hypr_json(args):
    out = subprocess.check_output(["hyprctl", *args, "-j"], text=True, timeout=2)
    return json.loads(out)


def hypr_dispatch(expr):
    subprocess.run(
        ["hyprctl", "dispatch", expr],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
        timeout=2,
    )


def focus_address(address):
    hypr_dispatch('hl.dsp.focus({ window = "address:%s" })' % address)


def reset_submap():
    hypr_dispatch('hl.dsp.submap("reset")')


def runtime_dir():
    return os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"


def socket_path():
    # Prefer this session. If Hyprland was restarted, follow the new socket
    # so a daemon that outlived the old instance does not hold the lock forever.
    base = os.path.join(runtime_dir(), "hypr")
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if sig:
        candidate = os.path.join(base, sig, ".socket2.sock")
        if os.path.exists(candidate):
            return candidate
    if os.path.isdir(base):
        dirs = [os.path.join(base, name) for name in os.listdir(base)]
        dirs = [path for path in dirs if os.path.isdir(path)]
        dirs.sort(key=os.path.getmtime, reverse=True)
        for path in dirs:
            candidate = os.path.join(path, ".socket2.sock")
            if os.path.exists(candidate):
                return candidate
    raise FileNotFoundError("no Hyprland instance")


def take_lock():
    path = os.path.join(runtime_dir(), "hypr-switcher.lock")
    handle = open(path, "w")
    try:
        fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        sys.exit(0)
    return handle


class Switcher:
    def __init__(self):
        import gi

        gi.require_version("Gdk", "3.0")
        gi.require_version("Gtk", "3.0")
        gi.require_version("GtkLayerShell", "0.1")
        from gi.repository import Gdk, GLib, Gtk, GtkLayerShell

        self.Gdk = Gdk
        self.GLib = GLib
        self.Gtk = Gtk
        self.Layer = GtkLayerShell
        self.win = None
        self.mode = None
        self.alt_windows = []
        self.alt_index = 0
        self.alt_cells = []
        self.alt_caption = None
        self.alt_place = None
        self.task_rows = []
        self.task_pos = (0, 0)
        self.task_cells = []
        self.timeout_id = None
        self.sock = None
        self.watch = None
        self.buf = b""
        self.icons = {}
        self.icon_names = self._desktop_icons()
        self._css()
        self.commands = {
            "alt-next": lambda: self.alt_step(1),
            "alt-prev": lambda: self.alt_step(-1),
            "alt-up": self.alt_commit,
            "alt-cancel": self.alt_cancel,
            "task-open": self.task_open,
            "task-close": self.task_close,
            "task-activate": self.task_activate,
            "task-left": lambda: self.task_move(-1, 0),
            "task-right": lambda: self.task_move(1, 0),
            "task-up": lambda: self.task_move(0, -1),
            "task-down": lambda: self.task_move(0, 1),
        }

    def _css(self):
        provider = self.Gtk.CssProvider()
        provider.load_from_data(
            b"""
            * { font-family: "MesloLGS Nerd Font Mono", sans-serif; }
            window, .background { background-color: transparent; }
            .dim { background-color: rgba(10, 13, 11, 0.72); }
            .panel {
                background-color: rgba(10, 13, 11, 0.96);
                border: 2px solid #5cff6b;
                padding: 16px 18px;
            }
            button.cell, button.cell:hover, button.cell:active, button.cell:focus {
                background: transparent;
                background-image: none;
                border: 2px solid transparent;
                box-shadow: none;
                outline: none;
                padding: 8px 10px;
                color: #c8d4c8;
            }
            button.cell.selected, button.cell.selected:hover, button.cell.selected:active {
                background: #1c2820;
                border-color: #5cff6b;
            }
            .caption { color: #c8d4c8; font-size: 16px; }
            .place, .meta, .ws { color: #7a9a7a; font-size: 13px; }
            .app { color: #c8d4c8; font-size: 12px; }
            .screen { color: #5cff6b; font-size: 15px; }
            .letter { color: #5cff6b; font-size: 22px; }
            """
        )
        self.Gtk.StyleContext.add_provider_for_screen(
            self.Gdk.Screen.get_default(),
            provider,
            self.Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

    def _desktop_icons(self):
        mapping = {}
        roots = (
            "/usr/share/applications",
            os.path.expanduser("~/.local/share/applications"),
        )
        for root in roots:
            if not os.path.isdir(root):
                continue
            for name in os.listdir(root):
                if not name.endswith(".desktop"):
                    continue
                klass = ""
                icon = ""
                try:
                    with open(os.path.join(root, name), encoding="utf-8", errors="replace") as fh:
                        for line in fh:
                            if line.startswith("StartupWMClass="):
                                klass = line.split("=", 1)[1].strip()
                            elif line.startswith("Icon="):
                                icon = line.split("=", 1)[1].strip()
                except OSError:
                    continue
                if klass and icon:
                    mapping[klass] = icon
        return mapping

    def icon_widget(self, win, size):
        pix = self._pixbuf(win.klass, size)
        if pix is not None:
            image = self.Gtk.Image.new_from_pixbuf(pix)
            image.set_pixel_size(size)
            return image
        letter = self.Gtk.Label(label=(win.app[:1] or "?").upper())
        letter.get_style_context().add_class("letter")
        letter.set_size_request(size, size)
        return letter

    def _pixbuf(self, klass, size):
        key = (klass, size)
        if key in self.icons:
            return self.icons[key]
        theme = self.Gtk.IconTheme.get_default()
        names = []
        if klass in self.icon_names:
            names.append(self.icon_names[klass])
        if klass.startswith("chrome-") or klass == "google-chrome":
            names.append("google-chrome")
        names.extend((klass, klass.lower(), klass.lower().replace(" ", "-")))
        pix = None
        flags = self.Gtk.IconLookupFlags.FORCE_SIZE
        for name in names:
            if not name or not theme.has_icon(name):
                continue
            try:
                pix = theme.load_icon(name, size, flags)
            except Exception:
                pix = None
            if pix is not None:
                break
        self.icons[key] = pix
        return pix

    def focused_monitor(self):
        monitors = hypr_json(["monitors"])
        focused = next((m for m in monitors if m.get("focused")), monitors[0] if monitors else None)
        if focused is None:
            return None, monitors
        display = self.Gdk.Display.get_default()
        gdk = None
        for i in range(display.get_n_monitors()):
            candidate = display.get_monitor(i)
            geo = candidate.get_geometry()
            if geo.x == focused.get("x") and geo.y == focused.get("y"):
                gdk = candidate
                break
        return gdk, monitors

    def hide(self):
        if self.timeout_id is not None:
            self.GLib.source_remove(self.timeout_id)
            self.timeout_id = None
        old = self.win
        self.win = None
        self.mode = None
        self.alt_cells = []
        self.task_cells = []
        if old is not None:
            self.GLib.idle_add(old.destroy)

    def _layer(self, fill):
        gdk, _monitors = self.focused_monitor()
        win = self.Gtk.Window()
        win.set_app_paintable(True)
        visual = win.get_screen().get_rgba_visual()
        if visual is not None:
            win.set_visual(visual)
        win.set_decorated(False)
        win.set_accept_focus(False)
        win.set_can_focus(False)
        win.set_focus_on_map(False)
        self.Layer.init_for_window(win)
        self.Layer.set_layer(win, self.Layer.Layer.OVERLAY)
        self.Layer.set_namespace(win, "hypr-switcher")
        self.Layer.set_exclusive_zone(win, -1)
        self.Layer.set_keyboard_mode(win, self.Layer.KeyboardMode.NONE)
        if gdk is not None:
            self.Layer.set_monitor(win, gdk)
        if fill:
            for edge in (
                self.Layer.Edge.LEFT,
                self.Layer.Edge.RIGHT,
                self.Layer.Edge.TOP,
                self.Layer.Edge.BOTTOM,
            ):
                self.Layer.set_anchor(win, edge, True)
        return win

    def snapshot(self):
        _gdk, monitors = self.focused_monitor()
        return collect_windows(hypr_json(["clients"]), monitors)

    def alt_step(self, direction):
        if self.mode == "task":
            return
        if self.mode != "alt":
            windows = self.snapshot()
            index = alt_open_index(len(windows), direction)
            if index is None:
                return
            self.alt_windows = windows
            self.alt_index = index
            self._show_alt()
            return
        self.alt_index = alt_move(self.alt_index, len(self.alt_windows), direction)
        self._mark_alt()

    def _show_alt(self):
        self.hide()
        self.mode = "alt"
        windows = self.alt_windows
        count = len(windows)
        inner = MAX_ALT_WIDTH - 36
        cell_w = 150
        if count > 1:
            cell_w = max(84, min(150, (inner - 6 * (count - 1)) // count))
        win = self._layer(False)
        panel = self.Gtk.Box(orientation=self.Gtk.Orientation.VERTICAL, spacing=12)
        panel.get_style_context().add_class("panel")
        row = self.Gtk.Box(orientation=self.Gtk.Orientation.HORIZONTAL, spacing=6)
        row.set_halign(self.Gtk.Align.CENTER)
        self.alt_cells = []
        for index, item in enumerate(windows):
            button = self.Gtk.Button()
            button.set_relief(self.Gtk.ReliefStyle.NONE)
            button.set_can_focus(False)
            button.get_style_context().add_class("cell")
            button.set_size_request(cell_w, -1)
            button.set_tooltip_text(item.title)
            box = self.Gtk.Box(orientation=self.Gtk.Orientation.VERTICAL, spacing=6)
            box.set_halign(self.Gtk.Align.CENTER)
            icon = self.icon_widget(item, 40)
            icon.set_halign(self.Gtk.Align.CENTER)
            name = self.Gtk.Label(label=item.app)
            name.get_style_context().add_class("app")
            name.set_ellipsize(self._ellipsize())
            name.set_max_width_chars(max(8, cell_w // 10))
            name.set_halign(self.Gtk.Align.CENTER)
            box.pack_start(icon, False, False, 0)
            box.pack_start(name, False, False, 0)
            button.add(box)
            button.connect("clicked", self._alt_clicked, index)
            button.connect("enter-notify-event", self._alt_hover, index)
            row.pack_start(button, False, False, 0)
            self.alt_cells.append(button)
        caption = self.Gtk.Label()
        caption.get_style_context().add_class("caption")
        caption.set_ellipsize(self._ellipsize())
        caption.set_max_width_chars(72)
        caption.set_halign(self.Gtk.Align.CENTER)
        place = self.Gtk.Label()
        place.get_style_context().add_class("place")
        place.set_halign(self.Gtk.Align.CENTER)
        self.alt_caption = caption
        self.alt_place = place
        panel.pack_start(row, False, False, 0)
        panel.pack_start(caption, False, False, 0)
        panel.pack_start(place, False, False, 0)
        win.add(panel)
        self.win = win
        self._mark_alt()
        win.show_all()
        self.timeout_id = self.GLib.timeout_add_seconds(ALT_TIMEOUT_S, self._alt_expired)

    def _ellipsize(self):
        from gi.repository import Pango

        return Pango.EllipsizeMode.END

    def _mark_alt(self):
        if self.mode != "alt" or not self.alt_windows:
            return
        for index, cell in enumerate(self.alt_cells):
            ctx = cell.get_style_context()
            if index == self.alt_index:
                ctx.add_class("selected")
            else:
                ctx.remove_class("selected")
        item = self.alt_windows[self.alt_index]
        if self.alt_caption is not None:
            self.alt_caption.set_text(item.title)
        if self.alt_place is not None:
            self.alt_place.set_text(f"{item.screen}  ·  {item.workspace_local}")

    def _alt_clicked(self, _button, index):
        self.alt_index = index
        self.alt_commit()

    def _alt_hover(self, _button, _event, index):
        if self.mode != "alt" or index == self.alt_index:
            return False
        self.alt_index = index
        self._mark_alt()
        return False

    def _alt_expired(self):
        self.timeout_id = None
        if self.mode == "alt":
            self.hide()
        return False

    def alt_commit(self):
        if self.mode != "alt" or not self.alt_windows:
            return
        item = self.alt_windows[self.alt_index]
        self.hide()
        focus_address(item.address)

    def alt_cancel(self):
        if self.mode == "alt":
            self.hide()

    def task_open(self):
        was = self.mode
        windows = self.snapshot()
        self.hide()
        if was == "alt":
            # A release that arrives late must not focus a window from the strip.
            pass
        self.mode = "task"
        self.task_rows = group_screens(windows)
        self.task_pos = task_start(self.task_rows)
        self._show_task()

    def _show_task(self):
        win = self._layer(True)
        dim = self.Gtk.EventBox()
        dim.get_style_context().add_class("dim")
        dim.connect("button-press-event", self._dim_click)
        outer = self.Gtk.Box(orientation=self.Gtk.Orientation.VERTICAL)
        outer.set_halign(self.Gtk.Align.CENTER)
        outer.set_valign(self.Gtk.Align.CENTER)
        panel = self.Gtk.Box(orientation=self.Gtk.Orientation.VERTICAL, spacing=14)
        panel.get_style_context().add_class("panel")
        panel.set_margin_top(24)
        panel.set_margin_bottom(24)
        if not self.task_rows:
            empty = self.Gtk.Label(label="No windows")
            empty.get_style_context().add_class("caption")
            panel.pack_start(empty, False, False, 0)
        else:
            self.task_cells = []
            for r, row in enumerate(self.task_rows):
                header = self.Gtk.Label(label=row["screen"])
                header.get_style_context().add_class("screen")
                header.set_halign(self.Gtk.Align.START)
                if r:
                    header.set_margin_top(10)
                panel.pack_start(header, False, False, 0)
                line = self.Gtk.Box(orientation=self.Gtk.Orientation.HORIZONTAL, spacing=8)
                cells = []
                for c, item in enumerate(row["windows"]):
                    button = self._task_card(item, r, c)
                    line.pack_start(button, False, False, 0)
                    cells.append(button)
                self.task_cells.append(cells)
                panel.pack_start(line, False, False, 0)
            self._mark_task()
        # Clicks on a card must not fall through to the dim and cancel.
        panel_events = self.Gtk.EventBox()
        panel_events.add(panel)
        panel_events.connect("button-press-event", lambda *_: True)
        outer.pack_start(panel_events, False, False, 0)
        dim.add(outer)
        win.add(dim)
        self.win = win
        win.show_all()

    def _task_card(self, item, row, col):
        button = self.Gtk.Button()
        button.set_relief(self.Gtk.ReliefStyle.NONE)
        button.set_can_focus(False)
        button.get_style_context().add_class("cell")
        button.set_size_request(250, -1)
        button.set_tooltip_text(item.title)
        box = self.Gtk.Box(orientation=self.Gtk.Orientation.HORIZONTAL, spacing=10)
        box.pack_start(self.icon_widget(item, 32), False, False, 0)
        text = self.Gtk.Box(orientation=self.Gtk.Orientation.VERTICAL, spacing=2)
        title = self.Gtk.Label(label=item.title)
        title.get_style_context().add_class("app")
        title.set_ellipsize(self._ellipsize())
        title.set_max_width_chars(24)
        title.set_halign(self.Gtk.Align.START)
        meta = self.Gtk.Label(label=f"{item.workspace_local}   {item.app}")
        meta.get_style_context().add_class("meta")
        meta.set_halign(self.Gtk.Align.START)
        text.pack_start(title, False, False, 0)
        text.pack_start(meta, False, False, 0)
        box.pack_start(text, True, True, 0)
        button.add(box)
        button.connect("clicked", self._task_clicked, row, col)
        return button

    def _mark_task(self):
        if self.mode != "task":
            return
        row, col = self.task_pos
        for r, cells in enumerate(self.task_cells):
            for c, cell in enumerate(cells):
                ctx = cell.get_style_context()
                if r == row and c == col:
                    ctx.add_class("selected")
                else:
                    ctx.remove_class("selected")

    def _task_clicked(self, _button, row, col):
        self.task_pos = (row, col)
        self.task_activate()

    def _dim_click(self, _widget, _event):
        if self.mode == "task":
            self.task_close()
        return True

    def task_move(self, horizontal, vertical):
        if self.mode != "task" or not self.task_rows:
            return
        if horizontal:
            self.task_pos = task_step(self.task_rows, self.task_pos, horizontal)
        if vertical:
            self.task_pos = task_vert(self.task_rows, self.task_pos, vertical)
        self._mark_task()

    def _selected_task(self):
        if not self.task_rows:
            return None
        row, col = self.task_pos
        if row < 0 or row >= len(self.task_rows):
            return None
        wins = self.task_rows[row]["windows"]
        if col < 0 or col >= len(wins):
            return None
        return wins[col]

    def task_activate(self):
        if self.mode != "task":
            return
        item = self._selected_task()
        self.hide()
        reset_submap()
        if item is not None:
            focus_address(item.address)

    def task_close(self):
        if self.mode != "task":
            reset_submap()
            return
        self.hide()
        reset_submap()

    def handle(self, cmd):
        fn = self.commands.get(cmd)
        if fn is None:
            return
        try:
            fn()
        except Exception:
            traceback.print_exc()

    def connect_socket(self):
        if self.watch is not None:
            self.GLib.source_remove(self.watch)
            self.watch = None
        if self.sock is not None:
            try:
                self.sock.close()
            except OSError:
                pass
            self.sock = None
        try:
            sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            sock.connect(socket_path())
            sock.setblocking(False)
        except OSError:
            self.GLib.timeout_add_seconds(1, self._retry_socket)
            return
        self.sock = sock
        self.buf = b""
        self.watch = self.GLib.io_add_watch(
            sock.fileno(),
            self.GLib.IO_IN | self.GLib.IO_HUP | self.GLib.IO_ERR,
            self._on_socket,
        )

    def _retry_socket(self):
        self.connect_socket()
        return False

    def _on_socket(self, _fd, condition):
        if condition & (self.GLib.IO_HUP | self.GLib.IO_ERR):
            self.GLib.timeout_add_seconds(1, self._retry_socket)
            return False
        try:
            chunk = self.sock.recv(65536)
        except BlockingIOError:
            return True
        except OSError:
            self.GLib.timeout_add_seconds(1, self._retry_socket)
            return False
        if not chunk:
            self.GLib.timeout_add_seconds(1, self._retry_socket)
            return False
        self.buf += chunk
        while b"\n" in self.buf:
            raw, self.buf = self.buf.split(b"\n", 1)
            line = raw.decode("utf-8", "replace")
            if line.startswith(PREFIX):
                self.handle(line[len(PREFIX) :].strip())
        return True


def main():
    if "--self-test" in sys.argv:
        self_test()
        return
    take_lock()
    os.environ.setdefault("GDK_BACKEND", "wayland")
    app = Switcher()
    app.connect_socket()
    app.Gtk.main()


if __name__ == "__main__":
    main()
