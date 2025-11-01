#!/usr/bin/env bash
# clipmenu.sh - Clipboard history menu with "Clear Clipboard" button

NUM_ENTRIES=10 # number of entries to show

# Fetch last NUM_ENTRIES oldest-first
mapfile -t HISTORY < <(cliphist list | tac | tail -n "$NUM_ENTRIES")

# Add "Clear Clipboard" option at the top
MENU=()
MENU+=("🗑️ Clear Clipboard")
MENU+=("${HISTORY[@]}")

# Show menu in rofi and get selected line
SELECTED=$(printf '%s\n' "${MENU[@]}" | rofi -dmenu -p "Clipboard History:")

# If nothing selected, exit
[ -z "$SELECTED" ] && exit

# Handle Clear Clipboard selection
if [ "$SELECTED" = "🗑️ Clear Clipboard" ]; then
    cliphist wipe     # clear history database
    echo -n | wl-copy # clear current clipboard
    exit
fi

# Extract ID from selected line and copy
ID=$(echo "$SELECTED" | cut -d: -f1)
cliphist decode "$ID" | wl-copy
