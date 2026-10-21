-- Hyprland resolves require() from the directory of ~/.config/hypr/hyprland.lua.
-- That path is a symlink, so the lookup stays in ~/.config/hypr and misses
-- the modules beside the real file. Search the repo copy first.
local hypr_dir = "/home/willyfresh/Projects/cachyos-gaming/configs/hypr"
package.path = hypr_dir .. "/?.lua;" .. hypr_dir .. "/?/init.lua;" .. package.path

require("config.environment")
require("config.monitors")
require("config.layouts")
require("config.appearance")
require("config.animation")
require("config.autostart")
require("config.rules")

require("keybinds.keychron")
require("keybinds.windows-compat")
require("keybinds.apps")
require("keybinds.utilities")
require("keybinds.session")
require("keybinds.window-management")
require("keybinds.workspaces")
