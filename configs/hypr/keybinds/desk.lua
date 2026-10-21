-- require("keybinds.desk")
-- Super+Ctrl+Left/Right steps every screen one workspace number.
-- Super+D opens the next empty number on the focused screen.
-- This file only reads hyprsplit. Calling monitor_priority again would
-- append to the list and renumber the right screen.
local hypr_dir = "/home/willyfresh/Projects/cachyos-gaming/configs/hypr"
package.path = hypr_dir .. "/?.lua;" .. hypr_dir .. "/?/init.lua;" .. package.path

local shared = require("config.shared")
local hs = require("hyprsplit")
local mod = shared.mod

local function range_for(monitor)
	local num = hs.get_config("num_workspaces") or 10
	local base = -1
	for i, selector in ipairs(hs.monitor_priority_list or {}) do
		if monitor.name == selector or monitor.description == selector then
			base = i - 1
		end
	end
	if base < 0 then
		return nil
	end
	local min = base * num + 1
	return { min = min, max = min + num - 1, num = num }
end

local function window_count(id)
	local ws = hl.get_workspace(id)
	if ws == nil then
		return 0
	end
	if type(ws.windows) == "number" then
		return ws.windows
	end
	local ok, listed = pcall(hl.get_workspace_windows, id)
	if ok and type(listed) == "table" then
		return #listed
	end
	-- Unknown occupancy. Treat it as taken so Super+D does not land on it.
	return 1
end

local function next_empty()
	local monitor = hl.get_active_monitor()
	if monitor == nil or monitor.active_workspace == nil or monitor.active_workspace.special then
		return
	end
	local range = range_for(monitor)
	if range == nil then
		return
	end
	local current = monitor.active_workspace.id
	if current < range.min or current > range.max then
		return
	end
	for step = 1, range.num do
		local id = range.min + ((current - range.min + step) % range.num)
		if id ~= current and window_count(id) == 0 then
			hl.dispatch(hl.dsp.focus({ workspace = id, on_current_monitor = true }))
			return
		end
	end
end

-- One local number on every screen, including an empty one. Stop at 1
-- and at 10. The mouse stays put while the screens move.
local function shift_all(delta)
	return function()
		local orig = hl.get_active_monitor()
		local have_warp, saved = pcall(hl.get_config, "cursor.no_warps")
		if have_warp then
			hl.config({ cursor = { no_warps = true } })
		end
		local ok, err = pcall(function()
			for _, monitor in ipairs(hl.get_monitors() or {}) do
				if monitor ~= nil and not monitor.is_mirror and monitor.id ~= -1 then
					local active = monitor.active_workspace
					if active and not active.special then
						local range = range_for(monitor)
						if range and active.id >= range.min and active.id <= range.max then
							local local_n = active.id - range.min + 1
							local next_local = math.max(1, math.min(range.num, local_n + delta))
							if next_local ~= local_n then
								hl.dispatch(hl.dsp.focus({ monitor = monitor }))
								hl.dispatch(hl.dsp.focus({
									workspace = range.min + next_local - 1,
									on_current_monitor = true,
								}))
							end
						end
					end
				end
			end
			if orig then
				hl.dispatch(hl.dsp.focus({ monitor = orig }))
			end
		end)
		if have_warp then
			hl.config({ cursor = { no_warps = saved } })
		end
		if not ok then
			error(err)
		end
	end
end

hl.bind(mod .. " + CTRL + left", shift_all(-1))
hl.bind(mod .. " + CTRL + right", shift_all(1))
hl.bind(mod .. " + D", next_empty)

return {
	next_empty = next_empty,
	shift_all = shift_all,
}
