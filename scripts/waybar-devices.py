#!/usr/bin/env python3
"""Every device value, in Fuzzel.

Left click on the CPU, memory, disk, GPU, or network chip runs this.
Super+Escape does too. The bar itself stays a percent. A hot part
shows degrees there instead.

Return on a row opens a tool. CPU, cores, and memory open btop.
A mounted drive opens yazi there. The GPU opens nvtop. A connected
network opens its gateway in the browser. A down link opens nmtui.
"""

from __future__ import annotations

import importlib.util
import json
import subprocess
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from waybar_level import digits


def load(name: str):
    path = Path(__file__).with_name(name)
    spec = importlib.util.spec_from_file_location(
        name.removesuffix(".py").replace("-", "_"),
        path,
    )
    if spec is None or spec.loader is None:
        raise ImportError(name)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def entry(
    name: str,
    percent: int | None,
    temp: int | None = None,
    detail: str = "",
    *,
    show_temp: bool = True,
) -> str:
    line = f"{name:<7}  {digits(percent, '%')}"
    if show_temp:
        line += f"   {digits(temp, '°')}"
    if detail:
        # No temperature column, so one extra space keeps the detail
        # on the same mark as a row that has degrees.
        line += ("    " if not show_temp else "   ") + detail
    return line


def read_counters() -> dict[str, tuple[int, int]]:
    found: dict[str, tuple[int, int]] = {}
    for line in Path("/proc/net/dev").read_text().splitlines()[2:]:
        name, rest = line.split(":", 1)
        cols = rest.split()
        found[name.strip()] = (int(cols[0]), int(cols[8]))
    return found


def rate(nbytes: int, seconds: float) -> str:
    per = max(nbytes, 0) * 8 / seconds
    if per >= 1_000_000:
        return f"{per / 1_000_000:.1f} Mb/s"
    if per >= 1_000:
        return f"{per / 1_000:.0f} kb/s"
    return f"{per:.0f} b/s"


def cpu_snapshot() -> tuple[tuple[int, int], list[tuple[int, int]]]:
    """Aggregate counters, then one pair per logical processor."""
    agg = (0, 0)
    cores: list[tuple[int, int]] = []
    for line in Path("/proc/stat").read_text().splitlines():
        parts = line.split()
        if not parts or not parts[0].startswith("cpu"):
            break
        nums = [int(n) for n in parts[1:]]
        sample = (nums[3] + nums[4], sum(nums))
        if parts[0] == "cpu":
            agg = sample
        else:
            cores.append(sample)
    return agg, cores


def delta_percent(prev: tuple[int, int], now: tuple[int, int]) -> int:
    delta = now[1] - prev[1]
    if delta <= 0:
        return 0
    percent = round(100 * (delta - (now[0] - prev[0])) / delta)
    return max(0, min(100, percent))


def cpu_model() -> str:
    for line in Path("/proc/cpuinfo").read_text().splitlines():
        if line.startswith("model name"):
            return " ".join(line.split(":", 1)[1].split())
    return ""


def live_links() -> list[tuple[str, str | None, str | None]] | None:
    try:
        links = json.loads(subprocess.check_output(["ip", "-json", "addr"], text=True))
        routes = json.loads(subprocess.check_output(
            ["ip", "-json", "route", "show", "default"],
            text=True,
        ))
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
        return None
    gateway = {item.get("dev"): item.get("gateway") for item in routes}
    live: list[tuple[str, str | None, str | None]] = []
    for link in links:
        if link.get("link_type") == "loopback":
            continue
        if link.get("operstate") not in {"UP", "UNKNOWN"}:
            continue
        inet = [
            addr["local"]
            for addr in link.get("addr_info") or []
            if addr.get("family") == "inet" and addr.get("local")
        ]
        live.append((link["ifname"], inet[0] if inet else None, gateway.get(link["ifname"])))
    return live


HERE = Path(__file__).resolve().parent


def terminal(app: str, *cmd: str) -> list[str]:
    """Focus a kitty with this class, or start one."""
    return [
        str(HERE / "launch-or-focus-app.sh"),
        f"^{app}$",
        "setsid", "kitty", "--class", app, "--title", app, "-e", *cmd,
    ]


# Its own tiled window. Super+Ctrl+T uses a different class, so the two
# do not focus each other.
BTOP = terminal("btop-tile", "btop")


def yazi(name: str, mount: str) -> list[str]:
    app = "yazi-" + "".join(ch.lower() if ch.isalnum() else "-" for ch in name).strip("-")
    return terminal(app, "yazi", mount)


def network_rows(
    live: list[tuple[str, str | None, str | None]],
    before: dict[str, tuple[int, int]],
    after: dict[str, tuple[int, int]],
    seconds: float,
) -> list[tuple[str, list[str] | None]]:
    """Address, down and up, adapter, then the gateway."""
    if not live:
        return [(f"{'Network':<7}   disconnected", terminal("nmtui-tile", "nmtui"))]
    rows: list[tuple[str, list[str] | None]] = []
    for name, address, via in live:
        start = before.get(name)
        end = after.get(name)
        chunks = [f"{'Network' if not rows else '':<7}   {address or 'no address'}"]
        if start is not None and end is not None:
            chunks.append(
                f"↓ {rate(end[0] - start[0], seconds)}"
                f"   ↑ {rate(end[1] - start[1], seconds)}"
            )
        chunks.append(name)
        if via:
            chunks.append(f"via {via}")
        action = ["xdg-open", f"http://{via}"] if via else terminal("nmtui-tile", "nmtui")
        rows.append(("   ".join(chunks), action))
    return rows


def device_lines() -> list[tuple[str, list[str] | None]]:
    cpu = load("waybar-cpu.py")
    mem = load("waybar-mem.py")
    disk = load("waybar-disk.py")
    gpu = load("waybar-gpu.py")

    cpu_before, cores_before = cpu_snapshot()
    net_before = read_counters()
    links = live_links()
    time.sleep(0.25)
    cpu_after, cores_after = cpu_snapshot()
    net_after = read_counters()

    rows: list[tuple[str, list[str] | None]] = [
        (
            entry(
                "CPU",
                delta_percent(cpu_before, cpu_after),
                cpu.cpu_temp_f(),
                cpu_model(),
            ),
            BTOP,
        )
    ]
    percents = [
        delta_percent(prev, now)
        for prev, now in zip(cores_before, cores_after)
    ]
    if percents:
        rest = "  ".join(f"{value}%" for value in percents[1:])
        cores = f"{'Cores':<7}  {digits(percents[0], '%')}"
        if rest:
            cores += f"  {rest}"
        rows.append((cores, BTOP))

    used, total = mem.mem_bytes()
    rows.append((
        entry(
            "Memory",
            mem.mem_percent(),
            show_temp=False,
            detail=f"{mem.gb(used)} / {mem.gb(total)}",
        ),
        BTOP,
    ))

    try:
        card = gpu.read_gpu()
    except (OSError, ValueError, IndexError, subprocess.CalledProcessError):
        rows.append((entry("GPU", None, None, "unavailable"), terminal("nvtop-tile", "nvtop")))
    else:
        rows.append((
            entry(
                "GPU",
                int(card["util"]),
                int(card["temp"]),
                f"{card['used']} MB / {card['total']} MB   {card['name']}",
            ),
            terminal("nvtop-tile", "nvtop"),
        ))

    drives = disk.lsblk()
    if drives:
        rows.append(("Drives", None))
    for item in drives:
        temp = disk.disk_temp_f(item.get("dev") or "")
        model = item.get("model") or ""
        if item["mount"]:
            used_b, total_b = disk.usage(item["mount"])
            percent = round(100 * used_b / total_b) if total_b else 0
            detail = f"{disk.gb(used_b)} / {disk.gb(total_b)}"
            if item["mount"] != "/":
                detail += f"   {item['mount']}"
            action = yazi(item["name"], item["mount"])
        else:
            percent = None
            detail = f"not mounted   {disk.gb(item['size'])}"
            action = None
        if model:
            detail += f"   {model}"
        rows.append((entry(item["name"], percent, temp, detail), action))

    if links is None:
        rows.append((f"{'Network':<7}   unavailable", terminal("nmtui-tile", "nmtui")))
    elif links:
        rows.extend(network_rows(links, net_before, net_after, 0.25))
    else:
        rows.append((f"{'Network':<7}   disconnected", terminal("nmtui-tile", "nmtui")))
    return rows


def main() -> None:
    rows = device_lines()
    if len(sys.argv) > 1 and sys.argv[1] == "lines":
        print("\n".join(text for text, _action in rows))
        return
    width = max((len(text) for text, _action in rows), default=20)
    chosen = subprocess.run(
        [
            "fuzzel",
            "--dmenu",
            "--no-sort",
            "--minimal-lines",
            "--prompt",
            "Devices  ",
            "--width",
            str(width),
            "--lines",
            str(max(len(rows), 1)),
        ],
        input="\n".join(text for text, _action in rows) + "\n",
        text=True,
        capture_output=True,
        check=False,
    ).stdout.rstrip("\n")
    actions = {text: action for text, action in rows}
    command = actions.get(chosen)
    if not command:
        return
    subprocess.Popen(
        command,
        start_new_session=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


if __name__ == "__main__":
    main()
