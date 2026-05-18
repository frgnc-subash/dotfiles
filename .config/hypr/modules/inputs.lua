-- ┬┌┐┌┌─┐┬ ┬┌┬┐┌─┐
-- ││││├─┘│ │ │ └─┐
-- ┴┘└┘┴  └─┘ ┴ └─┘

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		repeat_rate = 35,
		repeat_delay = 300,

		follow_mouse = 1,
		sensitivity = 0.5,
		accel_profile = "flat",
		numlock_by_default = false,

		touchpad = {
			natural_scroll = true,
			scroll_factor = 0.7,
		},
	},

	-- -------------------
	-- Cursor
	-- -------------------
	cursor = {
		inactive_timeout = 30,
		no_hardware_cursors = true,
	},

	-- -------------------
	-- Dwindle Layout
	-- -------------------

	dwindle = {
		preserve_split = true, -- You probably want this
	},

	scrolling = {
		fullscreen_on_one_column = true,
	},
	-- -------------------
	-- Master Layout
	-- -------------------
	master = {
		new_status = "master",
	},
})

-- -------------------
-- Gestures
-- -------------------
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- -------------------
-- Device Settings
-- -------------------
hl.device({
	name = "synps/2-synaptics-touchpad",
	enabled = true,
	natural_scroll = true,
})
hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})
