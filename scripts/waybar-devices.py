#!/usr/bin/env python3
"""Every device value, in Fuzzel.

Left click on the CPU, memory, disk, GPU, or network chip runs this.
The bar itself stays a percent. A hot part shows degrees there instead.
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


def entry(name: str, percent: int | None, temp: int | None, detail: str) -> str:
    line = f"{name:<7}  {digits(percent, '%')}   {digits(temp, '°')}"
    if detail:
        line += f"   {detail}"
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


def network_lines() -> list[str]:
    """Address, gateway, and a short up/down sample for each live link."""
    try:
        links = json.loads(subprocess.check_output(["ip", "-json", "addr"], text=True))
        routes = json.loads(subprocess.check_output(
            ["ip", "-json", "route", "show", "default"],
            text=True,
        ))
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
        return [f"{'Network':<7}  unavailable"]
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
    if not live:
        return [f"{'Network':<7}  disconnected"]
    before = read_counters()
    time.sleep(0.25)
    after = read_counters()
    rows: list[str] = []
    for name, address, via in live:
        start = before.get(name)
        end = after.get(name)
        speeds = ""
        if start is not None and end is not None:
            speeds = (
                f"   ↓ {rate(end[0] - start[0], 0.25)}"
                f"   ↑ {rate(end[1] - start[1], 0.25)}"
            )
        where = address or "no address"
        hop = f"   via {via}" if via else ""
        label = "Network" if not rows else ""
        rows.append(f"{label:<7}  {name}   {where}{hop}{speeds}")
    return rows


def device_lines() -> list[str]:
    cpu = load("waybar-cpu.py")
    mem = load("waybar-mem.py")
    disk = load("waybar-disk.py")
    gpu = load("waybar-gpu.py")

    rows = [
        entry("CPU", cpu.cpu_percent_shown(), cpu.cpu_temp_f(), ""),
        entry("Memory", mem.mem_percent(), None, ""),
    ]

    for item in disk.lsblk():
        temp = disk.disk_temp_f(item.get("dev") or "")
        if item["mount"]:
            used, total = disk.usage(item["mount"])
            percent = round(100 * used / total) if total else 0
            detail = f"{disk.gb(used)} / {disk.gb(total)}"
            if item["mount"] != "/":
                detail += f"   {item['mount']}"
        else:
            percent = None
            detail = f"not mounted   {disk.gb(item['size'])}"
        rows.append(entry(item["name"], percent, temp, detail))

    try:
        card = gpu.read_gpu()
    except (OSError, ValueError, IndexError, subprocess.CalledProcessError):
        rows.append(entry("GPU", None, None, "unavailable"))
    else:
        rows.append(entry(
            "GPU",
            int(card["util"]),
            int(card["temp"]),
            f"{card['name']}   {card['used']} MB / {card['total']} MB",
        ))
    rows.extend(network_lines())
    return rows


def main() -> None:
    rows = device_lines()
    if len(sys.argv) > 1 and sys.argv[1] == "lines":
        print("\n".join(rows))
        return
    subprocess.run(
        [
            "fuzzel",
            "--dmenu",
            "--prompt",
            "Devices  ",
            "--width",
            "84",
            "--lines",
            "12",
        ],
        input="\n".join(rows) + "\n",
        text=True,
        check=False,
    )


if __name__ == "__main__":
    main()
