-- require("keybinds.apps")
local shared = require("config.shared")
local bin = shared.bin
local mod = shared.mod
local modshi = shared.modshi
local tty = shared.tty

hl.bind(mod .. " + Space", hl.dsp.exec_cmd("fuzzel"))
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(tty))

hl.bind(modshi .. " + A", hl.dsp.exec_cmd(bin .. [[/launch-app.sh --match both 'grok[- ]?bot' setsid grok-bot]]))
hl.bind(modshi .. " + CTRL + A", hl.dsp.exec_cmd(bin .. [[/launch-app.sh '^grok-cli$' setsid kitty --class grok-cli --title grok -e /home/willyfresh/.grok/bin/grok]]))

hl.bind(modshi .. " + B", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-boardgamearena.com.*Default' 'https://boardgamearena.com/play']]))

hl.bind(modshi .. " + C", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-calendar.google.com.*Default' 'https://calendar.google.com/']]))

hl.bind(modshi .. " + D", hl.dsp.exec_cmd(bin .. [[/launch-app.sh --skip-title updater '^discord$' setsid discord]]))
hl.bind(modshi .. " + CTRL + D", hl.dsp.exec_cmd(bin .. [[/launch-app.sh '^concord$' setsid kitty --class concord --title concord -e concord]]))

hl.bind(modshi .. " + E", hl.dsp.exec_cmd(bin .. [[/launch-app.sh '^(thunderbird|org\.mozilla\.Thunderbird)$' thunderbird]]))
hl.bind(modshi .. " + CTRL + E", hl.dsp.exec_cmd("thunderbird -compose"))

hl.bind(modshi .. " + F", hl.dsp.exec_cmd("setsid kitty --class yazi --title yazi -e yazi"))
hl.bind(modshi .. " + CTRL + F", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-drive.google.com.*Default' 'https://drive.google.com/']]))

hl.bind(modshi .. " + G", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-mail.google.com.*Default' 'https://mail.google.com/']]))

hl.bind(modshi .. " + H", hl.dsp.exec_cmd(bin .. "/launch-app.sh heroic setsid heroic"))

hl.bind(modshi .. " + I", hl.dsp.exec_cmd(bin .. "/launch-app.sh inkscape setsid inkscape"))

hl.bind(modshi .. " + K", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-keep.google.com.*Default' 'https://keep.google.com/']]))

hl.bind(modshi .. " + L", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-maps.google.com.*Default' 'https://maps.google.com/']]))

hl.bind(modshi .. " + M", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-messages.google.com.*Default' 'https://messages.google.com/web/conversations']]))

hl.bind(modshi .. " + N", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-feedly.com.*Default' 'https://feedly.com/i/my']]))

hl.bind(modshi .. " + O", hl.dsp.exec_cmd(bin .. [[/launch-app.sh '^(libreoffice|soffice)' setsid libreoffice]]))
hl.bind(modshi .. " + CTRL + O", hl.dsp.exec_cmd(bin .. "/launch-app.sh obsidian setsid obsidian"))

hl.bind(modshi .. " + P", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-photos.google.com.*Default' 'https://photos.google.com/']]))
hl.bind(modshi .. " + CTRL + P", hl.dsp.exec_cmd(bin .. [[/launch-app.sh '^gimp' setsid gimp]]))

hl.bind(modshi .. " + S", hl.dsp.exec_cmd(bin .. [[/launch-app.sh --match both --skip-title notificationtoast '^steam(?!\w)' setsid steam]]))

hl.bind(modshi .. " + T", hl.dsp.exec_cmd(bin .. [[/launch-app.sh --toggle '^(btop|btop-key)$' setsid kitty --class btop-key --title btop -e btop]]))
hl.bind(modshi .. " + CTRL + T", hl.dsp.exec_cmd(bin .. [[/launch-app.sh --toggle '^(nvtop|nvtop-key)$' setsid kitty --class nvtop-key --title nvtop -e nvtop]]))

hl.bind(modshi .. " + V", hl.dsp.exec_cmd(bin .. [[/launch-app.sh '^nvim$' setsid kitty --class nvim --title nvim -e nvim]]))
hl.bind(modshi .. " + CTRL + V", hl.dsp.exec_cmd(bin .. [[/launch-app.sh '^[Cc]ode$' code]]))

hl.bind(modshi .. " + W", hl.dsp.exec_cmd(bin .. [[/launch-app.sh '^google-chrome$' setsid google-chrome-stable]]))
hl.bind(modshi .. " + CTRL + W", hl.dsp.exec_cmd(bin .. [[/launch-app.sh '^lynx$' setsid kitty --class lynx --title lynx -e lynx]]))

hl.bind(modshi .. " + Y", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-music\.youtube\.com' 'https://music.youtube.com/']]))
hl.bind(modshi .. " + CTRL + Y", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-(www\.)?youtube\.com' 'https://www.youtube.com/']]))

hl.bind(modshi .. " + period", hl.dsp.exec_cmd(bin .. [[/launch-webapp.sh --focus 'chrome-tasks.google.com.*Default' 'https://tasks.google.com/']]))
