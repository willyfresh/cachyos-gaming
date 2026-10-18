# Hardware — Novalis

| | |
| --- | --- |
| Hostname | Novalis (Borg until 2026-09-07). `/etc/hosts` `127.0.1.1` must say Novalis |
| Distro | CachyOS, rolling, NVIDIA open drivers |
| Desktop | Hyprland. niri and Noctalia were removed 2026-10-15 |
| CPU | AMD Ryzen 5 5600X (6c/12t) |
| Board | ASRock B450M-HDV R4.0, BIOS P10.10 |
| RAM | 32 GiB |
| GPU | NVIDIA GeForce RTX 2060 (TU106), `nvidia-open` |
| Ethernet | Realtek RTL8111 on `enp8s0` (r8169). NetworkManager owns it. `nmtui` is the text UI |

## Displays

Two ASUS VE247 panels, both 1920×1080 @ 60 Hz, scale 1, side by side.

| Connector | Make / serial | Position |
| --- | --- | --- |
| DP-1 | Ancor Communications Inc VE247 `K1LMQS100417` | 0, 0 (left) |
| HDMI-A-1 | Ancor Communications Inc VE247 `C5LMQS118094` | 1920, 0 (right) |

Pinned by serial in `configs/hypr/hyprland.lua`, so a cable swap does
not flip the desk. The two outputs touch, so the cursor can cross the
bezel.

## Storage

Captured at install, 2026-09-02.

| Device | Size | Notes |
| --- | --- | --- |
| nvme0n1 | 954 G | ext4 |
| nvme1n1 | 954 G | ext4 |
| sda | 233 G | btrfs `/var/tmp`, ESP on `sda2` |
| zram0 | 31 G | swap |

Root is btrfs subvol `/@`. `/boot` is the FAT partition `/dev/sda2`.

## Boot

Limine. Since limine-entry-tool 1.40 (2026-10-12), a kernel update
writes the initramfs under `/boot/<machine-id>/<kernel>/initramfs` and
puts a BLAKE2b hash on that Limine path. It no longer leaves
`initramfs-linux-cachyos.img`. The OS entry's comment has to be the
literal `machine-id=<id>` or the tool will not update it. A
`default_entry` that names a directory disables autoboot. This box
defaults to the LTS kernel.

On 2026-10-12 the hand-written menu still named the old `.img` files
after the tool had stopped writing them. A live ISO added the hashed
entries that actually boot.

`scripts/check-limine-boot.sh` fails if any `boot():` path is missing
or its hash does not match. Pacman runs it from
`configs/pacman/hooks/99-limine-boot-files.hook` after a kernel, limine,
or mkinitcpio update. `scripts/apply-system.sh` installs both.
