#!/bin/bash

WALLPAPER_DIR="/home/axosis/Pictures/Wallpapers"
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n 1)
RAND_POS="$(shuf -i 1-99 -n 1 | awk '{printf "%.2f,%.2f", $1/100, $1/100}')"

# Wait until no transition is happening
while pgrep -x swww-daemon > /dev/null && swww query | grep -q "Transition: true"; do
    sleep 0.05
done

swww img "$WALLPAPER" \
  --transition-type grow \
  --transition-pos "$RAND_POS" \
  --transition-step 20 \
  --transition-fps 60
