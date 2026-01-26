#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
LAYOUTS_DIR="$WAYBAR_DIR/layouts"
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

current_pos=$(grep "\"position\":" "$WAYBAR_DIR/config.jsonc" 2>/dev/null)
ACTIVE=""
[[ "$current_pos" == *"left"* ]] && ACTIVE="vertical"
[[ "$current_pos" == *"top"* ]] && ACTIVE="top"

MENU_LIST=""
for layout in "$LAYOUTS_DIR"/*/; do
    name=$(basename "$layout")
    if [ "$name" == "$ACTIVE" ]; then
        MENU_LIST+="${name} *\n"
    else
        MENU_LIST+="${name}\n"
    fi
done

SELECTION=$(echo -en "$MENU_LIST" | sed '/^$/d' | rofi -dmenu -i -p "󰃚 Waybar Layout")
[ -z "$SELECTION" ] && exit 0
CHOICE=$(echo "$SELECTION" | awk '{print $1}')

if [ -d "$LAYOUTS_DIR/$CHOICE" ]; then
    cp "$LAYOUTS_DIR/$CHOICE/config.jsonc" "$WAYBAR_DIR/config.jsonc"
    cp "$LAYOUTS_DIR/$CHOICE/style.css" "$WAYBAR_DIR/style.css"

    if [ "$CHOICE" == "vertical" ]; then
        TARGET="vertAni.conf"
    else
        TARGET="horizAni.conf"
    fi

    if grep -q "Ani.conf" "$HYPR_CONF"; then
        sed -i "s|source = .*Ani.conf|source = ~/.config/hypr/conf/$TARGET|" "$HYPR_CONF"
    else
        echo "source = ~/.config/hypr/conf/$TARGET" >>"$HYPR_CONF"
    fi

    hyprctl reload >/dev/null

    killall -q waybar
    while pgrep -x waybar >/dev/null; do sleep 0.1; done
    waybar &
    disown

    notify-send "System" "Layout: $CHOICE | Animation: $TARGET"
fi

pkill -f "cava -p /tmp/waybar_cava_config"
