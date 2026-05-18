-- ┬┌─┌─┐┬ ┬┌┐ ┬┌┐┌┌┬┐┌─┐
-- ├┴┐├┤ └┬┘├┴┐││││ ││└─┐
-- ┴ ┴└─┘ ┴ └─┘┴┘└┘─┴┘└─┘

local terminal      = "kitty"
local fileManager   = "nautilus"
local menu          = "rofi"
local browser       = "zen-browser"
local secondBrowser = "helium-browser"
local mainMod       = "SUPER"

-- -------------------
-- Basics
-- -------------------
hl.bind(mainMod .. " + RETURN",   hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",        hl.dsp.window.close())
hl.bind(mainMod .. " + E",        hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",        hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE",    hl.dsp.exec_cmd(menu .. " -show drun"))
hl.bind(mainMod .. " + P",        hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J",        hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + C",        hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + L",        hl.dsp.exec_cmd("~/.config/rofi/utilities/powermenu.sh"))
hl.bind(mainMod .. " + D",        hl.dsp.exec_cmd("vesktop"))
hl.bind(mainMod .. " + O",        hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + N",        hl.dsp.exec_cmd("kitty -e nvim"))
hl.bind(mainMod .. " + Y",        hl.dsp.exec_cmd("kitty -e yazi"))
hl.bind(mainMod .. " + M",        hl.dsp.exec_cmd("spotify"))
hl.bind(mainMod .. " + F",        hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + X",        hl.dsp.exec_cmd("~/Desktop/funtools/skedaddle.x86_64"))
hl.bind(mainMod .. " + K",        hl.dsp.exec_cmd("kitty -e kew"))
hl.bind(mainMod .. " + Z",        hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + B",        hl.dsp.exec_cmd(secondBrowser))
hl.bind("ALT + B",                hl.dsp.exec_cmd("kitty -e btop"))

hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("~/.config/rofi/utilities/clipboard.sh"))
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd("~/.config/rofi/utilities/theme-switcher.sh"))
hl.bind("ALT + C",                 hl.dsp.exec_cmd("~/.config/rofi/utilities/calculator.sh"))
hl.bind("ALT + S",                 hl.dsp.exec_cmd("~/.config/rofi/utilities/hyprshader.sh"))
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd("~/.config/hypr/scripts/reload.sh"))
hl.bind("ALT + V",                 hl.dsp.exec_cmd("$HOME/.config/wayclick/wayclick.sh"))

hl.bind("ALT + A",  hl.dsp.exec_cmd("~/.config/hypr/sliders/brightness_slider.sh"))
hl.bind("ALT + Z",  hl.dsp.exec_cmd("~/.config/hypr/sliders/hyprsunset_slider.sh"))
hl.bind("ALT + W",  hl.dsp.exec_cmd("~/.config/rofi/utilities/noti-bar.sh"))
hl.bind("ALT + D",  hl.dsp.exec_cmd("~/.config/hypr/sliders/volume_slider.sh"))
hl.bind("ALT + E",  hl.dsp.exec_cmd("eww open activate-linux"))
hl.bind("ALT + X",  hl.dsp.exec_cmd("eww close activate-linux"))
hl.bind("ALT + N",  hl.dsp.exec_cmd("errands"))

-- -------------------
-- Layout
-- -------------------
hl.bind(mainMod .. " + period",         hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma",          hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("movewindowto r"))
hl.bind(mainMod .. " + SHIFT + comma",  hl.dsp.layout("movewindowto l"))
hl.bind(mainMod .. " + SHIFT + K",      hl.dsp.layout("movewindowto u"))
hl.bind(mainMod .. " + SHIFT + J",      hl.dsp.layout("movewindowto d"))

-- -------------------
-- Wallpaper
-- -------------------
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/rofi/utilities/wallpaper-selector.sh gui"))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("~/.config/rofi/utilities/wallpaper-selector.sh cycle"))

-- -------------------
-- OSDs
-- -------------------
hl.bind("F7",  hl.dsp.exec_cmd("swayosd-client --output-volume -5"), { locked = true })
hl.bind("F8",  hl.dsp.exec_cmd("swayosd-client --output-volume +5"), { locked = true })
hl.bind("F9",  hl.dsp.exec_cmd("swayosd-client --brightness -5"),    { locked = true })
hl.bind("F10", hl.dsp.exec_cmd("swayosd-client --brightness +5"),    { locked = true })

-- -------------------
-- Screenshots
-- -------------------
hl.bind("Print",                    hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh rc"), { locked = true })
hl.bind(mainMod .. " + Print",      hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh rf"), { locked = true })
hl.bind("CTRL + Print",             hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh ri"), { locked = true })
hl.bind("SHIFT + Print",            hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh sc"), { locked = true })
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh sf"), { locked = true })
hl.bind("CTRL + SHIFT + Print",     hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh si"), { locked = true })
hl.bind("ALT + Print",              hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh p"),  { locked = true })

-- -------------------
-- Focus Navigation
-- -------------------
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- -------------------
-- Workspaces
-- -------------------
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,          hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,  hl.dsp.window.move({ workspace = i }))
end

-- -------------------
-- Special Workspaces
-- -------------------
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- -------------------
-- Workspace Scrolling
-- -------------------
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + TAB",        hl.dsp.focus({ workspace = "previous" }))

-- -------------------
-- Mouse Bindings
-- -------------------
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- -------------------
-- Audio & Brightness
-- -------------------
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness +5"),                 { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness -5"),                 { locked = true, repeating = true })

-- -------------------
-- Media Controls
-- -------------------
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

-- -------------------
-- Window Controls
-- -------------------
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.window.move({ workspace = "special:minimized" }))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mainMod .. " + A",         hl.dsp.workspace.toggle_special("minimized"))
hl.bind(mainMod .. " + minus",     hl.dsp.window.move({ workspace = "special" }))
hl.bind(mainMod .. " + equal",     hl.dsp.workspace.toggle_special())

hl.bind("XF86KbdLightOnOff", hl.dsp.exec_cmd("brightnessctl -s rgb:kbd_backlight set 0"))
hl.bind("XF86KbdLightOnOff", hl.dsp.exec_cmd("brightnessctl -s rgb:kbd_backlight set 1"))