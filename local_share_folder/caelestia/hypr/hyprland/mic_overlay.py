#!/usr/bin/env python3
import glob
import os
import sys

if "gtk4-layer-shell" not in os.environ.get("LD_PRELOAD", ""):
    _libs = glob.glob("/usr/lib/libgtk4-layer-shell.so*") + glob.glob(
        "/usr/lib/*/libgtk4-layer-shell.so*"
    )
    if _libs:
        os.environ["LD_PRELOAD"] = (
            _libs[0] + " " + os.environ.get("LD_PRELOAD", "")
        ).strip()
        os.environ["GDK_BACKEND"] = "wayland"
        os.execv(sys.executable, [sys.executable] + sys.argv)

import argparse
import signal
import subprocess
import threading

import cairo
import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Gtk4LayerShell", "1.0")
from gi.repository import Gdk, GLib, Gtk
from gi.repository import Gtk4LayerShell as LayerShell

CSS = """
window.overlay { background: transparent; }

.pill {
    background: rgba(18, 18, 24, 0.88);
    border-radius: 999px;
    padding: 14px 28px 14px 22px;
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.45);
    opacity: __OPACITY__;
    transition: opacity 220ms ease, border-color 220ms ease;
}
.pill.hidden { opacity: 0; }

.pill .icon-wrap {
    border-radius: 999px;
    padding: 10px;
    transition: background 220ms ease;
}
.pill .title { font-size: 15px; font-weight: 700; letter-spacing: 0.3px; }
.pill .sub   { font-size: 11px; opacity: 0.65; }

.pill.muted { border-color: rgba(255, 92, 108, 0.55); }
.pill.muted .icon-wrap { background: rgba(255, 92, 108, 0.18); color: #ff5c6c; }
.pill.muted .title { color: #ff8a96; }

.pill.live  { border-color: rgba(92, 224, 160, 0.45); }
.pill.live .icon-wrap { background: rgba(92, 224, 160, 0.16); color: #5ce0a0; }
.pill.live .title { color: #8ff0bf; }

.pill.unknown .icon-wrap { background: rgba(255, 255, 255, 0.1); }
.pill, .pill label { color: #e8e8ee; }
"""

STATES = {
    "MUTED": (
        "microphone-disabled-symbolic",
        "Microphone muted",
        "Nobody can hear you",
        "muted",
    ),
    "UNMUTED": (
        "audio-input-microphone-symbolic",
        "Microphone live",
        "You're being heard",
        "live",
    ),
    "UNKNOWN": (
        "dialog-question-symbolic",
        "Mic unknown",
        "No default input found",
        "unknown",
    ),
}


def get_state() -> str:
    try:
        out = subprocess.run(
            ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"],
            capture_output=True,
            text=True,
            timeout=2,
        )
    except (OSError, subprocess.TimeoutExpired):
        return "UNKNOWN"
    if out.returncode != 0:
        return "UNKNOWN"
    return "MUTED" if "[MUTED]" in out.stdout else "UNMUTED"


class Overlay(Gtk.Window):
    def __init__(self, args):
        super().__init__()
        self.args = args
        self.state = None
        self.hide_timer = None
        self.enabled = True

        self.add_css_class("overlay")
        self.set_decorated(False)
        self.set_resizable(False)

        if not LayerShell.is_supported():
            print(
                "layer-shell is not supported here (need Wayland: Hyprland/Sway/niri/KDE).",
                file=sys.stderr,
            )
            sys.exit(1)

        LayerShell.init_for_window(self)
        LayerShell.set_namespace(self, "mic-overlay")
        LayerShell.set_layer(self, LayerShell.Layer.OVERLAY)
        LayerShell.set_keyboard_mode(self, LayerShell.KeyboardMode.NONE)
        LayerShell.set_exclusive_zone(self, -1)

        edge = LayerShell.Edge.TOP if args.position == "top" else LayerShell.Edge.BOTTOM
        LayerShell.set_anchor(self, edge, True)
        side = LayerShell.Edge.RIGHT if args.side == "right" else LayerShell.Edge.LEFT
        LayerShell.set_anchor(self, side, True)
        LayerShell.set_margin(self, edge, args.y)
        LayerShell.set_margin(self, side, args.x)

        self.set_direction(Gtk.TextDirection.LTR)
        self.pill = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=16)
        self.pill.set_direction(Gtk.TextDirection.LTR)
        self.pill.add_css_class("pill")
        self.pill.add_css_class("hidden")

        wrap = Gtk.Box()
        wrap.add_css_class("icon-wrap")
        self.icon = Gtk.Image()
        self.icon.set_pixel_size(args.size)
        wrap.append(self.icon)
        self.pill.append(wrap)

        texts = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
        texts.set_valign(Gtk.Align.CENTER)
        self.title = Gtk.Label(xalign=0)
        self.title.add_css_class("title")
        self.sub = Gtk.Label(xalign=0)
        self.sub.add_css_class("sub")
        texts.append(self.title)
        texts.append(self.sub)
        self.pill.append(texts)

        self.set_child(self.pill)
        self.connect("realize", self._make_click_through)

    def _make_click_through(self, *_):
        surface = self.get_surface()
        if surface:
            surface.set_input_region(cairo.Region())

    def update(self):
        new = get_state()
        if new == self.state:
            return False
        first = self.state is None
        self.state = new

        icon, title, sub, css = STATES[new]
        self.icon.set_from_icon_name(icon)
        self.title.set_text(title)
        self.sub.set_text(sub)
        for c in ("muted", "live", "unknown"):
            self.pill.remove_css_class(c)
        self.pill.add_css_class(css)

        if first and new != "MUTED":
            return False
        self.show_pill()
        return False

    def toggle(self):
        self.enabled = not self.enabled
        if self.enabled:
            self.show_pill()
        else:
            if self.hide_timer:
                GLib.source_remove(self.hide_timer)
                self.hide_timer = None
            self.pill.add_css_class("hidden")
        return True

    def show_pill(self):
        if not self.enabled or self.state is None:
            return
        if self.hide_timer:
            GLib.source_remove(self.hide_timer)
            self.hide_timer = None
        self.present()
        self.pill.remove_css_class("hidden")

        stay = self.state == "MUTED" and not self.args.no_persist
        if not stay:
            self.hide_timer = GLib.timeout_add(self.args.duration, self.hide_pill)

    def hide_pill(self):
        self.pill.add_css_class("hidden")
        self.hide_timer = None
        return False

    def watch_events(self):
        def run():
            try:
                proc = subprocess.Popen(
                    ["pactl", "subscribe"],
                    stdout=subprocess.PIPE,
                    text=True,
                    bufsize=1,
                )
            except OSError:
                return
            for line in proc.stdout:
                if "source" in line or "server" in line:
                    GLib.idle_add(self.update)

        threading.Thread(target=run, daemon=True).start()
        GLib.timeout_add(1500, lambda: (self.update(), True)[1])


def main():
    p = argparse.ArgumentParser(description="Mic mute overlay")
    p.add_argument(
        "--position", choices=["top", "bottom"], default="top", help="vertical edge"
    )
    p.add_argument(
        "--side", choices=["left", "right"], default="right", help="horizontal side"
    )
    p.add_argument(
        "--y", type=int, default=48, help="distance from the top/bottom edge (px)"
    )
    p.add_argument(
        "--x", type=int, default=48, help="distance from the chosen side (px)"
    )
    p.add_argument(
        "--opacity", type=float, default=0.5, help="overlay opacity, 0.0 - 1.0"
    )
    p.add_argument("--size", type=int, default=30, help="icon size (px)")
    p.add_argument(
        "--duration", type=int, default=1500, help="visible time in ms when not muted"
    )
    p.add_argument(
        "--no-persist",
        action="store_true",
        help="hide after --duration even when muted",
    )
    args = p.parse_args()
    args.opacity = min(max(args.opacity, 0.0), 1.0)

    app = Gtk.Application(application_id="dev.local.MicOverlay")

    def on_activate(app):
        Gtk.Widget.set_default_direction(Gtk.TextDirection.LTR)
        css = Gtk.CssProvider()
        css.load_from_string(CSS.replace("__OPACITY__", str(args.opacity)))
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        win = Overlay(args)
        app.add_window(win)
        GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGUSR1, win.toggle)
        win.update()
        win.watch_events()
        app.hold()

    app.connect("activate", on_activate)
    app.run(None)


if __name__ == "__main__":
    main()
