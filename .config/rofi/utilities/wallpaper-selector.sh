#!/bin/bash

WALLPAPER_BASE="$HOME/Pictures/wallpapers"
HYPR_THEME_FILE="$HOME/.config/hypr/theme.conf"
ROFI_CONFIG="$HOME/.config/rofi/utilities/wallpaper-selector.rasi"
CACHE_DIR="$HOME/.cache/wallpaper-thumbnails"

CURRENT_SOURCE=$(grep "source =" "$HYPR_THEME_FILE" | awk '{print $3}')
if [[ "$CURRENT_SOURCE" == *"matugen"* ]]; then
    THEME_MODE="dynamic"
    TARGET_DIR="$WALLPAPER_BASE/wallpapers"
    THEME_NAME="dynamic"
else
    THEME_MODE="static"
    THEME_NAME=$(basename "$(dirname "$CURRENT_SOURCE")")
    TARGET_DIR="$WALLPAPER_BASE/$THEME_NAME"
fi

THEME_CACHE="$CACHE_DIR/$THEME_NAME"
mkdir -p "$THEME_CACHE"

generate_thumb() {
    img="$1"
    cache_dir="$2"
    thumb="$cache_dir/$(basename "${img%.*}.png")"

    [ -s "$thumb" ] && return

    ext="${img##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    if [ "$ext_lower" = "gif" ]; then
        # Count frames and pick the middle one for a representative thumbnail
        frame_count=$(ffprobe -v error -select_streams v:0 \
            -count_packets -show_entries stream=nb_read_packets \
            -of csv=p=0 "$img" 2>/dev/null)
        frame_count=${frame_count:-1}
        mid_frame=$((frame_count / 2))

        ffmpeg -v error -i "$img" \
            -vf "select=eq(n\,$mid_frame),scale=400:225:force_original_aspect_ratio=decrease,pad=400:225:(ow-iw)/2:(oh-ih)/2" \
            -frames:v 1 "$thumb"
    else
        vipsthumbnail "$img[0]" --size 400x225 --smartcrop=attention -o "$thumb"
    fi
}

export -f generate_thumb

FIND_PATTERNS=(-iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif")

if [ "$1" = "gui" ]; then
    find "$TARGET_DIR" -maxdepth 1 -type f \( "${FIND_PATTERNS[@]}" \) |
        xargs -P "$(nproc)" -I {} bash -c 'generate_thumb "$@"' _ {} "$THEME_CACHE"

    SELECTED_FILE=$(
        find "$TARGET_DIR" -maxdepth 1 -type f \( "${FIND_PATTERNS[@]}" \) | sort |
            while read -r img; do
                base=$(basename "$img")
                ext_lower=$(echo "${img##*.}" | tr '[:upper:]' '[:lower:]')
                thumb="$THEME_CACHE/$(basename "${img%.*}.png")"

                if [ "$ext_lower" = "gif" ]; then
                    label="▶ $base"
                else
                    label="$base"
                fi

                echo -en "${label}\0icon\x1f${thumb}\n"
            done |
            rofi -dmenu -i -show-icons -p " " -theme "$ROFI_CONFIG"
    )

    SELECTED_FILE="${SELECTED_FILE#▶ }"

else
    SELECTED_PATH=$(find "$TARGET_DIR" -maxdepth 1 -type f \( "${FIND_PATTERNS[@]}" \) | shuf -n 1)
    [ -n "$SELECTED_PATH" ] && SELECTED_FILE=$(basename "$SELECTED_PATH")
fi

if [ -n "$SELECTED_FILE" ]; then
    FULL_PATH="$TARGET_DIR/$SELECTED_FILE"
    ext_lower=$(echo "${SELECTED_FILE##*.}" | tr '[:upper:]' '[:lower:]')

    awww img "$FULL_PATH" \
        --transition-type any \
        --transition-duration 1.5 \
        --transition-fps 90

    if [ "$THEME_MODE" = "dynamic" ]; then
        if [ "$ext_lower" = "gif" ]; then
            GIF_FRAME_TMP=$(mktemp /tmp/matugen-frame-XXXXXX.png)
            ffmpeg -v error -i "$FULL_PATH" -vframes 1 "$GIF_FRAME_TMP"
            matugen image "$GIF_FRAME_TMP"
            rm -f "$GIF_FRAME_TMP"
        else
            matugen image "$FULL_PATH"
        fi
    fi
fi
