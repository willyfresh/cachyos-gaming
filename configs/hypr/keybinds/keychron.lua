-- require("keybinds.keychron")
local shared = require("config.shared")
local bin = shared.bin

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

-- Triangle opens the update list. Square opens devices.
-- Circle is Super+N, bound with the other utilities. Light and X stay open.
hl.bind("CTRL + SHIFT + F3", hl.dsp.exec_cmd(bin .. "/waybar-updates.py detail"))
hl.bind("CTRL + SHIFT + F4", hl.dsp.exec_cmd(bin .. "/waybar-devices.py"))
hl.bind("CTRL + SHIFT + F5", hl.dsp.exec_cmd(bin .. "/hypr-session.sh"))
