#!/usr/bin/env python3
"""One disk on the bar. Right click cycles. Root is first."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from waybar_level import bare, face, level

# md-harddisk shows the platter. fa-hdd draws as a plain box.
ICON = "\U000f02ca"

INDEX = Path.home() / ".cache" / "novalis" / "waybar-disk.index"
SIGNAL = 1


def emit(text: str, tooltip: str, temp_f: int | None = None, percent: int | None = None) -> None:
    print(json.dumps({
        "text": text,
        "tooltip": tooltip,
        "class": level(temp_f, percent),
    }, ensure_ascii=False), flush=True)


def disk_temp_f(dev: str) -> int | None:
    if not dev.startswith("nvme"):
        return None
    parent = dev.split("p", 1)[0]
    base = Path("/sys/class/block") / parent / "device"
    for path in sorted(base.glob("hwmon*/temp1_input")):
        try:
            celsius = int(path.read_text().strip()) / 1000
        except (OSError, ValueError):
            continue
        return round(celsius * 9 / 5 + 32)
    return None


def lsblk() -> list[dict]:
    raw = subprocess.check_output(
        ["lsblk", "-J", "-b", "-o", "NAME,LABEL,TYPE,SIZE,MOUNTPOINTS,MODEL"],
        text=True,
    )
    disks: list[dict] = []

    def walk(nodes: list[dict], model: str = "") -> None:
        for node in nodes:
            here = (node.get("model") or "").strip() or model
            walk(node.get("children") or [], here)
            if node.get("type") != "part":
                continue
            mounts = [m for m in (node.get("mountpoints") or []) if m]
            label = (node.get("label") or "").strip()
            dev = node.get("name") or ""
            item = {
                "mount": mounts[0] if mounts else None,
                "size": int(node["size"]),
                "dev": dev,
                "model": here,
            }
            if "/" in mounts:
                item["name"] = "root"
                item["mount"] = "/"
                disks.append(item)
            elif label:
                item["name"] = label
                disks.append(item)

    walk(json.loads(raw).get("blockdevices") or [])
    disks.sort(key=lambda d: (d["name"] != "root", d["name"]))
    return disks


def usage(mount: str) -> tuple[int, int]:
    st = os.statvfs(mount)
    used = (st.f_blocks - st.f_bfree) * st.f_frsize
    avail = st.f_bavail * st.f_frsize
    return used, used + avail


def gb(n: int) -> str:
    return f"{n / (1024 ** 3):.0f}G"


def show(disks: list[dict], index: int) -> None:
    if not disks:
        emit("—", "No disks")
        return
    disk = disks[index % len(disks)]
    temp = disk_temp_f(disk.get("dev") or "")
    pct: int | None = None
    if disk["mount"]:
        used, total = usage(disk["mount"])
        pct = round(100 * used / total) if total else 0
        tip = f"{disk['name']}\n{disk['mount']}\n{gb(used)} / {gb(total)}"
    else:
        tip = f"{disk['name']}\nnot mounted\n{gb(disk['size'])}"
    if temp is None:
        tip += "\nNo temperature sensor"
    else:
        tip += f"\n{temp}°"
    value, suffix = face(temp, pct)
    emit(f"{bare(value, suffix)} {ICON}", tip, temp, pct)


def read_index(count: int) -> int:
    try:
        index = int(INDEX.read_text().strip())
    except (OSError, ValueError):
        index = 0
    if count <= 0:
        return 0
    return index % count


def write_index(index: int) -> None:
    INDEX.parent.mkdir(parents=True, exist_ok=True)
    INDEX.write_text(str(index))


def main() -> None:
    disks = lsblk()
    if len(sys.argv) > 1 and sys.argv[1] == "next":
        index = (read_index(len(disks)) + 1) % max(len(disks), 1)
        write_index(index)
        subprocess.run(["pkill", f"-RTMIN+{SIGNAL}", "-x", "waybar"], check=False)
        return
    show(disks, read_index(len(disks)))


if __name__ == "__main__":
    main()
