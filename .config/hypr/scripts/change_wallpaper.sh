#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Get all wallpapers
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \)))

# Ask user: random or choose
choice=$(echo -e "Random\nChoose" | rofi -dmenu -p "Wallpaper selection:")

if [ "$choice" == "Random" ]; then
    WALLPAPER=$(printf "%s\n" "${WALLPAPERS[@]}" | shuf -n 1)
elif [ "$choice" == "Choose" ]; then
    WALLPAPER=$(zenity --file-selection \
        --title="Select Wallpaper" \
        --filename="$WALLPAPER_DIR/" \
        --file-filter="Images | *.jpg *.jpeg *.png")
    
    # If user cancels, exit
    [ -z "$WALLPAPER" ] && exit 0
else
    exit 0
fi

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
