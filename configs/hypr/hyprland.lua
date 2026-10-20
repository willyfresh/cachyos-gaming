-- Hyprland on Novalis. Dwindle only. The bar is Waybar (configs/waybar).
-- From the tty prompt type: start-hyprland
-- Ctrl+Alt+Delete opens the session list. Super+Shift+Q is unbound.

local mainMod = "SUPER"
local bin = "/home/willyfresh/.local/bin"

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("TERMINAL", "kitty")

-- Hyprland imports WAYLAND_DISPLAY into the user manager unless
-- HYPRLAND_NO_SD_VARS is set. Do not start hyprland-session.target
-- by hand. Noctalia is not part of this session.

-- Auto layout puts the HDMI panel on the left, so the serial pin stays.
-- Left: DP-1, serial K1LMQS100417. Right: HDMI-A-1, serial C5LMQS118094.
hl.monitor({
    output   = "desc:Ancor Communications Inc VE247 K1LMQS100417",
    mode     = "preferred",
    position = "0x0",
    scale    = 1,
})
hl.monitor({
    output   = "desc:Ancor Communications Inc VE247 C5LMQS118094",
    mode     = "preferred",
    position = "1920x0",
    scale    = 1,
})

hl.config({
    general = {
        layout      = "dwindle",
        gaps_in     = 2,
        gaps_out    = 4,
        -- 2px stays on every window so focus does not resize them.
        -- Only the focused one is drawn. Unfocused is fully transparent.
        border_size = 2,
        col = {
            active_border   = "rgba(5cff6bff)",
            inactive_border = "rgba(00000000)",
        },
    },
    dwindle = {
        preserve_split = true,
    },
    decoration = {
        rounding = 0,
        shadow = {
            enabled = false,
        },
        -- Unfocused windows are also dimmer. A fullscreen window stays solid.
        active_opacity     = 1.0,
        inactive_opacity   = 0.7,
        fullscreen_opacity = 1.0,
    },
    misc = {
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        background_color        = "#0A0D0B",
    },
})

-- Speed is tenths of a second. A window opens from a horizontal line
-- through its middle and closes back to that line. Its opacity finishes
-- in 100ms, so the shade is already solid while it is still opening.
-- A workspace change slides the full screen height and is solid the
-- whole way. Tile moves stay a plain move, so they do not squash.
-- The dim when a window loses focus is a separate fade and stays slow.
hl.animation({ leaf = "windows",       enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3, bezier = "default", style = "gnomed" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3, bezier = "default", style = "gnomed" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3, bezier = "default", style = "slidevert" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 3, bezier = "default", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 3, bezier = "default", style = "slidevert" })

hl.on("hyprland.start", function()
    hl.exec_cmd("dropbox start -i")
    hl.exec_cmd("sh -c 'pgrep -x waybar >/dev/null || exec waybar'")
    hl.exec_cmd("sh -c 'pgrep -x mako >/dev/null || exec mako'")
    hl.exec_cmd("sh -c 'pgrep -x hypridle >/dev/null || exec hypridle'")
    -- One row per copy. An image wins over the text that came with it.
    hl.exec_cmd("sh -c 'pgrep -a wl-paste | grep -q hypr-clipboard-store || exec wl-paste --watch " .. bin .. "/hypr-clipboard-store.sh'")
    hl.exec_cmd("sh -c 'systemctl --user is-active --quiet hyprpolkitagent || systemctl --user start hyprpolkitagent'")
    -- Inkscape crashes if its private SVG clipboard type is persisted.
    hl.exec_cmd([[sh -c 'pgrep -x wl-clip-persist >/dev/null || exec wl-clip-persist --clipboard regular --all-mime-type-regex "(?i)^(?!image/x-inkscape-svg).+"']])
    hl.exec_cmd("python3 /home/willyfresh/Projects/cachyos-gaming/configs/hypr/wallpaper.py")
    hl.exec_cmd("sh -c 'pgrep -f \"[h]ypr-switcher.py\" >/dev/null || exec " .. bin .. "/hypr-switcher.py'")
end)

-- Dialogs that should not become tiles.
hl.window_rule({
    name  = "float-gtk-file-chooser",
    match = { class = "^xdg-desktop-portal-gtk$" },
    float = true,
    center = true,
})
-- System, Utilities
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("fuzzel"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd(bin .. "/waybar-devices.py"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus --new-window"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(bin .. "/hypr-notifications.sh"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(bin .. "/hypr-clipboard.sh"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(bin .. "/waybar-weather.py detail"))
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(bin .. "/hypr-session.sh"))

-- Apps. An open window is focused. A miss launches a new one.
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(bin .. "/launch-grok-bot.sh"))
hl.bind(mainMod .. " + SHIFT + CTRL + A", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^grok-cli$' setsid kitty --class grok-cli --title grok -e /home/willyfresh/.grok/bin/grok]]))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-boardgamearena.com.*Default' 'https://boardgamearena.com/'"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-calendar.google.com.*Default' 'https://calendar.google.com/'"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(bin .. "/launch-discord.sh"))
hl.bind(mainMod .. " + SHIFT + CTRL + D", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^concord$' setsid kitty --class concord --title concord -e concord]]))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^(thunderbird|org\.mozilla\.Thunderbird)$' thunderbird]]))
hl.bind(mainMod .. " + SHIFT + CTRL + E", hl.dsp.exec_cmd("thunderbird -compose"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^yazi$' setsid kitty --class yazi --title yazi -e yazi]]))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-mail.google.com.*Default' 'https://mail.google.com/'"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd(bin .. "/launch-or-focus-app.sh heroic setsid heroic"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd(bin .. "/launch-or-focus-app.sh inkscape setsid inkscape"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-maps.google.com.*Default' 'https://maps.google.com/'"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-messages.google.com.*Default' 'https://messages.google.com/web/conversations'"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^(libreoffice|soffice)' setsid libreoffice]]))
hl.bind(mainMod .. " + SHIFT + CTRL + O", hl.dsp.exec_cmd(bin .. "/launch-or-focus-app.sh obsidian setsid obsidian"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^gimp' setsid gimp]]))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(bin .. "/launch-steam.sh"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(bin .. "/launch-btop.sh"))
hl.bind(mainMod .. " + SHIFT + CTRL + T", hl.dsp.exec_cmd(bin .. "/launch-btop.sh nvtop"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^nvim$' setsid kitty --class nvim --title nvim -e nvim]]))
hl.bind(mainMod .. " + SHIFT + CTRL + V", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^[Cc]ode$' code]]))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^google-chrome$' setsid google-chrome-stable]]))
hl.bind(mainMod .. " + SHIFT + CTRL + W", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^lynx$' setsid kitty --class lynx --title lynx -e lynx]]))
hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd(bin .. "/launch-youtube.sh music"))
hl.bind(mainMod .. " + SHIFT + CTRL + Y", hl.dsp.exec_cmd(bin .. "/launch-youtube.sh youtube"))


-- Media keys. keyd turns the Keychron knob and Fn+F8 into the Ctrl+Shift
-- chords. These talk to PipeWire and playerctl directly. The screens
-- have no backlight, so brightness stays unbound.
local media = { locked = true }
local media_repeat = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media_repeat)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), media_repeat)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), media)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), media)
hl.bind("CTRL + SHIFT + F6", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), media)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), media)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), media)
hl.bind("CTRL + SHIFT + F8", hl.dsp.exec_cmd("playerctl play-pause"), media)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), media)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), media)

-- The Keychron crop key sends Print. Alone it drags a region.
-- Shift grabs the focused window. Ctrl+Shift grabs both screens.
-- Alt+Print is SysRq and never reached Hyprland, so it is unbound.
hl.bind("Print", hl.dsp.exec_cmd(bin .. "/hypr-screenshot.sh region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(bin .. "/hypr-screenshot.sh window"))
hl.bind("CTRL + SHIFT + Print", hl.dsp.exec_cmd(bin .. "/hypr-screenshot.sh screen"))

hl.bind("CTRL + SHIFT + F4", hl.dsp.exec_cmd(bin .. "/waybar-devices.py"))
hl.bind("CTRL + SHIFT + F5", hl.dsp.exec_cmd(bin .. "/launch-steam-heroic.sh"))
-- Dwindle. Super+F keeps the gaps (maximize). Super+Ctrl+F2 covers
-- the screen. Super+Up/Down and Super+Shift+Up/Down are bound after
-- hyprsplit. At the edge, Up/Down go to an occupied workspace.
-- Shift+Up/Down carry the window onto the neighboring number,
-- including an empty one.
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))

hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + CTRL + F2", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Turn the screens off. The delay lets the key go up first, so the
-- keypress itself does not wake them again. Any later key turns them on.
hl.bind(mainMod .. " + ALT + P", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "disable" }))
    end, { timeout = 500, type = "oneshot" })
end)

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

hl.bind(mainMod .. " + minus", resize_by(-1, 0))
hl.bind(mainMod .. " + equal", resize_by(1, 0))
hl.bind(mainMod .. " + SHIFT + minus", resize_by(0, -1))
hl.bind(mainMod .. " + SHIFT + equal", resize_by(0, 1))

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
    hl.bind("TAB", function() switcher("task-right") end)
    hl.bind("SHIFT + TAB", function() switcher("task-left") end)
    hl.bind("left", function() switcher("task-left") end)
    hl.bind("right", function() switcher("task-right") end)
    hl.bind("up", function() switcher("task-up") end)
    hl.bind("down", function() switcher("task-down") end)
end)

hl.bind(mainMod .. " + TAB", function()
    task_ready = false
    switcher("task-open")
    hl.dispatch(hl.dsp.submap("taskview"))
end)

hl.bind(mainMod .. " + K", hl.dsp.exec_cmd(bin .. "/hypr-cheatsheet.sh"))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(bin .. "/hypr-wallpaper.sh"))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

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
    hl.bind(mainMod .. " + " .. key, hs.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hs.dsp.window.move({ workspace = i, follow = true }))
end

hl.bind(mainMod .. " + SHIFT + TAB", hs.dsp.focus({ workspace = "e-1" }))

-- Super+scroll changes workspace on this screen. Wheel down is the
-- next occupied workspace. Wheel up is the previous one. Empty
-- numbers are skipped. The step stops at the first and the last.
hl.bind(mainMod .. " + mouse_down", hs.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hs.dsp.focus({ workspace = "e-1" }))

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

hl.bind(mainMod .. " + up", focus_or_workspace("up", "e-1"))
hl.bind(mainMod .. " + down", focus_or_workspace("down", "e+1"))

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

hl.bind(mainMod .. " + SHIFT + up", move_or_workspace("up", "-1"))
hl.bind(mainMod .. " + SHIFT + down", move_or_workspace("down", "+1"))
