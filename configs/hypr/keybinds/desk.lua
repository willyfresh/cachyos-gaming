-- require("keybinds.desk")
-- Super+Ctrl+Left/Right steps every screen one workspace number.
-- Super+Ctrl+Up/Down does that too, and skips numbers with no windows.
-- Super+Ctrl+number moves every screen to that number. 0 is 10.
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

-- The mouse stays put. Focus returns to the screen that had it.
local function across_screens(visit)
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
						if range then
							visit(monitor, active, range)
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

local function show_on(monitor, workspace)
	hl.dispatch(hl.dsp.focus({ monitor = monitor }))
	hl.dispatch(hl.dsp.focus({
		workspace = workspace,
		on_current_monitor = true,
	}))
end

-- One step on every screen, including an empty number. Stop at 1 and at 10.
local function shift_all(delta)
	return across_screens(function(monitor, active, range)
		if active.id < range.min or active.id > range.max then
			return
		end
		local local_n = active.id - range.min + 1
		local next_local = math.max(1, math.min(range.num, local_n + delta))
		if next_local ~= local_n then
			show_on(monitor, range.min + next_local - 1)
		end
	end)
end

-- Previous or next number that has windows, on every screen. Empty
-- numbers are skipped. The step stops at 1 and at 10.
local function step_occupied(delta)
	local step = delta < 0 and -1 or 1
	return across_screens(function(monitor, active, range)
		if active.id < range.min or active.id > range.max then
			return
		end
		local local_n = active.id - range.min + 1
		local n = local_n + step
		while n >= 1 and n <= range.num do
			if window_count(range.min + n - 1) > 0 then
				show_on(monitor, range.min + n - 1)
				return
			end
			n = n + step
		end
	end)
end

-- The same local number on every screen, including an empty one.
local function focus_all(local_n)
	return across_screens(function(monitor, active, range)
		if local_n < 1 or local_n > range.num then
			return
		end
		local target = range.min + local_n - 1
		if active.id ~= target then
			show_on(monitor, target)
		end
	end)
end

hl.bind(mod .. " + CTRL + left", shift_all(-1))
hl.bind(mod .. " + CTRL + right", shift_all(1))
hl.bind(mod .. " + CTRL + up", step_occupied(-1))
hl.bind(mod .. " + CTRL + down", step_occupied(1))
for i = 1, 10 do
	hl.bind(mod .. " + CTRL + " .. (i % 10), focus_all(i))
end
hl.bind(mod .. " + D", next_empty)

return {
	next_empty = next_empty,
	shift_all = shift_all,
	step_occupied = step_occupied,
	focus_all = focus_all,
}
