#!/bin/bash

# Toggle file location
TOGGLE_FILE="/tmp/waybar-clock-toggle"

# Check if toggle file exists
if [ -f "$TOGGLE_FILE" ]; then
    # File exists - remove it (switch to clock mode)
    rm "$TOGGLE_FILE"
else
    # File doesn't exist - create it (switch to date mode)
    touch "$TOGGLE_FILE"
fi

# Signal Waybar to update the clock module
pkill -SIGRTMIN+8 waybar
