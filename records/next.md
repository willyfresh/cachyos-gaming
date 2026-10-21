# Next

Scratch notes from `os-notes.txt` land here after triage. This page is
only open work. Finished items leave. The inbox is emptied after triage.

Pace is backlog only. Start one item, or two, when you pick them.

| Want | Status |
|------|--------|
| Quieter Hyprland animations | current motion is in; shorter is unpicked |
| Stow layout | backlog |
| Mango | later, and only if you ask |
| VLC chord | no key yet |
| Keychron light and X | unbound |
| Mic dictation | backlog |
| Super+Shift+scroll moves the window | backlog |
| Library updates that need a service restart | unmarked on the update list |
| Halo Xbox login, For Honor | tabled in `records/gaming.md` |

## Quieter Hyprland animations

Windows use `gnomed` at speed 3 (300ms). Opacity uses `fadeIn` and
`fadeOut` at speed 1 (100ms). Workspace changes use `slidevert` at
speed 3 and stay solid. Tile moves stay a plain move. Speed is tenths
of a second. Still unpicked: turn the motion off, or drop the speed
toward 1.

## Stow layout

`./setup.sh` installs the package lists. `scripts/apply-configs.sh`
symlinks the live files. `hyprland.lua` is linked as one file so
Hyprland's runtime files stay out of the repo. Scripts go to
`~/.local/bin`. Desktop entries go to `~/.local/share/applications`.
`scripts/apply-system.sh` copies keyd, udev, and the Limine hook into
`/etc`. GNU Stow is not installed. A Stow tree would replace those two
scripts. The current links already come back from `./setup.sh`.

## Keychron light and X

The light key (Ctrl+Shift+F1) and X (Ctrl+Shift+F5) open nothing.
These panels have no backlight.

## Mic dictation

The mic key (F20, Ctrl+Shift+F6) toggles microphone mute. Wanted:
press once to dictate, and any key stops it. Holding Ctrl keeps
dictation on until Ctrl is released.

## Super+Shift+scroll

Super+scroll changes workspace on this screen. Super+Shift+scroll
should move the window.

## Update list

A row ends in `reboot *` when that package is unused until the next
boot. The list can update the other pending packages without those.
Restarting a service after a library update is still unmarked.
