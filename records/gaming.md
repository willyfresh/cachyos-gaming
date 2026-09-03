# Gaming on Borg

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

Steam menus flash-and-die on niri after the 2026-09-01 client update (xwayland-satellite treats CEF child windows badly). We launch Steam with `-cef-disable-gpu-compositing` via `configs/applications/steam.desktop`, and we do not clip Steam windows. If menus still vanish, fully quit Steam (`steam -shutdown`) and reopen it from the launcher. Settings can also be opened with `steam steam://open/settings`.

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

## Heroic

Settings → Wine version: **Proton - proton-cachyos-slr**. Wrapper: `game-performance`.

## What we did not install

- **Lutris** — not requested. `cachyos-gaming-applications` would pull it if you want a third launcher later.
- **GameMode** — conflicts with `ananicy-cpp`.
- Extra Proton-GE — Proton-CachyOS SLR covers this; add Proton-GE later with protonup-qt if a specific game needs it.

## Niri notes

Steam already has window rules (floating overlay toasts). Move a game to the other monitor with Super+Shift+←/→. If a game refuses to go exclusive fullscreen, wrap it in gamescope.
