-- Hyprland imports WAYLAND_DISPLAY into the user manager unless
-- HYPRLAND_NO_SD_VARS is set. Do not start hyprland-session.target
-- by hand. Noctalia is not part of this session.

-- Auto layout puts the HDMI panel on the left, so the serial pin stays.
-- Left: DP-1, serial K1LMQS100417. Right: HDMI-A-1, serial C5LMQS118094.
hl.monitor({
	output = "desc:Ancor Communications Inc VE247 K1LMQS100417",
	mode = "preferred",
	position = "0x0",
	scale = 1,
})
hl.monitor({
	output = "desc:Ancor Communications Inc VE247 C5LMQS118094",
	mode = "preferred",
	position = "1920x0",
	scale = 1,
})
