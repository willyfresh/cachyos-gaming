hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 4,
		-- 2px stays on every window so focus does not resize them.
		-- Only the focused one is drawn. Unfocused is fully transparent.
		border_size = 2,
		col = {
			active_border = "rgba(5cff6bff)",
			inactive_border = "rgba(00000000)",
		},
	},
	decoration = {
		rounding = 0,
		shadow = {
			enabled = false,
		},
		-- Unfocused windows are also dimmer. A fullscreen window stays solid.
		active_opacity = 1.0,
		inactive_opacity = 0.7,
		fullscreen_opacity = 1.0,
		-- One variant for the whole compositor. It only shows where a window
		-- is transparent: kitty's background, and the VS Code opacity rule.
		-- drops is the rain-on-glass variant.
		blur = {
			enabled = true,
			variant = "drops",
		},
	},
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		force_default_wallpaper = 0,
		background_color = "#0A0D0B",
	},
})