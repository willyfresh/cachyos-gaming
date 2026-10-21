-- require("keybinds.windows-compat")
local shared = require("config.shared")
local bin = shared.bin
local mod = shared.mod

hl.bind(mod .. " + period", hl.dsp.exec_cmd(bin .. "/hypr-emoji.sh"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(shared.filem))
hl.bind(mod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(bin .. "/hypr-session.sh"))

-- Alt+Tab is the Windows switcher. The list is frozen in the order
-- you used the windows, and the window changes when Alt is released.
-- No submap here: a quick tap used to stick one, and the bar printed
-- the name. Super+Tab stays up, so that one is a submap. Arrows and
-- Esc work, and Waybar does not show the name.
local alt_open = false
local alt_cool = 0
local task_ready = false

local function switcher(cmd)
	hl.dispatch(hl.dsp.event("switcher>>" .. cmd))
end

local function alt_held()
	return hl.is_key_down("Alt_L") or hl.is_key_down("Alt_R")
end

hl.timer(function()
	if alt_cool > 0 then
		alt_cool = alt_cool - 1
	end
	if alt_open and not alt_held() then
		alt_open = false
		alt_cool = 3
		switcher("alt-up")
	end
	-- The Super+Tab that opened Task View is still down. Ignore it
	-- until it is released, or the submap would close immediately.
	if not task_ready and hl.get_current_submap() == "taskview" then
		if not (hl.is_key_down("Super_L") or hl.is_key_down("Super_R")) then
			task_ready = true
		end
	end
end, { timeout = 30, type = "repeat" })

local function alt_step(cmd)
	return function()
		if alt_cool > 0 then
			return
		end
		alt_open = true
		switcher(cmd)
	end
end

hl.bind("ALT + TAB", alt_step("alt-next"), { repeating = true })
hl.bind("ALT + SHIFT + TAB", alt_step("alt-prev"), { repeating = true })
hl.bind("ALT + Escape", function()
	if not alt_open then
		return
	end
	alt_open = false
	alt_cool = 3
	switcher("alt-cancel")
end)

local function leave_task(cmd)
	return function()
		task_ready = false
		switcher(cmd)
		hl.dispatch(hl.dsp.submap("reset"))
	end
end

hl.define_submap("taskview", function()
	hl.bind("Escape", leave_task("task-close"))
	hl.bind("Return", leave_task("task-activate"))
	hl.bind("SUPER + TAB", function()
		if not task_ready then
			return
		end
		leave_task("task-close")()
	end)
	hl.bind("TAB", function()
		switcher("task-right")
	end)
	hl.bind("SHIFT + TAB", function()
		switcher("task-left")
	end)
	hl.bind("left", function()
		switcher("task-left")
	end)
	hl.bind("right", function()
		switcher("task-right")
	end)
	hl.bind("up", function()
		switcher("task-up")
	end)
	hl.bind("down", function()
		switcher("task-down")
	end)
end)

hl.bind(mod .. " + TAB", function()
	task_ready = false
	switcher("task-open")
	hl.dispatch(hl.dsp.submap("taskview"))
end)

-- The switcher is a separate process. If it has exited, Alt+Tab and
-- Super+Tab dispatch into nothing. Bring it back.
-- pgrep -f reads every command line, including this shell. The path
-- has to stay off that line or the check matches itself and the
-- process is never started. The empty quotes are what keeps it off.
hl.timer(function()
	os.execute(
		"pgrep -f '[h]ypr-switcher.py' >/dev/null 2>&1 || setsid -f "
			.. bin
			.. "/hypr-switcher''.py >/dev/null 2>&1"
	)
end, { timeout = 5000, type = "repeat" })
