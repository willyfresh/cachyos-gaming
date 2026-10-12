-- Hyprland on Novalis. Dwindle only. The bar is Waybar (configs/waybar).
-- Launcher, lock screen, clipboard, and control center stay on niri.
-- From the tty prompt type: start-hyprland
-- Super+Shift+Q quits back to that prompt.

local mainMod = "SUPER"
local bin = "/home/willyfresh/.local/bin"
local quit = "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Hyprland imports WAYLAND_DISPLAY into the user manager unless
-- HYPRLAND_NO_SD_VARS is set. Do not start hyprland-session.target
-- by hand, and do not start noctalia.

-- Same places as niri. Auto layout puts the HDMI panel on the left.
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
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 0,
    },
    dwindle = {
        preserve_split = true,
    },
    decoration = {
        rounding = 0,
        shadow = {
            enabled = false,
        },
        -- Focus is opacity. A fullscreen window stays solid.
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

hl.on("hyprland.start", function()
    hl.exec_cmd("dropbox start -i")
    hl.exec_cmd("sh -c 'pgrep -x waybar >/dev/null || exec waybar'")
    hl.exec_cmd("python3 /home/willyfresh/Projects/cachyos-gaming/configs/hypr/wallpaper.py")
end)

-- Dialogs that should not become tiles.
hl.window_rule({
    name  = "float-gtk-file-chooser",
    match = { class = "^xdg-desktop-portal-gtk$" },
    float = true,
    center = true,
})
hl.window_rule({
    name  = "float-btop",
    match = { class = "^btop$" },
    float = true,
    center = true,
})

-- Apps. Same scripts as niri. They ask niri which window to focus, miss,
-- and launch a new one while niri is not running.
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("fuzzel"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("alacritty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(quit))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(quit))

hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-boardgamearena.com.*Default' 'https://boardgamearena.com/'"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-calendar.google.com.*Default' 'https://calendar.google.com/'"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(bin .. "/launch-discord.sh"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^(thunderbird|org\.mozilla\.Thunderbird)$' thunderbird]]))
hl.bind(mainMod .. " + SHIFT + ALT + E", hl.dsp.exec_cmd("thunderbird -compose"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-mail.google.com.*Default' 'https://mail.google.com/'"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd(bin .. "/launch-or-focus-app.sh heroic setsid heroic"))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.exec_cmd(bin .. "/launch-or-focus-app.sh inkscape setsid inkscape"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-maps.google.com.*Default' 'https://maps.google.com/'"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-messages.google.com.*Default' 'https://messages.google.com/web/conversations'"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^(libreoffice|soffice)' setsid libreoffice]]))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^gimp' setsid gimp]]))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(bin .. "/launch-steam.sh"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^[Cc]ode$' code]]))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^google-chrome$' setsid google-chrome-stable]]))
hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd(bin .. "/launch-youtube.sh"))
hl.bind(mainMod .. " + CTRL + T", hl.dsp.exec_cmd(bin .. "/launch-btop.sh"))
hl.bind(mainMod .. " + SHIFT + ALT + A", hl.dsp.exec_cmd(bin .. "/launch-grok-bot.sh"))
hl.bind("CTRL + SHIFT + F3", hl.dsp.exec_cmd(bin .. "/launch-grok-bot.sh"))
hl.bind("CTRL + SHIFT + F4", hl.dsp.exec_cmd(bin .. "/launch-steam-heroic.sh"))

-- Dwindle. Super+F keeps the gaps (maximize). Super+Shift+F covers the screen.
-- Super+Up/Down is bound after hyprsplit: focus that way, then the
-- previous or next workspace on this screen.
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + ALT + left",  hl.dsp.focus({ monitor = "left" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ monitor = "right" }))
hl.bind(mainMod .. " + ALT + up",    hl.dsp.focus({ monitor = "up" }))
hl.bind(mainMod .. " + ALT + down",  hl.dsp.focus({ monitor = "down" }))

hl.bind(mainMod .. " + SHIFT + ALT + left",  hl.dsp.window.move({ monitor = "left", follow = true }))
hl.bind(mainMod .. " + SHIFT + ALT + right", hl.dsp.window.move({ monitor = "right", follow = true }))
hl.bind(mainMod .. " + SHIFT + ALT + up",    hl.dsp.window.move({ monitor = "up", follow = true }))
hl.bind(mainMod .. " + SHIFT + ALT + down",  hl.dsp.window.move({ monitor = "down", follow = true }))

hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Super+Shift+V: focus a window of the other kind on this workspace.
hl.bind(mainMod .. " + SHIFT + V", function()
    local active = hl.get_active_window()
    if active == nil or active.workspace == nil then
        return
    end
    local want_float = not active.floating
    for _, other in ipairs(hl.get_windows() or {}) do
        local ws = other.workspace
        if other.address ~= active.address and other.mapped and not other.hidden
            and other.floating == want_float and ws and ws.id == active.workspace.id then
            hl.dispatch(hl.dsp.focus({ window = "address:" .. other.address }))
            return
        end
    end
end)

-- Turn the screens off. The delay lets the key go up first, so the
-- keypress itself does not wake them again. Any later key turns them on.
hl.bind(mainMod .. " + ALT + P", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "disable" }))
    end, { timeout = 500, type = "oneshot" })
end)

-- Same width step as niri: 10% of the screen, not Omarchy's left-edge resize.
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
hl.bind(mainMod .. " + CTRL + ALT + left", resize_by(-1, 0))
hl.bind(mainMod .. " + CTRL + ALT + right", resize_by(1, 0))
hl.bind(mainMod .. " + CTRL + ALT + up", resize_by(0, -1))
hl.bind(mainMod .. " + CTRL + ALT + down", resize_by(0, 1))

-- Alt stays held in the normal keymap. No submap, so the bar never
-- labels the mode, and a quick tap cannot leave the keys stuck.
local function cycle_window(prev)
    return function()
        if prev then
            hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
        else
            hl.dispatch(hl.dsp.window.cycle_next())
        end
        hl.dispatch(hl.dsp.window.bring_to_top())
    end
end

hl.bind("ALT + TAB", cycle_window(false))
hl.bind("ALT + SHIFT + TAB", cycle_window(true))

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

-- Super+Ctrl+arrows always change workspace, the way niri does.
-- Left and Up are the previous occupied desk. Right and Down are the next.
local function focus_workspace_rel(sel)
    return function()
        hs.dsp.focus({ workspace = sel })()
    end
end

local function move_to_workspace_rel(sel)
    return function()
        hs.dsp.window.move({ workspace = sel, follow = true })()
    end
end

hl.bind(mainMod .. " + CTRL + left", focus_workspace_rel("e-1"))
hl.bind(mainMod .. " + CTRL + right", focus_workspace_rel("e+1"))
hl.bind(mainMod .. " + CTRL + up", focus_workspace_rel("e-1"))
hl.bind(mainMod .. " + CTRL + down", focus_workspace_rel("e+1"))
hl.bind(mainMod .. " + SHIFT + CTRL + left", move_to_workspace_rel("e-1"))
hl.bind(mainMod .. " + SHIFT + CTRL + right", move_to_workspace_rel("e+1"))
hl.bind(mainMod .. " + SHIFT + CTRL + up", move_to_workspace_rel("e-1"))
hl.bind(mainMod .. " + SHIFT + CTRL + down", move_to_workspace_rel("e+1"))
