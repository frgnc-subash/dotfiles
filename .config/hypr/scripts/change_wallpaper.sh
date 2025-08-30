#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
INDEX_FILE="$HOME/.last_wallpaper_index"

# Get all wallpapers sorted alphabetically
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort))

# If no wallpapers, exit
[ ${#WALLPAPERS[@]} -eq 0 ] && exit 0

# Read last index, default to -1 if file does not exist
if [ -f "$INDEX_FILE" ]; then
    LAST_INDEX=$(cat "$INDEX_FILE")
else
    LAST_INDEX=-1
fi

# Calculate next index (loop back if at end)
NEXT_INDEX=$(( (LAST_INDEX + 1) % ${#WALLPAPERS[@]} ))

# Pick the wallpaper
WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"

# Save the current index for next run
echo "$NEXT_INDEX" > "$INDEX_FILE"

# Generate random transition position
RAND_POS="$(shuf -i 1-99 -n 1 | awk '{printf "%.2f,%.2f", $1/100, $1/100}')"

# Wait until no transition is active
while pgrep -x swww-daemon > /dev/null && swww query | grep -q "Transition: true"; do
    sleep 0.05
done

# Set wallpaper using swww
swww img "$WALLPAPER" \
    --transition-type grow \
    --transition-pos "$RAND_POS" \
    --transition-step 5 \
    --transition-fps 120
