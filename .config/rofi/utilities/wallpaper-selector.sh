#!/bin/bash

WALLPAPER_BASE="$HOME/Pictures/wallpapers"
HYPR_THEME_FILE="$HOME/.config/hypr/theme.conf"
ROFI_CONFIG="$HOME/.config/rofi/utilities/wallpaper-selector.rasi"
CACHE_DIR="$HOME/.cache/wallpaper-thumbnails"

CURRENT_SOURCE=$(grep "source =" "$HYPR_THEME_FILE" | awk '{print $3}')
if [[ "$CURRENT_SOURCE" == *"matugen"* ]]; then
    THEME_MODE="dynamic"; TARGET_DIR="$WALLPAPER_BASE/wallpapers"; THEME_NAME="dynamic"
else
    THEME_MODE="static"; THEME_NAME=$(basename "$(dirname "$CURRENT_SOURCE")"); TARGET_DIR="$WALLPAPER_BASE/$THEME_NAME"
fi

THEME_CACHE="$CACHE_DIR/$THEME_NAME"; mkdir -p "$THEME_CACHE"

generate_thumb() {
    img="$1"; thumb="$2/$(basename "${img%.*}.png")"
    [ ! -s "$thumb" ] && vipsthumbnail "$img[0]" --size 400x225 --smartcrop=attention -o "$thumb"
}
export -f generate_thumb

if [ "$1" == "gui" ]; then
    find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) | xargs -P "$(nproc)" -I {} bash -c "generate_thumb \"{}\" \"$THEME_CACHE\""
    SELECTED_FILE=$(find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) | sort | while read -r img; do
            echo -en "$(basename "$img")\0icon\x1f$THEME_CACHE/$(basename "${img%.*}.png")\n"
    done | rofi -dmenu -i -show-icons -p " " -theme "$ROFI_CONFIG")
else
    SELECTED_PATH=$(find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.jpeg" \) | shuf -n 1)
    [ -n "$SELECTED_PATH" ] && SELECTED_FILE=$(basename "$SELECTED_PATH")
fi

if [ -n "$SELECTED_FILE" ]; then
    FULL_PATH="$TARGET_DIR/$SELECTED_FILE"
    swww img "$FULL_PATH" --transition-type any --transition-duration 1.5 --transition-fps 90
    [ "$THEME_MODE" == "dynamic" ] && matugen image "$FULL_PATH"
fi