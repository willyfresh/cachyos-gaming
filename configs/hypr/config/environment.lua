-- require("config.environment")
local shared = require("config.shared")
local tty = shared.tty

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("TERMINAL", tty)