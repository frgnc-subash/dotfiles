-- ┌─┐┌┐┌┬  ┬┬┬─┐┌─┐┌┐┌┌┬┐┌─┐┌┐┌┌┬┐  ┬  ┬┌─┐┬─┐┬┌─┐┌┐ ┬  ┌─┐┌─┐
-- ├┤ │││└┐┌┘│├┬┘│ │││││││├┤ │││ │   └┐┌┘├─┤├┬┘│├─┤├┴┐│  ├┤ └─┐
-- └─┘┘└┘ └┘ ┴┴└─└─┘┘└┘┴ ┴└─┘┘└┘ ┴    └┘ ┴ ┴┴└─┴┴ ┴└─┘┴─┘└─┘└─┘

-- NVIDIA
hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "mesa")
hl.env("NVD_BACKEND", "direct")
hl.env("__GL_GSYNC_ALLOWED", "0")
hl.env("__GL_VRR_ALLOWED", "0")
hl.env("__GL_THREADED_OPTIMIZATIONS", "1")

-- Wayland
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- Qt
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
hl.env("QT_ENABLE_HIGHDPI_SCALING", "0")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- General
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("XCURSOR_THEME", "Mocu-Black-Right")
hl.env("TERMINAL", "kitty")
