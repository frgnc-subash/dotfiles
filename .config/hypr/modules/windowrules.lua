-- ┬ ┬┬┌┐┌┌┬┐┌─┐┬ ┬  ┬─┐┬ ┬┬  ┌─┐┌─┐
-- │││││││ │││ ││││  ├┬┘│ ││  ├┤ └─┐
-- └┴┘┴┘└┘─┴┘└─┘└┴┘  ┴└─└─┘┴─┘└─┘└─┘

-- -------------------
-- Windows and Rules
-- -------------------

hl.window_rule({
	name = "browser-ws3",
	workspace = "3",
})

hl.window_rule({
	name = "audio-tui-float",
	match = {
		class = "^(audio-tui)$",
	},
	float = true,
	size = "800 500",
	center = true,
})

hl.window_rule({
	name = "suppress-maximize",
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "border-google",
	match = {
		title = ".*Google.*",
	},
	border_color = tertiary,
})

hl.window_rule({
	name = "border-frgnc",
	match = {
		title = ".*frgnc-subash.*",
	},
	border_color = tertiary,
})

hl.window_rule({
	name = "errands-float",
	match = {
		title = "^(Errands)$",
	},
	float = true,
	size = "500 550",
	center = true,
})

hl.window_rule({
	name = "calendar-float",
	match = {
		class = "^(org.gnome.Calender)$",
	},
	float = true,
	size = "300 500",
	center = true,
})

-- -------------------
-- Layer Rules
-- -------------------

hl.layer_rule({
	name = "waybar-no-blur",
	match = {
		namespace = "waybar",
	},
	blur = false,
})

hl.layer_rule({
	name = "rofi-no-blur",
	match = {
		namespace = "rofi",
	},
	blur = false,
})

hl.layer_rule({
	name = "logout-blur",
	match = {
		namespace = "logout_dialog",
	},
	blur = true,
})

hl.layer_rule({
	name = "swaync-cc-blur",
	match = {
		namespace = "swaync-control-center",
	},
	blur = true,
	ignore_alpha = 0.5,
})

hl.layer_rule({
	name = "swaync-notif-blur",
	match = {
		namespace = "swaync-notification-window",
	},
	blur = true,
	ignore_alpha = 0.5,
})

-- hl.layer_rule({
-- 	name = "swaync-notification-animation",
-- 	match = { namespace = "swaync-control-center" },
-- 	animation = "slide top",
-- })
