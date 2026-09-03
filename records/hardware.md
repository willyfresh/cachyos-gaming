# Hardware — Borg

Captured 2026-09-02 on the first CachyOS niri install.

| | |
| --- | --- |
| Hostname | Borg |
| Distro | CachyOS (rolling), `linux-cachyos` 7.2.2 |
| Desktop | niri 26.04 + noctalia (`cachyos-niri-noctalia` 1.4.0) |
| CPU | AMD Ryzen 5 5600X (6c/12t) |
| RAM | 32 GiB |
| GPU | NVIDIA GeForce RTX 2060 (TU106), driver 610.57.04 (`nvidia-open`) |

## Displays

Two ASUS VE247 panels, both 1920×1080 @ 60 Hz, scale 1, side by side.

| Connector | Make / serial | Position |
| --- | --- | --- |
| HDMI-A-1 | Ancor Communications Inc VE247 `C5LMQS118094` | 0, 0 (left) |
| DP-1 | Ancor Communications Inc VE247 `K1LMQS100417` | 1920, 0 (right) |

Stock niri `display.kdl` still has a commented example for `DP-1` at 2560×1440@360. That is not this machine. Runtime layout is currently coming from niri itself, not from that file.

## Storage (at install)

| Device | Size | Notes |
| --- | --- | --- |
| nvme0n1 | 954 G | ext4 |
| nvme1n1 | 954 G | ext4 |
| sda | 233 G | btrfs `/var/tmp`, ESP on `sda2` |
| zram0 | 31 G | swap |
