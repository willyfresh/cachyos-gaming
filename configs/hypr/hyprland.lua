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
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

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
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

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
