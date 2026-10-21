-- require("keybinds.window-management")
local shared = require("config.shared")
local mod = shared.mod
local modshi = shared.modshi

-- Dwindle. Super+F keeps the gaps (maximize). Super+Ctrl+F2 covers
-- the screen. Super+Up/Down and Super+Shift+Up/Down are bound in
-- keybinds.workspaces. At the edge, Up/Down go to an occupied workspace.
-- Shift+Up/Down carry the window onto the neighboring number,
-- including an empty one.
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))

hl.bind(modshi .. " + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(modshi .. " + right", hl.dsp.window.move({ direction = "right" }))

hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + CTRL + F2", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- 10% of the screen, not Omarchy's left-edge resize.
local function resize_by(x_sign, y_sign)
	return function()
		local mon = hl.get_active_monitor()
		if mon == nil then
			return
		end
		hl.dispatch(hl.dsp.window.resize({
			x = math.floor(mon.width * 0.10) * x_sign,
			y = math.floor(mon.height * 0.10) * y_sign,
			relative = true,
		}))
	end
end

hl.bind(mod .. " + minus", resize_by(-1, 0))
hl.bind(mod .. " + equal", resize_by(1, 0))
hl.bind(modshi .. " + minus", resize_by(0, -1))
hl.bind(modshi .. " + equal", resize_by(0, 1))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
