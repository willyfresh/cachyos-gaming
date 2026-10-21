-- require( "config.autostart" )
local shared = require("config.shared")
local bin = shared.bin

hl.on("hyprland.start", function()
	hl.exec_cmd("dropbox start -i")
	hl.exec_cmd("bitwarden-desktop")
	hl.exec_cmd("sh -c 'pgrep -x waybar >/dev/null || exec waybar'")
	hl.exec_cmd("sh -c 'pgrep -x mako >/dev/null || exec mako'")
	hl.exec_cmd("sh -c 'pgrep -x hypridle >/dev/null || exec hypridle'")
	-- One row per copy. An image wins over the text that came with it.
	hl.exec_cmd(
		"sh -c 'pgrep -a wl-paste | grep -q hypr-clipboard-store || exec wl-paste --watch "
			.. bin
			.. "/hypr-clipboard-store.sh'"
	)
	hl.exec_cmd("sh -c 'systemctl --user is-active --quiet hyprpolkitagent || systemctl --user start hyprpolkitagent'")
	-- graphical-session.target does not start from the tty, so the
	-- enabled unit would stay down. Start it with the session.
	hl.exec_cmd("sh -c 'systemctl --user is-active --quiet hyprwhspr || systemctl --user start hyprwhspr'")
	-- Inkscape crashes if its private SVG clipboard type is persisted.
	hl.exec_cmd(
		[[sh -c 'pgrep -x wl-clip-persist >/dev/null || exec wl-clip-persist --clipboard regular --all-mime-type-regex "(?i)^(?!image/x-inkscape-svg).+"']]
	)
	hl.exec_cmd("python3 /home/willyfresh/Projects/cachyos-gaming/configs/hypr/wallpaper.py")
	-- Empty quotes so this shell's command line does not contain the
	-- script name. pgrep -f would match itself and never start it.
	hl.exec_cmd(
		"pgrep -f '[h]ypr-switcher.py' >/dev/null 2>&1 || setsid -f "
			.. bin
			.. "/hypr-switcher''.py >/dev/null 2>&1"
	)
end)
