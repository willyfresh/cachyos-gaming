# Next

Scratch notes from `os-notes.txt` land here after triage. This page is
the backlog. Finished items leave. The inbox is emptied after triage.

Tabled items stay on the list and are not up next. Start one item, or
two, when you pick them.

| Want | Status |
|------|--------|
| Mic dictation | backlog |
| Super+Shift+scroll moves the window | backlog |
| Library updates that need a service restart | backlog |
| Emoji menu should not fuzzy-search | backlog |
| Stow layout | tabled |
| Mango | tabled |
| Keychron light key | tabled |
| Halo Xbox login, For Honor | tabled |

## Mic dictation

Super+Mic starts dictation and stops it. That is the only control.
The mic key by itself still toggles mute.

## Emoji menu

Super+. still fuzzy-filters the list as you type. It should not.
`--no-sort` only keeps the list order.

## Super+Shift+scroll

Super+scroll changes workspace on this screen. Super+Shift+scroll
should move the window.

## Update list

A row ends in `reboot *` when that package is unused until the next
boot. The list can update the other pending packages without those.
Restarting a service after a library update is still unmarked.

## Stow layout

Tabled. `./setup.sh` installs the package lists. `scripts/apply-configs.sh`
symlinks the live files. `hyprland.lua` is linked as one file so
Hyprland's runtime files stay out of the repo. Scripts go to
`~/.local/bin`. Desktop entries go to `~/.local/share/applications`.
`scripts/apply-system.sh` copies keyd, udev, and the Limine hook into
`/etc`. GNU Stow is not installed. A Stow tree would replace those two
scripts. The current links already come back from `./setup.sh`.

## Mango

Tabled. Only if you ask.

## Keychron light key

Tabled. The light key (Ctrl+Shift+F1) opens nothing. These panels have
no backlight.

## Halo Xbox login, For Honor

Tabled. Notes are in `records/gaming.md`.
