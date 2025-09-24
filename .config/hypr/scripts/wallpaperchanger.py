#!/usr/bin/env python3
import gi
import os
import subprocess
import threading

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GdkPixbuf, GLib

# ---------------- CONFIG ----------------
WALLPAPER_DIR = os.path.expanduser("~/Pictures/wallpapers/wallpapers")
THUMBNAIL_WIDTH = 800
THUMBNAIL_HEIGHT = 250
SCROLL_SPEED = 150
MAX_BAR_WIDTH = 1350  # Maximum dock width
# ----------------------------------------

class WallpaperDock(Gtk.Window):
    def __init__(self):
        super().__init__()
        
        # Borderless, transparent, always on top
        self.set_title("WallpaperDock")        # Title
        self.set_name("WallpaperDock")         #
        self.set_decorated(False)
        self.set_app_paintable(True)
        self.set_keep_above(True)
        self.set_type_hint(Gdk.WindowTypeHint.DOCK)
        # Screen geometry (Wayland safe)
        display = Gdk.Display.get_default()
        monitor = display.get_monitor_at_window(display.get_default_screen().get_root_window())
        geometry = monitor.get_geometry()
        width, height = geometry.width, geometry.height

        # Initially set a small width; we will resize later based on number of thumbnails
        self.set_default_size(MAX_BAR_WIDTH, THUMBNAIL_HEIGHT + 20)
        self.move((width - MAX_BAR_WIDTH)//2, height - (THUMBNAIL_HEIGHT + 20))

        # Transparent background using CSS
        screen = Gdk.Screen.get_default()
        css = b"""
        window {
            background-color: rgba(0,0,0,0);
        }
        """
        style_provider = Gtk.CssProvider()
        style_provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            screen, style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # Horizontal scrolled window
        self.scrolled = Gtk.ScrolledWindow()
        self.scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.NEVER)
        self.scrolled.set_propagate_natural_height(True)
        self.scrolled.set_min_content_height(THUMBNAIL_HEIGHT + 20)
        self.add(self.scrolled)

        # Horizontal box for thumbnails (do NOT expand to full width)
        self.hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=15)
        self.hbox.set_halign(Gtk.Align.START)
        self.hbox.set_hexpand(False)
        self.scrolled.add(self.hbox)

        # Mouse wheel horizontal scrolling
        self.scrolled.add_events(Gdk.EventMask.SCROLL_MASK)
        self.scrolled.connect("scroll-event", self.on_scroll_event)

        # Load wallpapers in a thread
        threading.Thread(target=self.load_wallpapers, daemon=True).start()

    def load_wallpapers(self):
        files = sorted([f for f in os.listdir(WALLPAPER_DIR)
                        if f.lower().endswith((".jpg", ".png", ".jpeg",".gif"))])

        # Calculate dynamic width of the dock based on thumbnails
        bar_width = min(len(files) * (THUMBNAIL_WIDTH + 15), MAX_BAR_WIDTH)
        GLib.idle_add(self.set_default_size, bar_width, THUMBNAIL_HEIGHT + 20)

        for file in files:
            filepath = os.path.join(WALLPAPER_DIR, file)
            try:
                thumb = GdkPixbuf.Pixbuf.new_from_file_at_scale(
                    filepath, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT, True
                )
                GLib.idle_add(self.add_thumbnail, thumb, filepath)
            except Exception as e:
                print(f"Failed to load {file}: {e}")

    def add_thumbnail(self, thumb, filepath):
        image = Gtk.Image.new_from_pixbuf(thumb)
        button = Gtk.Button()
        button.set_image(image)
        button.set_relief(Gtk.ReliefStyle.NONE)
        button.connect("clicked", self.set_wallpaper, filepath)
        self.hbox.pack_start(button, False, False, 0)
        self.show_all()
        return False

    def set_wallpaper(self, widget, filepath):
        subprocess.Popen([
            "swww", "img", filepath,
            "--transition-type", "any",
            "--transition-step", "15",
            "--transition-fps", "120"
        ])

    def on_scroll_event(self, widget, event):
        adj = self.scrolled.get_hadjustment()
        if event.direction == Gdk.ScrollDirection.UP or event.delta_y < 0:
            adj.set_value(max(adj.get_lower(), adj.get_value() - SCROLL_SPEED))
        elif event.direction == Gdk.ScrollDirection.DOWN or event.delta_y > 0:
            adj.set_value(min(adj.get_upper() - adj.get_page_size(), adj.get_value() + SCROLL_SPEED))
        return True

def main():
    win = WallpaperDock()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()
