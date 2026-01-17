#!/bin/bash

THEME_CONFIG_DIR="$HOME/.config/themes"
MATUGEN_GEN="$HOME/.config/matugen/generated"
WALLPAPER_BASE="$HOME/Pictures/wallpapers"

HYPR_THEME_FILE="$HOME/.config/hypr/theme.conf"
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
TMUX_THEME_FILE="$HOME/.config/tmux/theme.conf"
GTK3_CONF="$HOME/.config/gtk-3.0/gtk.css"
GTK4_CONF="$HOME/.config/gtk-4.0/gtk.css"

NVIM_THEME_NAME_FILE="$HOME/.config/nvim/theme_name.txt"

WAYBAR_THEME_FILE="$HOME/.config/waybar/theme.css"
ROFI_THEME_FILE="$HOME/.config/rofi/theme.rasi"
SWAYNC_THEME_FILE="$HOME/.config/swaync/theme.css"
SWAYOSD_THEME_FILE="$HOME/.config/swayosd/theme.css"
KITTY_THEME_FILE="$HOME/.config/kitty/theme.conf"

SWAYOSD_RELOAD_SCRIPT="$HOME/.config/swayosd/scripts/restartOSD.sh"

CURRENT_SOURCE=$(grep "source =" "$HYPR_THEME_FILE" | awk '{print $3}')
if [[ "$CURRENT_SOURCE" == *"matugen"* ]]; then
    ACTIVE_THEME="dynamic"
else
    ACTIVE_THEME=$(basename $(dirname "$CURRENT_SOURCE"))
fi

THEME_LIST=""
for theme_dir in "$THEME_CONFIG_DIR"/*/; do
    theme_name=$(basename "$theme_dir")

    icon_path="${theme_dir}icon.png"
    [ ! -f "$icon_path" ] && icon_path=$(find "$WALLPAPER_BASE/$theme_name" -type f | head -n 1)
    [ -z "$icon_path" ] && icon_path="preferences-desktop-theme"

    if [ "$theme_name" == "$ACTIVE_THEME" ]; then
        THEME_LIST+="${theme_name} *\0icon\x1f${icon_path}\n"
    else
        THEME_LIST+="${theme_name}\0icon\x1f${icon_path}\n"
    fi
done

RAW_SELECTION=$(echo -en "$THEME_LIST" | sed '/^$/d' | rofi -dmenu -i -show-icons -p "Select Theme")
[ -z "$RAW_SELECTION" ] && exit 0

SELECTED_THEME=$(echo "$RAW_SELECTION" | awk '{print $1}')
CURRENT_CONFIG_PATH="$THEME_CONFIG_DIR/$SELECTED_THEME"

if [ "$SELECTED_THEME" == "dynamic" ]; then
    SEARCH_DIR="$WALLPAPER_BASE/wallpapers"
    WALLPAPER=$(find "$SEARCH_DIR" -type f | shuf -n 1)
    swww img "$WALLPAPER" --transition-type any --transition-duration 1.5 --transition-fps 90

    matugen image "$WALLPAPER"

    HYPR_SOURCE="$MATUGEN_GEN/hypr-colors.conf"
    WAYBAR_SOURCE="$MATUGEN_GEN/colors.css"
    ROFI_SOURCE="$MATUGEN_GEN/rofi-colors.rasi"
    SWAYNC_SOURCE="$MATUGEN_GEN/colors.css"
    SWAYOSD_SOURCE="$MATUGEN_GEN/swayosd-colors.css"
    KITTY_SOURCE="$MATUGEN_GEN/kitty-colors.conf"
    TMUX_SOURCE="$MATUGEN_GEN/tmux-colors.conf"

    echo "catppuccin-dynamic" >"$NVIM_THEME_NAME_FILE"
else

    SEARCH_DIR="$WALLPAPER_BASE/$SELECTED_THEME"
    WALLPAPER=$(find "$SEARCH_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)
    swww img "$WALLPAPER" --transition-type any --transition-duration 1.5 --transition-fps 90

    rm -f "$GTK3_CONF" "$GTK4_CONF"
    [ -f "$CURRENT_CONFIG_PATH/gtk-3.css" ] && cp "$CURRENT_CONFIG_PATH/gtk-3.css" "$GTK3_CONF"
    [ -f "$CURRENT_CONFIG_PATH/gtk-4.css" ] && cp "$CURRENT_CONFIG_PATH/gtk-4.css" "$GTK4_CONF"
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"

    HYPR_SOURCE="$CURRENT_CONFIG_PATH/hyprland.conf"
    WAYBAR_SOURCE="$CURRENT_CONFIG_PATH/waybar.css"
    ROFI_SOURCE="$CURRENT_CONFIG_PATH/rofi.rasi"
    SWAYNC_SOURCE="$CURRENT_CONFIG_PATH/swaync.css"
    SWAYOSD_SOURCE="$CURRENT_CONFIG_PATH/swayosd.css"
    KITTY_SOURCE="$CURRENT_CONFIG_PATH/kitty.conf"
    TMUX_SOURCE="$CURRENT_CONFIG_PATH/tmux.conf"

    if [ -f "$CURRENT_CONFIG_PATH/neovim.lua" ]; then
        THEME_NAME_STRING=$(grep 'return' "$CURRENT_CONFIG_PATH/neovim.lua" | cut -d '"' -f 2)
        echo "$THEME_NAME_STRING" >"$NVIM_THEME_NAME_FILE"
    fi
fi

[ -f "$TMUX_SOURCE" ] && cp "$TMUX_SOURCE" "$TMUX_THEME_FILE"

if [ -f "$CURRENT_CONFIG_PATH/vscode.json" ] && [ -f "$VSCODE_SETTINGS" ]; then
    VS_THEME_NAME=$(grep '"name":' "$CURRENT_CONFIG_PATH/vscode.json" | cut -d '"' -f 4 | xargs)
    if [ -n "$VS_THEME_NAME" ]; then
        sed -i "s/\(\"workbench.colorTheme\":\s*\"\)[^\"]*\(\"\)/\1$VS_THEME_NAME\2/" "$VSCODE_SETTINGS"
    fi
fi

echo "source = $HYPR_SOURCE" >"$HYPR_THEME_FILE"
echo "@import \"$WAYBAR_SOURCE\";" >"$WAYBAR_THEME_FILE"
echo "@import \"$ROFI_SOURCE\"" >"$ROFI_THEME_FILE"
echo "@import \"$SWAYNC_SOURCE\";" >"$SWAYNC_THEME_FILE"
echo "@import \"$SWAYOSD_SOURCE\";" >"$SWAYOSD_THEME_FILE"
echo "include $KITTY_SOURCE" >"$KITTY_THEME_FILE"

hyprctl reload >/dev/null
kill -SIGUSR2 $(pidof waybar) 2>/dev/null
swaync-client -R && swaync-client -rs 2>/dev/null
kill -SIGUSR1 $(pidof kitty) 2>/dev/null

if pgrep tmux >/dev/null; then
    tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null
fi

[ -x "$SWAYOSD_RELOAD_SCRIPT" ] && "$SWAYOSD_RELOAD_SCRIPT"

notify-send -i "$WALLPAPER" "Theme Activated" "Applied <b>$SELECTED_THEME</b>"

