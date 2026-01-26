#!/bin/bash

pkill waybar
killall -q swaync
pkill -f "cava -p /tmp/waybar_cava_config"

while pgrep -x waybar >/dev/null || pgrep -x swaync >/dev/null || pgrep -f "cava -p /tmp/waybar_cava_config" >/dev/null; do
    sleep 0.1
done

waybar &
swaync &
disown

hyprctl reload
