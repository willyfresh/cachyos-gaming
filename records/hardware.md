# Hardware — Novalis

Captured 2026-09-02 on the first CachyOS niri install.

| | |
| --- | --- |
| Hostname | Novalis (was Borg until 2026-09-07) |
| Distro | CachyOS (rolling), `linux-cachyos` 7.2.2 |
| Desktop | niri 26.04 + noctalia (`cachyos-niri-noctalia` 1.4.0) |
| CPU | AMD Ryzen 5 5600X (6c/12t) |
| RAM | 32 GiB |
| GPU | NVIDIA GeForce RTX 2060 (TU106), driver 610.57.04 (`nvidia-open`) |

## Displays

Two ASUS VE247 panels, both 1920×1080 @ 60 Hz, scale 1, side by side.

| Connector | Make / serial | Position |
| --- | --- | --- |
| DP-1 | Ancor Communications Inc VE247 `K1LMQS100417` | 0, 0 (left) |
| HDMI-A-1 | Ancor Communications Inc VE247 `C5LMQS118094` | 1920, 0 (right) |

Set in `configs/niri/cfg/display.kdl` (matched by serial so it survives cable swaps). The two outputs touch, so the cursor can cross the bezel.

## Storage (at install)

| Device | Size | Notes |
| --- | --- | --- |
| nvme0n1 | 954 G | ext4 |
| nvme1n1 | 954 G | ext4 |
| sda | 233 G | btrfs `/var/tmp`, ESP on `sda2` |
| zram0 | 31 G | swap |
