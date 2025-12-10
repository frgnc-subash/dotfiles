#!/usr/bin/env python3

import gi
import os
import subprocess
import threading
import sys
import random
import time
import hashlib
from concurrent.futures import ThreadPoolExecutor

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GdkPixbuf, GLib

# ---------------- CONFIGURATION ----------------
WALLPAPER_DIR = os.path.expanduser("~/Pictures/wallpapers/wallpapers")
CACHE_DIR = os.path.expanduser("~/.cache/wallpaper_dock")

CENTER_W = 400
CENTER_H = 225
SIDE_W = 250
SIDE_H = 140

MAX_BAR_WIDTH = 1000
TOTAL_WINDOW_HEIGHT = CENTER_H + 50 
# -----------------------------------------------

class Utils:
    @staticmethod
    def ensure_dir(directory):
        if not os.path.exists(directory):
            os.makedirs(directory)

    @staticmethod
    def get_cache_path(filepath, width, height):
        hash_str = hashlib.md5(f"{filepath}_{width}_{height}".encode()).hexdigest()
        return os.path.join(CACHE_DIR, f"{hash_str}.png")

class WallpaperManager:
    @staticmethod
    def set_wallpaper(wallpaper):
        threading.Thread(target=WallpaperManager._set_wallpaper_thread, args=(wallpaper,)).start()

    @staticmethod
    def _set_wallpaper_thread(wallpaper):
        try:
            subprocess.Popen([
                "swww", "img", wallpaper,
                "--transition-type", "any",
                "--transition-duration", "1.5",
                "--transition-fps", "90"
            ])
            subprocess.Popen(["matugen", "image", wallpaper])
        except Exception as e:
            print(f"Error setting wallpaper: {e}")

    @staticmethod
    def get_wallpapers():
        wallpapers = []
        if not os.path.exists(WALLPAPER_DIR):
            return []
        valid_exts = ('.jpg', '.png', '.jpeg', '.gif', '.webp')
        for f in os.listdir(WALLPAPER_DIR):
            if f.lower().endswith(valid_exts):
                wallpapers.append(os.path.join(WALLPAPER_DIR, f))
        return sorted(wallpapers)

class ImageLoader:
    def __init__(self):
        Utils.ensure_dir(CACHE_DIR)
        self.executor = ThreadPoolExecutor(max_workers=4)
        self.mem_cache = {}

    def get_pixbuf(self, filepath, w, h, callback):
        cache_key = (filepath, w, h)
        if cache_key in self.mem_cache:
            callback(self.mem_cache[cache_key])
            return
        self.executor.submit(self._load_worker, filepath, w, h, callback)

    def _load_worker(self, filepath, w, h, callback):
        cache_path = Utils.get_cache_path(filepath, w, h)
        pixbuf = None
        try:
            if os.path.exists(cache_path):
                pixbuf = GdkPixbuf.Pixbuf.new_from_file(cache_path)
            else:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(filepath, w, h, False)
                pixbuf.savev(cache_path, "png", [], [])

            if pixbuf:
                self.mem_cache[(filepath, w, h)] = pixbuf
                GLib.idle_add(callback, pixbuf)
        except Exception as e:
            print(f"Error loading {filepath}: {e}")

class WallpaperDock(Gtk.Window):
    def __init__(self):
        super().__init__()
        
        self.set_title("WallpaperDock")
        self.set_wmclass("WallpaperDock", "WallpaperDock")
        self.set_decorated(False)
        self.set_app_paintable(True)
        self.set_keep_above(True)
        self.set_type_hint(Gdk.WindowTypeHint.DOCK)

        display = Gdk.Display.get_default()
        monitor = display.get_monitor_at_window(display.get_default_screen().get_root_window())
        geo = monitor.get_geometry()
        
        self.set_default_size(MAX_BAR_WIDTH, TOTAL_WINDOW_HEIGHT)
        self.move((geo.width - MAX_BAR_WIDTH)//2, geo.height - TOTAL_WINDOW_HEIGHT)

        # -- FIXED CSS --
        screen = Gdk.Screen.get_default()
        css = b"""
        window { 
            border-radius: 15px 15px 0 0; 
            background-color: rgba(0,0,0,1.0);
        }
        button { 
            background: transparent; 
            box-shadow: none; 
            padding: 2px; 
            margin: 0; 
            border-radius: 6px;
        }
        
        /* Side Images */
        #side_btn { 
            opacity: 1.0; 
            transition: opacity 0.2s; 
            border: 2px solid transparent; 
        }
        #side_btn:hover { 
            opacity: 1.0; 
        }

        /* Center Image - FIXED */
        #center_btn { 
            opacity: 1.0; 
            transition: all 0.2s; 
            border: 2px solid transparent; 
        }
        #center_btn:hover { 
            /* Full border frame instead of underline */
            border: 1px solid #ffffff; 
            background-color: rgba(255,255,255,0.1);
        }
        """
        style_provider = Gtk.CssProvider()
        style_provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(screen, style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        self.wallpapers = WallpaperManager.get_wallpapers()
        self.current_idx = 0
        self.loader = ImageLoader()

        if not self.wallpapers:
            print("No wallpapers found.")
            sys.exit(1)

        self.hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=15)
        self.hbox.set_halign(Gtk.Align.CENTER)
        self.hbox.set_valign(Gtk.Align.CENTER)
        self.add(self.hbox)

        self.img_prev = Gtk.Image()
        self.img_curr = Gtk.Image()
        self.img_next = Gtk.Image()
        
        self.img_prev.set_size_request(SIDE_W, SIDE_H)
        self.img_curr.set_size_request(CENTER_W, CENTER_H)
        self.img_next.set_size_request(SIDE_W, SIDE_H)

        self.btn_prev = self._make_btn(self.img_prev, "side_btn", -1)
        self.btn_curr = self._make_btn(self.img_curr, "center_btn", 0)
        self.btn_next = self._make_btn(self.img_next, "side_btn", 1)

        self.hbox.pack_start(self.btn_prev, False, False, 0)
        self.hbox.pack_start(self.btn_curr, False, False, 0)
        self.hbox.pack_start(self.btn_next, False, False, 0)

        self.add_events(Gdk.EventMask.SCROLL_MASK)
        self.connect("scroll-event", self.on_scroll)
        
        self.update_view()

    def _make_btn(self, image_widget, name, scroll_dir):
        btn = Gtk.Button()
        btn.set_name(name)
        btn.set_image(image_widget)
        if scroll_dir == 0:
            btn.connect("clicked", self.on_center_click)
        else:
            btn.connect("clicked", lambda w: self.shift(scroll_dir))
        return btn

    def shift(self, direction):
        self.current_idx += direction
        self.update_view()

    def on_scroll(self, widget, event):
        if event.direction in (Gdk.ScrollDirection.DOWN, Gdk.ScrollDirection.RIGHT):
            self.shift(1)
        elif event.direction in (Gdk.ScrollDirection.UP, Gdk.ScrollDirection.LEFT):
            self.shift(-1)
        return True

    def on_center_click(self, widget):
        path = self.wallpapers[self.current_idx % len(self.wallpapers)]
        WallpaperManager.set_wallpaper(path)

    def update_view(self):
        n = len(self.wallpapers)
        
        i_prev = (self.current_idx - 1) % n
        i_curr = (self.current_idx) % n
        i_next = (self.current_idx + 1) % n

        self.loader.get_pixbuf(self.wallpapers[i_prev], SIDE_W, SIDE_H, self.img_prev.set_from_pixbuf)
        self.loader.get_pixbuf(self.wallpapers[i_curr], CENTER_W, CENTER_H, self.img_curr.set_from_pixbuf)
        self.loader.get_pixbuf(self.wallpapers[i_next], SIDE_W, SIDE_H, self.img_next.set_from_pixbuf)

def main():
    if len(sys.argv) > 1 and sys.argv[1] == "cycle":
        try:
            m = WallpaperManager()
            w = m.get_wallpapers()
            if w: m.set_wallpaper(random.choice(w))
        except: pass
    else:
        win = WallpaperDock()
        win.connect("destroy", Gtk.main_quit)
        win.show_all()
        Gtk.main()

if __name__ == "__main__":
    main()
