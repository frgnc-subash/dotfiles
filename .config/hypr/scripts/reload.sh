#!/bin/bash

pkill waybar
pkill -f cava.sh
pkill -f "/home/axosis/.config/waybar/scripts/cava.sh"
pkill -f cava

waybar &

hyprctl reload
