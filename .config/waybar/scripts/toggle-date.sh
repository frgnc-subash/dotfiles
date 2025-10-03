#!/bin/bash


TOGGLE_FILE="/tmp/waybar-clock-toggle"


if [ -f "$TOGGLE_FILE" ]; then
    
    rm "$TOGGLE_FILE"
else
    
    touch "$TOGGLE_FILE"
fi


pkill -SIGRTMIN+8 waybar
