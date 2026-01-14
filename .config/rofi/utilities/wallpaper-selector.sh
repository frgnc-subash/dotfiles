#!/bin/bash

WALLPAPER_BASE="$HOME/Pictures/wallpapers"
HYPR_THEME_FILE="$HOME/.config/hypr/theme.conf"
ROFI_CONFIG="$HOME/.config/rofi/utilities/wallpaper-selector.rasi"
CACHE_DIR="$HOME/.cache/wallpaper-thumbnails"
CYCLE_STATE_FILE="$HOME/.cache/wallpaper-cycle-index"

CURRENT_SOURCE=$(grep "source =" "$HYPR_THEME_FILE" | awk '{print $3}')

if [[ "$CURRENT_SOURCE" == *"matugen"* ]]; then
    THEME_MODE="dynamic"
    TARGET_DIR="$WALLPAPER_BASE/wallpapers"
    THEME_CACHE="$CACHE_DIR/dynamic"
else
    THEME_MODE="static"
    THEME_NAME=$(basename "$(dirname "$CURRENT_SOURCE")")
    TARGET_DIR="$WALLPAPER_BASE/$THEME_NAME"
    THEME_CACHE="$CACHE_DIR/$THEME_NAME"
fi

if [ ! -d "$TARGET_DIR" ]; then
    notify-send "Error" "Dir not found: $TARGET_DIR"
    exit 1
fi

MODE="$1"

case "$MODE" in
"gui")
    mkdir -p "$THEME_CACHE"
    export THEME_CACHE
    export TARGET_DIR

    generate_thumb() {
        img="$1"
        filename=$(basename "$img")
        thumb_name="${filename%.*}.png"
        target="$THEME_CACHE/$thumb_name"

        if [ ! -s "$target" ]; then
            vipsthumbnail "$img[0]" --size 300x300 --smartcrop=attention -o "$target"
        fi
    }

    export -f generate_thumb

    find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) |
        xargs -P "$(nproc)" -I {} bash -c 'generate_thumb "{}"'

    SELECTED_FILE=$(
        find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | sort | while read -r img; do
            filename=$(basename "$img")
            thumb_name="${filename%.*}.png"
            echo -en "$filename\0icon\x1f$THEME_CACHE/$thumb_name\n"
        done | rofi -dmenu -i -show-icons -p "Wallpaper" -theme "$ROFI_CONFIG"
    )
    ;;
"cycle")
    mapfile -t WALLPAPERS < <(
        find "$TARGET_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | sort
    )

    COUNT="${#WALLPAPERS[@]}"
    [ "$COUNT" -eq 0 ] && exit 1

    if [ -f "$CYCLE_STATE_FILE" ]; then
        INDEX=$(cat "$CYCLE_STATE_FILE")
    else
        INDEX=0
    fi

    SELECTED_FILE="$(basename "${WALLPAPERS[$INDEX]}")"

    INDEX=$(((INDEX + 1) % COUNT))
    echo "$INDEX" >"$CYCLE_STATE_FILE"
    ;;
*)
    echo "Usage: $0 {gui|cycle}"
    exit 1
    ;;
esac

if [ -z "$SELECTED_FILE" ]; then
    exit 0
fi

FULL_PATH="$TARGET_DIR/$SELECTED_FILE"

if [ "$THEME_MODE" == "dynamic" ]; then
    swww img "$FULL_PATH" --transition-type any --transition-duration 1.5 --transition-fps 90

    matugen image "$FULL_PATH"
else
    swww img "$FULL_PATH" --transition-type any --transition-duration 1.5 --transition-fps 90
fi
