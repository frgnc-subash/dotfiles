#!/bin/bash

# SWITCHER_SCRIPT="$HOME/.config/hypr/scripts/switch_theme.sh"
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

OPTION_MOCHA=">⩊< Catppuccin Mocha"
OPTION_TOKYO="⋆˙⟡ Tokyo Night"
OPTION_MOON="☽◯☾ Moonfly"

CHOICE=$(echo -e "$OPTION_MOCHA\n$OPTION_TOKYO\n$OPTION_MOON" | rofi -dmenu \
    -config "$ROFI_CONFIG" \
    -p "themes" \
    -theme-str 'entry { placeholder: "Select a theme..."; }' \
    -theme-str 'window { width: 400px; }' \
-theme-str 'listview { lines: 3; }')

case "$CHOICE" in
    "$OPTION_MOCHA")
        "$SWITCHER_SCRIPT" mocha
    ;;
    "$OPTION_TOKYO")
        "$SWITCHER_SCRIPT" tokyo
    ;;
    "$OPTION_MOON")
        "$SWITCHER_SCRIPT" moonfly
    ;;
    *)
        echo "No theme selected"
        exit 0
    ;;
esac