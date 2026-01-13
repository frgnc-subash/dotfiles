#!/bin/bash

killall -q waybar
pkill -f "cava -p /tmp/waybar_cava_config"

while pgrep -x waybar >/dev/null || pgrep -f "cava -p /tmp/waybar_cava_config" >/dev/null; do
    sleep 0.1
done

waybar &
disown

hyprctl reload
