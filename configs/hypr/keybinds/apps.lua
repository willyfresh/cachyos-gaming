-- require("keybinds.apps")
local shared = require("config.shared")
local bin = shared.bin
local modshi = shared.modshi


hl.bind(modshi .. " + K", hl.dsp.exec_cmd("kitty"))
hl.bind(modshi .. " + A", hl.dsp.exec_cmd(bin .. "/launch-grok-bot.sh"))
hl.bind(
	modshi .. " + CTRL + A",
	hl.dsp.exec_cmd(
		bin
			.. [[/launch-or-focus-app.sh '^grok-cli$' setsid kitty --class grok-cli --title grok -e /home/willyfresh/.grok/bin/grok]]
	)
)
hl.bind(
	modshi .. " + B",
	hl.dsp.exec_cmd(
		bin .. "/launch-or-focus-webapp.sh 'chrome-boardgamearena.com.*Default' 'https://boardgamearena.com/'"
	)
)
hl.bind(
	modshi .. " + C",
	hl.dsp.exec_cmd(
		bin .. "/launch-or-focus-webapp.sh 'chrome-calendar.google.com.*Default' 'https://calendar.google.com/'"
	)
)
hl.bind(modshi .. " + D", hl.dsp.exec_cmd(bin .. "/launch-discord.sh"))
hl.bind(
	modshi .. " + CTRL + D",
	hl.dsp.exec_cmd(
		bin .. [[/launch-or-focus-app.sh '^concord$' setsid kitty --class concord --title concord -e concord]]
	)
)
hl.bind(
	modshi .. " + E",
	hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^(thunderbird|org\.mozilla\.Thunderbird)$' thunderbird]])
)
hl.bind(modshi .. " + CTRL + E", hl.dsp.exec_cmd("thunderbird -compose"))
hl.bind(
	modshi .. " + F",
	hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^yazi$' setsid kitty --class yazi --title yazi -e yazi]])
)
hl.bind(
	modshi .. " + G",
	hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-mail.google.com.*Default' 'https://mail.google.com/'")
)
hl.bind(modshi .. " + H", hl.dsp.exec_cmd(bin .. "/launch-or-focus-app.sh heroic setsid heroic"))
hl.bind(modshi .. " + I", hl.dsp.exec_cmd(bin .. "/launch-or-focus-app.sh inkscape setsid inkscape"))
hl.bind(
	modshi .. " + L",
	hl.dsp.exec_cmd(bin .. "/launch-or-focus-webapp.sh 'chrome-maps.google.com.*Default' 'https://maps.google.com/'")
)
hl.bind(
	modshi .. " + M",
	hl.dsp.exec_cmd(
		bin
			.. "/launch-or-focus-webapp.sh 'chrome-messages.google.com.*Default' 'https://messages.google.com/web/conversations'"
	)
)
hl.bind(
	modshi .. " + O",
	hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^(libreoffice|soffice)' setsid libreoffice]])
)
hl.bind(modshi .. " + CTRL + O", hl.dsp.exec_cmd(bin .. "/launch-or-focus-app.sh obsidian setsid obsidian"))
hl.bind(modshi .. " + P", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^gimp' setsid gimp]]))
hl.bind(modshi .. " + S", hl.dsp.exec_cmd(bin .. "/launch-steam.sh"))
hl.bind(modshi .. " + T", hl.dsp.exec_cmd(bin .. "/launch-btop.sh"))
hl.bind(modshi .. " + CTRL + T", hl.dsp.exec_cmd(bin .. "/launch-btop.sh nvtop"))
hl.bind(
	modshi .. " + V",
	hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^nvim$' setsid kitty --class nvim --title nvim -e nvim]])
)
hl.bind(modshi .. " + CTRL + V", hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^[Cc]ode$' code]]))
hl.bind(
	modshi .. " + W",
	hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^google-chrome$' setsid google-chrome-stable]])
)
hl.bind(
	modshi .. " + CTRL + W",
	hl.dsp.exec_cmd(bin .. [[/launch-or-focus-app.sh '^lynx$' setsid kitty --class lynx --title lynx -e lynx]])
)
hl.bind(modshi .. " + Y", hl.dsp.exec_cmd(bin .. "/launch-youtube.sh music"))
hl.bind(modshi .. " + CTRL + Y", hl.dsp.exec_cmd(bin .. "/launch-youtube.sh youtube"))