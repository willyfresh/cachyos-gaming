#!/usr/bin/env python3
"""One temperature on the bar. Click cycles CPU, then each NVMe."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

INDEX = Path.home() / ".cache" / "novalis" / "waybar-temp.index"
SIGNAL = 2
CPU = Path("/sys/devices/pci0000:00/0000:00:18.3/hwmon")


def emit(text: str, tooltip: str, critical: bool = False) -> None:
    payload = {"text": text, "tooltip": tooltip}
    if critical:
        payload["class"] = "critical"
    print(json.dumps(payload, ensure_ascii=False), flush=True)


def read_temp(path: Path) -> float | None:
    try:
        return int(path.read_text().strip()) / 1000
    except (OSError, ValueError):
        return None


def first_temp(directory: Path, name: str) -> tuple[str, float] | None:
    if not directory.is_dir():
        return None
    for child in sorted(directory.glob("hwmon*/temp1_input")):
        value = read_temp(child)
        if value is not None:
            return name, value
    return None


def nvme_sensors() -> list[tuple[str, float]]:
    raw = subprocess.check_output(
        ["lsblk", "-J", "-o", "NAME,LABEL,TYPE"],
        text=True,
    )
    labels: dict[str, str] = {}

    def walk(nodes: list[dict]) -> None:
        for node in nodes:
            name = node.get("name") or ""
            if node.get("type") == "disk" and name.startswith("nvme"):
                label = ""
                for child in node.get("children") or []:
                    label = (child.get("label") or "").strip()
                    if label:
                        break
                labels[name] = label or name
            walk(node.get("children") or [])

    walk(json.loads(raw).get("blockdevices") or [])
    found: list[tuple[str, float]] = []
    for name, label in labels.items():
        sensor = first_temp(Path("/sys/class/block") / name / "device", label)
        if sensor is not None:
            found.append(sensor)
    found.sort(key=lambda item: item[0])
    return found


def sensors() -> list[tuple[str, float]]:
    items: list[tuple[str, float]] = []
    cpu = first_temp(CPU, "CPU")
    if cpu is not None:
        items.append(cpu)
    items.extend(nvme_sensors())
    return items


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


def fahrenheit(celsius: float) -> int:
    return round(celsius * 9 / 5 + 32)


def show(items: list[tuple[str, float]], index: int) -> None:
    if not items:
        emit("—", "No temperature sensor")
        return
    name, value = items[index % len(items)]
    rounded = fahrenheit(value)
    others = "\n".join(f"{n} {fahrenheit(v)}°" for n, v in items)
    emit(f"{name} {rounded}°", others, critical=rounded >= 176)


def main() -> None:
    items = sensors()
    if len(sys.argv) > 1 and sys.argv[1] == "next":
        index = (read_index(len(items)) + 1) % max(len(items), 1)
        write_index(index)
        subprocess.run(["pkill", f"-RTMIN+{SIGNAL}", "-x", "waybar"], check=False)
        return
    show(items, read_index(len(items)))


if __name__ == "__main__":
    main()
