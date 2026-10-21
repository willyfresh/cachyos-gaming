-- require("keybinds.workspaces")
local shared = require("config.shared")
local mod = shared.mod
local modshi = shared.modshi

-- Each screen has its own workspaces 1–10.
-- Left (DP-1) is ids 1–10. Right (HDMI-A-1) is ids 11–20.
-- Super+number follows whichever screen is focused.
-- persistent_workspaces stays off, so an empty number is not pinned.
local hypr_dir = "/home/willyfresh/Projects/cachyos-gaming/configs/hypr"
package.path = package.path .. ";" .. hypr_dir .. "/?.lua;" .. hypr_dir .. "/?/init.lua"
local hs = require("hyprsplit")
hs.config({
	num_workspaces = 10,
	persistent_workspaces = false,
})
hs.monitor_priority({ "DP-1", "HDMI-A-1" })

for i = 1, 10 do
	local key = i % 10
	hl.bind(mod .. " + " .. key, hs.dsp.focus({ workspace = i }))
	hl.bind(modshi .. " + " .. key, hs.dsp.window.move({ workspace = i, follow = true }))
end

hl.bind(modshi .. " + TAB", hs.dsp.focus({ workspace = "e-1" }))

-- Super+scroll changes workspace on this screen. Wheel down is the
-- next occupied workspace. Wheel up is the previous one. Empty
-- numbers are skipped. The step stops at the first and the last.
hl.bind(mod .. " + mouse_down", hs.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hs.dsp.focus({ workspace = "e-1" }))

-- Super+Shift+scroll moves the window one number on this screen and
-- follows it. The number can be empty. The step stops at 1 and at 10.
hl.bind(modshi .. " + mouse_down", hs.dsp.window.move({ workspace = "+1", follow = true }))
hl.bind(modshi .. " + mouse_up", hs.dsp.window.move({ workspace = "-1", follow = true }))

-- Super+Up/Down moves focus. Hyprland wraps at the edge, so a second
-- window would bounce forever. A window counts as further up or down
-- only when its center is that way. The top window's Up, and the
-- bottom window's Down, go to the previous or next occupied workspace
-- on this screen. Left and right stay on this workspace.
local function window_center(window)
	local at = window.at
	local size = window.size
	local x, y, w, h = 0, 0, 0, 0
	if type(at) == "table" then
		x = at.x or at[1] or 0
		y = at.y or at[2] or 0
	end
	if type(size) == "table" then
		w = size.x or size.w or size[1] or 0
		h = size.y or size.h or size[2] or 0
	end
	return x + w / 2, y + h / 2
end

local function has_window_that_way(active, direction)
	local ws = active.workspace
	if ws == nil or ws.id == nil then
		return false
	end
	local _, ay = window_center(active)
	for _, other in ipairs(hl.get_windows() or {}) do
		if other.address ~= active.address and other.mapped and not other.hidden then
			local other_ws = other.workspace
			if other_ws and other_ws.id == ws.id then
				local _, oy = window_center(other)
				if direction == "up" and oy < ay - 1 then
					return true
				elseif direction == "down" and oy > ay + 1 then
					return true
				end
			end
		end
	end
	return false
end

local function focus_or_workspace(direction, workspace_sel)
	return function()
		local ws = hl.get_active_workspace()
		if ws and ws.special then
			return
		end
		local active = hl.get_active_window()
		if active and has_window_that_way(active, direction) then
			hl.dispatch(hl.dsp.focus({ direction = direction }))
			return
		end
		hs.dsp.focus({ workspace = workspace_sel })()
	end
end

hl.bind(mod .. " + up", focus_or_workspace("up", "e-1"))
hl.bind(mod .. " + down", focus_or_workspace("down", "e+1"))

-- Super+Shift+Up/Down moves the window that way. At the top or bottom
-- window it carries the window one workspace number on this screen.
-- That number can be empty. The step stops at 1 and at 10.
-- "+1" and "-1" are hyprsplit's neighboring numbers. "e+1" would
-- skip any number that has no windows.
local function move_or_workspace(direction, workspace_sel)
	return function()
		local ws = hl.get_active_workspace()
		if ws and ws.special then
			return
		end
		local active = hl.get_active_window()
		if active and has_window_that_way(active, direction) then
			hl.dispatch(hl.dsp.window.move({ direction = direction }))
			return
		end
		hs.dsp.window.move({ workspace = workspace_sel, follow = true })()
	end
end

hl.bind(modshi .. " + up", move_or_workspace("up", "-1"))
hl.bind(modshi .. " + down", move_or_workspace("down", "+1"))

-- Super+Ctrl+Left/Right and Super+D. A separate file, so loading it
-- does not call monitor_priority a second time.
require("keybinds.desk")
