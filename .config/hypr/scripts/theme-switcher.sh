#!/bin/bash

THEME="$1"
HYPR_DIR="$HOME/.config/hypr"
THEME_DIR="$HYPR_DIR/themes/$THEME"


if [ "$THEME" == "mocha" ]; then
    GTK_THEME="catppuccin-mocha-sapphire-standard+default"
    ICON_THEME="Papirus-Dark"
    KITTY_THEME="Catppuccin-Mocha"
    SWAYNC_COLOR="#1e1e2e"
    
elif [ "$THEME" == "tokyo" ]; then
    GTK_THEME="Tokyonight-Dark"
    ICON_THEME="Papirus-Dark"
    KITTY_THEME="Tokyo Night"
    SWAYNC_COLOR="#1a1b26"

elif [ "$THEME" == "moonfly" ]; then
   
    GTK_THEME="Materia-dark" 
    ICON_THEME="Papirus-Dark"
    KITTY_THEME="Moonfly" 
    SWAYNC_COLOR="#080808"
else
    echo "Available themes: mocha, tokyo, moonfly"
    exit 1
fi


ln -sf "$THEME_DIR/theme.conf" "$HYPR_DIR/themes/current.conf"
ln -sf "$THEME_DIR/waybar.css" "$HYPR_DIR/themes/colors.css"


kitty +kitten themes --reload-in=all "$KITTY_THEME"


echo ".notification-row { outline: none; } .control-center { background: $SWAYNC_COLOR; }" > ~/.config/swaync/style.css
swaync-client -rs 


gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"


killall waybar
waybar &
hyprctl reload

notify-send "Theme Switched" "Active: $THEME"