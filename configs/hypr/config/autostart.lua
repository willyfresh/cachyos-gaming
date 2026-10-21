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
	-- Inkscape crashes if its private SVG clipboard type is persisted.
	hl.exec_cmd(
		[[sh -c 'pgrep -x wl-clip-persist >/dev/null || exec wl-clip-persist --clipboard regular --all-mime-type-regex "(?i)^(?!image/x-inkscape-svg).+"']]
	)
	hl.exec_cmd("python3 /home/willyfresh/Projects/cachyos-gaming/configs/hypr/wallpaper.py")
	hl.exec_cmd('sh -c \'pgrep -f "[h]ypr-switcher.py" >/dev/null || exec ' .. bin .. "/hypr-switcher.py'")
end)
