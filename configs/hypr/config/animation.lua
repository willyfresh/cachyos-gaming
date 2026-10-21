-- require( "config.animation" )

-- Speed is tenths of a second. A window opens from a horizontal line
-- through its middle and closes back to that line. Its opacity finishes
-- in 100ms, so the shade is already solid while it is still opening.
-- A workspace change slides the full screen height and is solid the
-- whole way. Tile moves stay a plain move, so they do not squash.
-- The dim when a window loses focus is a separate fade and stays slow.
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "default", style = "gnomed" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default", style = "gnomed" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "default", style = "slidevert" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 3, bezier = "default", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 3, bezier = "default", style = "slidevert" })
