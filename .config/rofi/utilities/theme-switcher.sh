#!/bin/bash

# --- CONFIGURATION ---
THEME_DIR="$HOME/.config/btop/themes"
BTOP_CONF="$HOME/.config/btop/btop.conf"
ROFI_THEME="$HOME/.config/rofi/config.rasi"

# --- CHECKS ---
if [ ! -d "$THEME_DIR" ]; then
    notify-send "Error" "Theme directory not found!" -u critical
    exit 1
fi

# --- LOGIC ---
# Get themes
THEMES=$(ls "$THEME_DIR"/*.theme | xargs -n 1 basename | sed 's/\.theme//')

# Show Rofi
CHOICE=$(echo "$THEMES" | rofi -dmenu -i -theme "$ROFI_THEME" -p "")

if [ -z "$CHOICE" ]; then
    exit 0
fi

# --- APPLY THEME (LIVE UPDATE) ---

# 1. Prepare the new configuration line
NEW_CONF="color_theme = \"$CHOICE\""

# 2. Update the file WITHOUT changing the inode.
#    (sed -i creates a new file; using a temp file + cat preserves the file handle
#    so running instances of btop don't lose track of it.)
if grep -q "^color_theme =" "$BTOP_CONF"; then
    # Create a temp file with the change
    sed "s|^color_theme = .*|$NEW_CONF|" "$BTOP_CONF" >"$BTOP_CONF.tmp"
    # Overwrite the original file content
    cat "$BTOP_CONF.tmp" >"$BTOP_CONF"
    # Remove temp
    rm "$BTOP_CONF.tmp"
else
    # Fallback if line doesn't exist
    echo "$NEW_CONF" >>"$BTOP_CONF"
fi

# 3. Force btop to redraw immediately
#    Sending SIGWINCH (Signal 28) forces btop to recalculate sizes and redraw,
#    which makes it pick up the new colors instantly without waiting for the update timer.
pkill -USR2 btop || pkill -WINCH btop

# 4. Notify
notify-send "Btop" "Theme set to: $CHOICE" -t 2000

