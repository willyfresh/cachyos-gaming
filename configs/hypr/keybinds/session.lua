-- require("keybinds.session")
local shared = require("config.shared")
local mod = shared.mod

-- Turn the screens off. The delay lets the key go up first, so the
-- keypress itself does not wake them again. Any later key turns them on.
hl.bind(mod .. " + ALT + P", function()
	hl.timer(function()
		hl.dispatch(hl.dsp.dpms({ action = "disable" }))
	end, { timeout = 500, type = "oneshot" })
end)
