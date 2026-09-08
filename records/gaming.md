# Gaming on Novalis

RTX 2060, nvidia-open 610.57.04, niri + noctalia. Drivers were already in place from the CachyOS install (`nvidia-utils`, `lib32-nvidia-utils`, `egl-wayland`).

## Installed

| Package | Why |
| --- | --- |
| `cachyos-gaming-meta` | Proton-CachyOS SLR, umu-launcher, wine-cachyos-opt, winetricks, 32-bit libs |
| `steam` | Steam |
| `heroic-games-launcher-bin` | Epic / GOG / Amazon |
| `mangohud` + `lib32-mangohud` | FPS overlay |
| `goverlay` | GUI for MangoHud |
| `gamescope` | Nested compositor for awkward fullscreen games |

`ananicy-cpp` is already running (CachyOS default). Do **not** also use Feral GameMode — they fight over niceness. Use `game-performance` instead.

## Steam

Steam menus on niri are flaky (xwayland-satellite + the 2026-09-01 client). Do **not** launch Steam with `-cef-disable-gpu-compositing`: Halo Infinite’s Xbox login is a Steam web-view popup and needs GPU-accelerated web views. Open Interface settings without the menu bar: `steam steam://settings/interface` and tick **Enable GPU accelerated rendering in web views**.

1. Open Steam, log in, let it finish first-run downloads.
2. Settings → Compatibility: leave the **default** on Valve Proton or Proton Experimental.
3. Per-game, force **proton-cachyos** (the SLR build) when you want CachyOS extras or anti-cheat titles.
4. Settings → Downloads: turn **off** Shader Pre-Caching (Proton-CachyOS already has codecs; pre-cache just slows launches).
5. Per-game launch options, typical:

```
game-performance %command%
```

DLSS titles:

```
dlss-swapper game-performance %command%
```

MangoHud:

```
mangohud game-performance %command%
```

## Splitgate: Arena Reloaded (AppID 2918300)

Library lives on `/mnt/tb1/SteamLibrary` (`common/Splitgate 2`). Steam marks it
Linux-native, but the install is a Windows Unreal `.exe`. Without a forced
Proton tool it dies in about a second (Steam Linux Runtime tries to exec the
exe). Force **proton-cachyos-slr**. Launch options:

```
game-performance %command% -windowed
```

niri keeps it maximized, not exclusive-fullscreen (`steam_app_2918300`).
Dedicated servers went P2P on **2026-09-03** — use the in-game server
browser to host or join. RedKard anti-cheat is supposed to allow Proton.

## Halo Infinite (AppID 1240440)

Library lives on `/mnt/tb1/SteamLibrary`. It was exiting instantly because the old Windows launch options called `gamemoderun`, which is not installed here (ananicy-cpp is the CachyOS niceness daemon).

| Setting | Value |
| --- | --- |
| Compatibility tool | `proton-cachyos-slr` (EAC-friendly SLR build) |
| Launch options | `VKD3D_DISABLE_EXTENSIONS=VK_NV_device_generated_commands_compute PROTON_USE_XALIA=0 game-performance %command%` |

The `VKD3D_DISABLE_EXTENSIONS=...` bit is the NVIDIA workaround from ProtonDB (RTX cards freeze in-game without it). Campaign and social/custom games work with Microsoft’s EAC opt-in; ranked can still be picky on a custom kernel.

Xbox Live login needs:

1. A synced clock (`systemd-timesyncd`). XAL will refuse tokens if the machine clock is skewed.
2. Steam **GPU accelerated rendering in web views** on (the Microsoft sign-in window is a Steam CEF popup).
3. If you get a sign-in loop, clear Wine Xbox credentials in `compatdata/1240440/pfx/user.reg` (`Credential Manager` keys mentioning xbox / Xbl) and delete `Halo Infinite/XalClockSkew.json`.
4. Do **not** exclusive-fullscreen Halo while signing in. The Microsoft window is Steam overlay; niri fullscreen steals the pointer. Leave it windowed (`open-fullscreen false`), or tap Super+Shift+F to drop fullscreen, then click the login. `PROTON_USE_XALIA=0` stops Proton’s gamepad helper from eating mouse input on that dialog.

## Heroic

Default Wine version on this box is system **wine-11.16** (`/usr/bin/wine`),
not Proton. Wrapper: `game-performance`. Force **proton-cachyos-slr**
per-game when you want CachyOS extras or anti-cheat titles.

For Honor (Epic, Sundrop) is tabled. Distro `wine-mono` is installed.
wine-11.16 showed Connect then hung in CEF. `proton-cachyos-slr` (umu)
started Connect with **no window**. Prefix:
`/run/media/willyfresh/TB1/Heroic/Prefixes/For Honor`. Ubisoft drops
Linux / Steam Deck for this title on **2026-09-10**. Notes: `records/next.md`.

## What we did not install

- **Lutris** — not requested. `cachyos-gaming-applications` would pull it if you want a third launcher later.
- **GameMode** — conflicts with `ananicy-cpp`.
- Extra Proton-GE — Proton-CachyOS SLR covers this; add Proton-GE later with protonup-qt if a specific game needs it.

## Niri notes

Steam already has window rules (floating overlay toasts). Move a game to the other monitor with Super+Shift+←/→. If a game refuses to go exclusive fullscreen, wrap it in gamescope.
