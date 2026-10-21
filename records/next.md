# Next

Scratch notes from `os-notes.txt` land here after triage. This page is
the backlog. Finished items leave. The inbox is emptied after triage.

Tabled items stay on the list and are not up next. Start one item, or
two, when you pick them.

| Want | Status |
|------|--------|
| Stow layout | tabled |
| Mango | tabled |
| Keychron light key | tabled |
| Halo Xbox login, For Honor | tabled |

## Update list

A row ends in `reboot *` when that package is unused until the next
boot. The list can update the other pending packages without those.
A row ends in `restart *` when a running service has one of that
package's libraries loaded. After the upgrade, the terminal asks
before a reboot or a service restart. Enter means yes. A reboot is
refused when the Limine menu names a missing or mismatched file.
The menu is only as tall as its rows, and it stops growing at 40.

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
