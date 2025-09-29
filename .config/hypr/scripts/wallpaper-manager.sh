#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers/wallpapers"

# Function to set wallpaper with swww + matugen
set_wallpaper() {
  local wallpaper="$1"

  # Generate random transition position
  local rand_pos="$(shuf -i 1-99 -n 1 | awk '{printf "%.2f,%.2f", $1/100, $1/100}')"

  # Wait until no transition is active
  while pgrep -x swww-daemon >/dev/null && swww query | grep -q "Transition: true"; do
    sleep 0.05
  done

  # Set wallpaper using swww
  swww img "$wallpaper" \
    --transition-type any \
    --transition-pos "$rand_pos" \
    --transition-step 15 \
    --transition-fps 120

  # Apply Matugen theme (this will trigger Hyprland + Waybar reloads via your config)
  matugen image "$wallpaper"
}

# Function to cycle wallpaper randomly
cycle_wallpaper() {
  # Get all wallpapers
  local wallpapers=($(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \)))

  # If no wallpapers, exit
  [ ${#wallpapers[@]} -eq 0 ] && exit 0

  # Pick a random wallpaper
  local wallpaper="${wallpapers[$RANDOM % ${#wallpapers[@]}]}"

  # Set the wallpaper
  set_wallpaper "$wallpaper"
}

# Main command handling
case "${1:-cycle}" in
  "cycle") cycle_wallpaper ;;
  "set")
    if [ -n "$2" ]; then
      set_wallpaper "$2"
    else
      echo "Usage: $0 set <wallpaper-path>"
    fi
    ;;
  "help")
    echo "Wallpaper Manager Commands:"
    echo "  cycle      - Set a random wallpaper and apply Matugen colors"
    echo "  set <path> - Set a specific wallpaper and apply Matugen colors"
    echo "  help       - Show this help"
    ;;
  *) cycle_wallpaper ;;
esac
