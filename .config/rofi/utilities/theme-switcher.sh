#!/bin/bash

THEME_CONFIG_DIR="$HOME/.config/themes"
MATUGEN_GEN="$HOME/.config/matugen/generated"
WALLPAPER_BASE="$HOME/Pictures/wallpapers"

HYPR_THEME_FILE="$HOME/.config/hypr/theme.conf"
WAYBAR_THEME_FILE="$HOME/.config/waybar/theme.css"
ROFI_THEME_FILE="$HOME/.config/rofi/theme.rasi"
SWAYNC_THEME_FILE="$HOME/.config/swaync/theme.css"
SWAYOSD_THEME_FILE="$HOME/.config/swayosd/theme.css"
KITTY_THEME_FILE="$HOME/.config/kitty/theme.conf"

SWAYOSD_RELOAD_SCRIPT="$HOME/.config/swayosd/scripts/restartOSD.sh"

CURRENT_SOURCE=$(grep "source =" "$HYPR_THEME_FILE" | awk '{print $3}')

if [[ "$CURRENT_SOURCE" == *"matugen"* ]]; then
    ACTIVE_THEME="dynamic"
else
    ACTIVE_THEME=$(basename $(dirname "$CURRENT_SOURCE"))
fi

THEME_LIST=""
for theme_dir in "$THEME_CONFIG_DIR"/*/; do
    theme_name=$(basename "$theme_dir")
    if [ "$theme_name" == "$ACTIVE_THEME" ]; then
        THEME_LIST+="${theme_name} *\n"
    else
        THEME_LIST+="${theme_name}\n"
    fi
done

RAW_SELECTION=$(echo -e "$THEME_LIST" | rofi -dmenu -i -p "Select Theme")

if [ -z "$RAW_SELECTION" ]; then exit 0; fi

SELECTED_THEME=$(echo "$RAW_SELECTION" | awk '{print $1}')

if [ "$SELECTED_THEME" == "dynamic" ]; then
    SEARCH_DIR="$WALLPAPER_BASE/wallpapers"
    WALLPAPER=$(find "$SEARCH_DIR" -type f | shuf -n 1)
    
    if [ -z "$WALLPAPER" ]; then 
        notify-send "Error" "No wallpapers found in $SEARCH_DIR"
        exit 1
    fi

    HYPR_SOURCE="$MATUGEN_GEN/hypr-colors.conf"
    WAYBAR_SOURCE="$MATUGEN_GEN/colors.css"
    ROFI_SOURCE="$MATUGEN_GEN/rofi-colors.rasi"
    SWAYNC_SOURCE="$MATUGEN_GEN/colors.css"
    SWAYOSD_SOURCE="$MATUGEN_GEN/swayosd-colors.css"
    KITTY_SOURCE="$MATUGEN_GEN/kitty-colors.conf"

else
    CURRENT_CONFIG_PATH="$THEME_CONFIG_DIR/$SELECTED_THEME"
    SEARCH_DIR="$WALLPAPER_BASE/$SELECTED_THEME"
    
    WALLPAPER=$(find "$SEARCH_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

    HYPR_SOURCE="$CURRENT_CONFIG_PATH/hyprland.conf"
    WAYBAR_SOURCE="$CURRENT_CONFIG_PATH/waybar.css"
    ROFI_SOURCE="$CURRENT_CONFIG_PATH/rofi.rasi"
    SWAYNC_SOURCE="$CURRENT_CONFIG_PATH/swaync.css"
    SWAYOSD_SOURCE="$CURRENT_CONFIG_PATH/swayosd.css"
    KITTY_SOURCE="$CURRENT_CONFIG_PATH/kitty.conf"
fi

echo "source = $HYPR_SOURCE" > "$HYPR_THEME_FILE"
echo "@import \"$WAYBAR_SOURCE\";" > "$WAYBAR_THEME_FILE"
echo "@import \"$ROFI_SOURCE\"" > "$ROFI_THEME_FILE"
echo "@import \"$SWAYNC_SOURCE\";" > "$SWAYNC_THEME_FILE"
echo "@import \"$SWAYOSD_SOURCE\";" > "$SWAYOSD_THEME_FILE"
echo "include $KITTY_SOURCE" > "$KITTY_THEME_FILE"

if [ -n "$WALLPAPER" ]; then
    swww img "$WALLPAPER" --transition-type any --transition-duration 1.5 --transition-fps 90
fi

if [ "$SELECTED_THEME" == "dynamic" ]; then
    matugen image "$WALLPAPER"
else
    hyprctl reload > /dev/null
    kill -SIGUSR2 $(pidof waybar)
    swaync-client -R && swaync-client -rs
    kill -SIGUSR1 $(pidof kitty)
    
    if [ -x "$SWAYOSD_RELOAD_SCRIPT" ]; then
        "$SWAYOSD_RELOAD_SCRIPT"
    fi
fi

notify-send -i "$WALLPAPER" "Theme Activated" "<b>$SELECTED_THEME</b> applied."