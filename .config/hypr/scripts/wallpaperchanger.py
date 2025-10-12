#!/usr/bin/env python3
import gi
import os
import subprocess
import threading
import sys
import random
import time

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GdkPixbuf, GLib

# ---------------- CONFIG ----------------
WALLPAPER_DIR = os.path.expanduser("~/Pictures/wallpapers/wallpapers")
THUMBNAIL_WIDTH = 800
THUMBNAIL_HEIGHT = 300
SCROLL_SPEED = 150
MAX_BAR_WIDTH = 1350 
# ----------------------------------------

class WallpaperManager:
    @staticmethod
    def set_wallpaper(wallpaper):
        """Set wallpaper with swww + matugen (from bash script)"""
        rand_pos = f"{random.randint(1, 99)/100:.2f},{random.randint(1, 99)/100:.2f}"

 
        while WallpaperManager._is_swww_transition_active():
            time.sleep(0.05)

        # Set wallpaper using swww
        subprocess.Popen([
            "swww", "img", wallpaper,
            "--transition-type", "any",
            "--transition-pos", rand_pos,
            "--transition-step", "15",
            "--transition-fps", "120"
        ])

       
        subprocess.Popen(["matugen", "image", wallpaper])

    @staticmethod
    def _is_swww_transition_active():
        """Check if swww transition is active"""
        try:
          
            daemon_running = subprocess.run(["pgrep", "-x", "swww-daemon"], 
                                          capture_output=True).returncode == 0
            
            if daemon_running:
               
                result = subprocess.run(["swww", "query"], capture_output=True, text=True)
                return "Transition: true" in result.stdout
            return False
        except:
            return False

    @staticmethod
    def cycle_wallpaper():
        """Cycle wallpaper randomly (from bash script)"""
        try:
       
            wallpapers = []
            for ext in ('*.jpg', '*.png', '*.jpeg', '*.gif'):
                wallpapers.extend(
                    os.path.join(WALLPAPER_DIR, f) 
                    for f in os.listdir(WALLPAPER_DIR) 
                    if f.lower().endswith(ext[1:])
                )
            
            if not wallpapers:
                print("No wallpapers found in directory")
                return
            
        
            wallpaper = random.choice(wallpapers)
            
          
            WallpaperManager.set_wallpaper(wallpaper)
            print(f"Set wallpaper: {os.path.basename(wallpaper)}")
            
        except Exception as e:
            print(f"Error cycling wallpaper: {e}")

class WallpaperDock(Gtk.Window):
    def __init__(self):
        super().__init__()
        
     
        self.set_title("WallpaperDock")
        self.set_name("WallpaperDock")
        self.set_decorated(False)
        self.set_app_paintable(True)
        self.set_keep_above(True)
        self.set_type_hint(Gdk.WindowTypeHint.DOCK)

       
        display = Gdk.Display.get_default()
        monitor = display.get_monitor_at_window(display.get_default_screen().get_root_window())
        geometry = monitor.get_geometry()
        width, height = geometry.width, geometry.height

        self.set_default_size(MAX_BAR_WIDTH, THUMBNAIL_HEIGHT + 20)
        self.move((width - MAX_BAR_WIDTH)//2, height - (THUMBNAIL_HEIGHT + 20))

     
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

 
        self.scrolled = Gtk.ScrolledWindow()
        self.scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.NEVER)
        self.scrolled.set_propagate_natural_height(True)
        self.scrolled.set_min_content_height(THUMBNAIL_HEIGHT + 20)
        self.add(self.scrolled)

       
        self.hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=15)
        self.hbox.set_halign(Gtk.Align.START)
        self.hbox.set_hexpand(False)
        self.scrolled.add(self.hbox)

        self.scrolled.add_events(Gdk.EventMask.SCROLL_MASK)
        self.scrolled.connect("scroll-event", self.on_scroll_event)

  
        threading.Thread(target=self.load_wallpapers, daemon=True).start()

    def load_wallpapers(self):
        files = sorted([f for f in os.listdir(WALLPAPER_DIR)
                        if f.lower().endswith((".jpg", ".png", ".jpeg", ".gif"))])

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
        WallpaperManager.set_wallpaper(filepath)

    def on_scroll_event(self, widget, event):
        adj = self.scrolled.get_hadjustment()
        if event.direction == Gdk.ScrollDirection.UP or event.delta_y < 0:
            adj.set_value(max(adj.get_lower(), adj.get_value() - SCROLL_SPEED))
        elif event.direction == Gdk.ScrollDirection.DOWN or event.delta_y > 0:
            adj.set_value(min(adj.get_upper() - adj.get_page_size(), adj.get_value() + SCROLL_SPEED))
        return True

def handle_cli():
    """Handle command line arguments"""
    command = sys.argv[1] if len(sys.argv) > 1 else "cycle"
    
    if command == "cycle":
        WallpaperManager.cycle_wallpaper()
    elif command == "set":
        if len(sys.argv) > 2:
            WallpaperManager.set_wallpaper(sys.argv[2])
        else:
            print("Usage: wallpaper_manager.py set <wallpaper-path>")
            sys.exit(1)
    elif command == "gui":
        start_gui()
    elif command == "help":
        print("Wallpaper Manager Commands:")
        print("  cycle      - Set a random wallpaper and apply Matugen colors")
        print("  set <path> - Set a specific wallpaper and apply Matugen colors")
        print("  gui        - Start the graphical wallpaper selector")
        print("  help       - Show this help")
    else:
        WallpaperManager.cycle_wallpaper()

def start_gui():
    """Start the GUI application"""
    win = WallpaperDock()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()

def main():
    if len(sys.argv) > 1:
        handle_cli()
    else:
      
        start_gui()

if __name__ == "__main__":
    main()