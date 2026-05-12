-- ┌─┐┬ ┬┌┬┐┌─┐┌─┐┌┬┐┌─┐┬─┐┌┬┐
-- ├─┤│ │ │ │ │└─┐ │ ├─┤├┬┘ │ 
-- ┴ ┴└─┘ ┴ └─┘└─┘ ┴ ┴ ┴┴└─ ┴ 

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon &")
    hl.exec_cmd("~/.config/rofi/utilities/wallpaper-selector.sh cycle")
    hl.exec_cmd("nm-applet &")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swaync")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("wl-paste --watch cliphist store &")

    -- hl.exec_cmd("hyprctl setcursor \"Banana-Blue\" 38")
    -- hl.exec_cmd("gsettings set org.gnome.desktop.interface color-theme \"Banana-Blue\"")
    -- hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 38")
end)