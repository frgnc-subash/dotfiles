#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers/wallpapers"
INDEX_FILE="$HOME/.last_wallpaper_index"
CURRENT_WALL_FILE="$HOME/.current_wallpaper"

# Function to set wallpaper with swww
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

  # Save current wallpaper path
  echo "$wallpaper" >"$CURRENT_WALL_FILE"
}

# Function to cycle to next wallpaper
cycle_wallpaper() {
  # Get all wallpapers sorted alphabetically
  local wallpapers=($(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort))

  # If no wallpapers, exit
  [ ${#wallpapers[@]} -eq 0 ] && exit 0

  # Read last index, default to -1 if file does not exist
  if [ -f "$INDEX_FILE" ]; then
    local last_index=$(cat "$INDEX_FILE")
  else
    local last_index=-1
  fi

  # Calculate next index (loop back if at end)
  local next_index=$(((last_index + 1) % ${#wallpapers[@]}))

  # Pick the wallpaper
  local wallpaper="${wallpapers[$next_index]}"

  # Save the current index for next run
  echo "$next_index" >"$INDEX_FILE"

  # Set the wallpaper
  set_wallpaper "$wallpaper"
}

# Function to launch Waypaper GUI
launch_gui() {
  # Check if swww is running, initialize if not
  if ! pgrep -x "swww-daemon" >/dev/null; then
    swww init
    sleep 1
  fi

  # Launch waypaper
  waypaper

  # After waypaper closes, update our index to match the selected wallpaper
  if [ -f "$CURRENT_WALL_FILE" ]; then
    current_wall=$(cat "$CURRENT_WALL_FILE")
    update_index_for_wallpaper "$current_wall"
  fi
}

# Function to update index based on selected wallpaper
update_index_for_wallpaper() {
  local selected_wallpaper="$1"
  local wallpapers=($(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort))

  for i in "${!wallpapers[@]}"; do
    if [[ "${wallpapers[$i]}" == "$selected_wallpaper" ]]; then
      echo "$i" >"$INDEX_FILE"
      break
    fi
  done
}

# Function to set specific wallpaper (for waypaper integration)
set_specific_wallpaper() {
  local wallpaper="$1"
  set_wallpaper "$wallpaper"
  update_index_for_wallpaper "$wallpaper"
}

# Function to show current wallpaper
show_current() {
  if [ -f "$CURRENT_WALL_FILE" ]; then
    echo "Current wallpaper: $(cat "$CURRENT_WALL_FILE")"
  else
    echo "No wallpaper set yet"
  fi
}

# Main command handling
case "${1:-cycle}" in
"cycle")
  cycle_wallpaper
  ;;
"gui")
  launch_gui
  ;;
"set")
  if [ -n "$2" ]; then
    set_specific_wallpaper "$2"
  else
    echo "Usage: $0 set <wallpaper-path>"
  fi
  ;;
"current")
  show_current
  ;;
"help")
  echo "Wallpaper Manager Commands:"
  echo "  cycle      - Cycle to next wallpaper"
  echo "  gui        - Open Waypaper GUI"
  echo "  set <path> - Set specific wallpaper"
  echo "  current    - Show current wallpaper"
  echo "  help       - Show this help"
  ;;
*)
  cycle_wallpaper
  ;;
esac
