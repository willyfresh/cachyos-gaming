# Gaming on Novalis

RTX 2060 with nvidia-open. The CachyOS install already included
`nvidia-utils`, `lib32-nvidia-utils`, and `egl-wayland`.

## Installed

| Package | Why |
| --- | --- |
| `cachyos-gaming-meta` | Proton-CachyOS SLR, umu-launcher, wine-cachyos-opt, winetricks, 32-bit libs |
| `steam` | Steam. The library is on `/mnt/tb1/SteamLibrary` |
| `heroic-games-launcher-bin` | Epic, GOG, and Amazon |
| `mangohud` and `lib32-mangohud` | FPS overlay. Config is `configs/MangoHud/MangoHud.conf` |
| `goverlay` | GUI for MangoHud. It rewrites that file |
| `gamescope` | Nested compositor when a game will not fullscreen |

`ananicy-cpp` is already running. Do not also install Feral GameMode.
Use `game-performance`.

`lsfg-vk` 2.0.0 is a manual install under `~/.local`, not a pacman
package. Profiles are `configs/lsfg-vk/conf.toml`. `DISABLE_LSFGVK=1`
turns the layer off.

## Steam

1. Log in and let the first-run downloads finish.
2. Settings, Compatibility: leave the default on Valve Proton or Proton Experimental.
3. Per game, force **proton-cachyos-slr** for the CachyOS build or for anti-cheat.
4. Settings, Downloads: turn off Shader Pre-Caching.
5. Typical launch options: `game-performance %command%`

DLSS titles: `dlss-swapper game-performance %command%`

MangoHud: `mangohud game-performance %command%`

Do not add `-cef-disable-gpu-compositing`. Halo's Xbox login is a Steam
web view and needs GPU-accelerated web views. The menu flash was niri's
xwayland-satellite plus the 2026-09-01 client. That satellite left with
niri.

`steam-tui` is installed and stores an empty library. The working
library is the Steam client on Super+Shift+S. Run `steamcmd` once, log
in, then quit, before the first `steam-tui`. Do not put the Steam
password in this repo.

## Splitgate: Arena Reloaded (AppID 2918300)

`common/Splitgate 2` on `/mnt/tb1/SteamLibrary`. Steam marks it
Linux-native, but the install is a Windows Unreal exe. Without a forced
Proton tool the Linux runtime exits in about a second. Force
**proton-cachyos-slr**. Launch options:

```
game-performance %command% -windowed
```

Dedicated servers went P2P on 2026-09-03. Use the in-game server browser.

## Halo Infinite (AppID 1240440)

Also on `/mnt/tb1/SteamLibrary`. It exited instantly while the old
Windows launch options called `gamemoderun`, which is not installed here.

| Setting | Value |
| --- | --- |
| Compatibility tool | `proton-cachyos-slr` |
| Launch options | `VKD3D_DISABLE_EXTENSIONS=VK_NV_device_generated_commands_compute PROTON_USE_XALIA=0 game-performance %command%` |

The `VKD3D_DISABLE_EXTENSIONS` line is the NVIDIA workaround. RTX cards
freeze in-game without it. Ranked can still be picky on a custom kernel.

Xbox Live login is tabled. The sign-in window is Steam's web view, not
a Halo window. Leave the game windowed while signing in. The clock has
to be synced (`systemd-timesyncd`). A sign-in loop: clear the Wine Xbox
credential keys in `compatdata/1240440/pfx/user.reg` and delete
`Halo Infinite/XalClockSkew.json`.

## Heroic

The default Wine on this box is system wine, not Proton. The wrapper is
`game-performance`. Force **proton-cachyos-slr** per game when you want
the CachyOS build.

For Honor (Epic) is tabled. Ubisoft ended Linux and Steam Deck support
for it on 2026-09-10. `wine-mono` is the distro package. Skip Wine's own
mono installer.

## Not installed

Lutris. Extra Proton-GE. Add `protonup-qt` later if one game needs it.
