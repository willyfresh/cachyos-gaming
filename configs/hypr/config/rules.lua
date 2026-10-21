-- require( "config.rules" )

-- GTK portal file chooser.
hl.window_rule({
    name = "float-gtk-file-chooser",
    match = { class = "^xdg-desktop-portal-gtk$" },
    float = true,
    center = true,
})

-- Windows explicitly identified as modal dialogs.
hl.window_rule({
    name = "float-modal-dialogs",
    match = { modal = true },
    float = true,
    center = true,
})

-- Other rules: add them for actual behavior you want
-- Useful candidates for your setup are:

-- Utility windows: float audio controls, Bluetooth settings, or network connection editors if you prefer those as small tools.

-- Picture-in-picture: float it and optionally pin it across workspaces.

-- App placement: send selected applications to dedicated workspaces.

-- Opacity exceptions: given your inactive_opacity = 0.7, consider exceptions for video players or other windows you don’t want dimmed.

-- Those are choices, not missing essentials. I wouldn’t paste a giant generic rules collection into your config.

-- Before writing an app-specific rule, open its window and inspect:

-- bash
-- hyprctl clients
-- Use its actual class and title rather than guessing. Also avoid broad title matches such as .*Open.* or .*dialog.*: class/title matching controls which windows receive a rule, and floating is evaluated when the window is created—not when its title changes later.