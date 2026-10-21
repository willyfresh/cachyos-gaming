-- require("keybinds.utilities")
local shared = require("config.shared")
local bin = shared.bin
local mod = shared.mod
local modshi = shared.modshi

hl.bind(mod .. " + N", hl.dsp.exec_cmd(bin .. "/hypr-notifications.sh"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd(bin .. "/hypr-clipboard.sh"))
hl.bind(mod .. " + W", hl.dsp.exec_cmd(bin .. "/waybar-weather.py detail"))
hl.bind(mod .. " + K", hl.dsp.exec_cmd(bin .. "/hypr-cheatsheet.sh"))
hl.bind(modshi .. " + Return", hl.dsp.exec_cmd(bin .. "/hypr-wallpaper.sh"))
