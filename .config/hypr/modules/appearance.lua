-- ┌─┐┌─┐┌─┐┌─┐┌─┐┬─┐┌─┐┌┐┌┌─┐┌─┐
-- ├─┤├─┘├─┘├┤ ├─┤├┬┘├─┤││││  ├┤
-- ┴ ┴┴  ┴  └─┘┴ ┴┴└─┴ ┴┘└┘└─┘└─┘

dofile(os.getenv("HOME") .. "/.config/matugen/generated/hypr-colors.lua")
dofile(os.getenv("HOME") .. "/.config/hypr/theme.lua")

hl.config({
	-- -------------------
	-- General Settings
	-- -------------------
	general = {
		gaps_in = 1,
		gaps_out = 4,
		border_size = 1,
		["col.active_border"] = outline,
		["col.inactive_border"] = outline_variant,
		resize_on_border = true,
		allow_tearing = false,
	},

	-- -------------------
	-- Window Decoration
	-- -------------------
	decoration = {
		rounding = 4,
		rounding_power = 4,
		active_opacity = 0.95,
		inactive_opacity = 0.80,

		shadow = {
			enabled = false,
			range = 2,
			render_power = 2,
			color = primary,
		},

		blur = {
			enabled = false,
			size = 4,
			passes = 2,
			new_optimizations = true,
			ignore_opacity = true,
			noise = 0.05,
			brightness = 1,
			contrast = 1,
		},
	},

	-- -------------------
	-- Master Layout
	-- -------------------
	master = {
		new_status = "master",
	},

	-- -------------------
	-- Miscellaneous
	-- -------------------
	misc = {
		force_default_wallpaper = 1,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		-- vfr = false,
		enable_swallow = true,
	},

	ecosystem = {
		no_update_news = true,
	},

	-- plugin = {
	--     hyprscrolling = {
	--         column_width             = 0.7,
	--         fullscreen_on_one_column = true,
	--         follow_focus             = true,
	--     },
	-- },
})
