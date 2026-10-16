#!/usr/bin/env python3
"""Waybar weather chip. Open-Meteo, Fahrenheit, cached for 30 minutes.

The chip is the selected place: temperature and condition. Hover shows
that place's short summary. Right click cycles the places. Left click
opens that place's week in Fuzzel. The other places are lines under
it. Choosing one loads that week, with the rest below.

Order: Citrus Heights, Sugar Bowl, Nevada City, Tahoe, San Francisco.
Sugar Bowl is the Norden resort. Tahoe is the lake.
"""

from __future__ import annotations

import datetime
import fcntl
import json
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

CACHE = Path.home() / ".cache" / "novalis"
WX_FILE = CACHE / "weather.json"
INDEX = CACHE / "waybar-weather.index"
LOCK_FILE = CACHE / "weather.lock"
WX_MAX_AGE = 30 * 60
SIGNAL = 3
MENU_WIDTH = 78

# Sugar Bowl is the resort above Norden, about 7000 ft.
# Tahoe is the lake point from Open-Meteo's geocoder.
PLACES = [
    {"city": "Citrus Heights", "lat": 38.70712, "lon": -121.28106},
    {"city": "Sugar Bowl", "lat": 39.3044, "lon": -120.3356},
    {"city": "Nevada City", "lat": 39.26173, "lon": -121.01779},
    {"city": "Tahoe", "lat": 39.14525, "lon": -120.09572},
    {"city": "San Francisco", "lat": 37.77493, "lon": -122.41942},
]

CODES = {
    0: ("Clear", "☀"),
    1: ("Mainly clear", "🌤"),
    2: ("Partly cloudy", "⛅"),
    3: ("Overcast", "☁"),
    45: ("Fog", "🌫"),
    48: ("Fog", "🌫"),
    51: ("Drizzle", "🌦"),
    53: ("Drizzle", "🌦"),
    55: ("Drizzle", "🌦"),
    56: ("Freezing drizzle", "🌧"),
    57: ("Freezing drizzle", "🌧"),
    61: ("Rain", "🌧"),
    63: ("Rain", "🌧"),
    65: ("Heavy rain", "🌧"),
    66: ("Freezing rain", "🌧"),
    67: ("Freezing rain", "🌧"),
    71: ("Snow", "❄"),
    73: ("Snow", "❄"),
    75: ("Heavy snow", "❄"),
    77: ("Snow", "❄"),
    80: ("Showers", "🌧"),
    81: ("Showers", "🌧"),
    82: ("Heavy showers", "🌧"),
    85: ("Snow showers", "❄"),
    86: ("Snow showers", "❄"),
    95: ("Thunder", "⛈"),
    96: ("Thunder", "⛈"),
    99: ("Thunder", "⛈"),
}


def chip(text: str) -> str:
    """Keep the temperature at the bar size and draw the condition larger."""
    if "<span" in text or "° " not in text:
        return text
    temp, icon = text.split("° ", 1)
    return f"{temp}° <span size='16384'>{icon}</span>"


def emit(text: str, tooltip: str) -> None:
    print(json.dumps({"text": text, "tooltip": tooltip}, ensure_ascii=False), flush=True)


def load_json(path: Path) -> dict | None:
    try:
        return json.loads(path.read_text())
    except (OSError, json.JSONDecodeError):
        return None


def save_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data))


def fresh(data: dict | None, max_age: int) -> bool:
    if not data or "fetched" not in data:
        return False
    return time.time() - float(data["fetched"]) < max_age


def fetch_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": "novalis-waybar"})
    with urllib.request.urlopen(req, timeout=8) as resp:
        return json.loads(resp.read().decode())


def condition(code: int) -> tuple[str, str]:
    return CODES.get(code, ("Weather", "·"))


def compass(degrees: float) -> str:
    names = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    return names[round(degrees / 45) % 8]


def clock(stamp: str) -> str:
    if "T" not in stamp:
        return stamp
    return stamp.split("T", 1)[1][:5]


def day_name(day: str, index: int) -> str:
    if index == 0:
        return "Today"
    return datetime.date.fromisoformat(day).strftime("%a")


def fill(left: str, right: str) -> str:
    """One row that reaches both edges of the Fuzzel menu."""
    gap = MENU_WIDTH - len(left) - len(right)
    if gap < 2:
        return f"{left}  {right}"
    return f"{left}{' ' * gap}{right}"


def spread(parts: list[str]) -> str:
    """Place columns across the menu, with the last one on the right edge."""
    used = sum(len(part) for part in parts)
    gaps = len(parts) - 1
    slack = MENU_WIDTH - used
    if gaps <= 0 or slack < gaps * 2:
        return "  ".join(parts)
    base, extra = divmod(slack, gaps)
    chunks = [parts[0]]
    for index, part in enumerate(parts[1:]):
        chunks.append(" " * (base + (1 if index < extra else 0)))
        chunks.append(part)
    return "".join(chunks)


def report_lines(city: str, data: dict) -> list[str]:
    current = data["current"]
    label, _icon = condition(int(current["weather_code"]))
    temp = round(float(current["temperature_2m"]))
    feels = round(float(current["apparent_temperature"]))
    humidity = round(float(current["relative_humidity_2m"]))
    wind = round(float(current["wind_speed_10m"]))
    direction = compass(float(current["wind_direction_10m"]))
    clouds = round(float(current.get("cloud_cover") or 0))
    rain_now = float(current.get("precipitation") or 0)
    rain_line = "No rain right now" if rain_now <= 0 else f"Rain now {rain_now:.2f} in"
    lines = [
        fill(city, f"{label}, {temp}°"),
        spread([
            f"Feels like {feels}°",
            f"Humidity {humidity}%",
            f"Wind {wind} mph {direction}",
        ]),
        fill(f"Clouds {clouds}%", rain_line),
        "",
    ]
    daily = data["daily"]
    for index, day in enumerate(daily["time"]):
        dlabel, _icon = condition(int(daily["weather_code"][index]))
        high = round(float(daily["temperature_2m_max"][index]))
        low = round(float(daily["temperature_2m_min"][index]))
        chance = daily["precipitation_probability_max"][index]
        chance_s = "—" if chance is None else f"{round(float(chance))}%"
        uv = daily["uv_index_max"][index]
        uv_s = "—" if uv is None else f"{float(uv):.0f}"
        name = day_name(day, index)
        lines.append(spread([
            f"{name:<7}{dlabel:<18}{high:>3} / {low:<3}",
            f"rain {chance_s:>4}",
            f"UV {uv_s:>2}",
        ]))
        lines.append(fill(
            f"{'':7}sunrise {clock(daily['sunrise'][index])}",
            f"sunset {clock(daily['sunset'][index])}",
        ))
    return lines


def forecast(loc: dict) -> dict:
    url = (
        "https://api.open-meteo.com/v1/forecast"
        f"?latitude={loc['lat']}&longitude={loc['lon']}"
        "&current=temperature_2m,apparent_temperature,relative_humidity_2m,"
        "weather_code,wind_speed_10m,wind_direction_10m,precipitation,cloud_cover"
        "&daily=temperature_2m_max,temperature_2m_min,weather_code,"
        "precipitation_probability_max,uv_index_max,sunrise,sunset"
        "&temperature_unit=fahrenheit"
        "&wind_speed_unit=mph"
        "&precipitation_unit=inch"
        "&timezone=America%2FLos_Angeles"
        "&forecast_days=7"
    )
    data = fetch_json(url)
    code = int(data["current"]["weather_code"])
    temp = round(float(data["current"]["temperature_2m"]))
    high = round(float(data["daily"]["temperature_2m_max"][0]))
    low = round(float(data["daily"]["temperature_2m_min"][0]))
    label, icon = condition(code)
    feels = round(float(data["current"]["apparent_temperature"]))
    city = loc["city"]
    return {
        "text": f"{temp}° {icon}",
        "tooltip": f"{city}\n{label}\n{temp}°   high {high}°   low {low}°",
        "lines": report_lines(city, data),
        "label": label,
        "temp": temp,
        "feels": feels,
        "fetched": time.time(),
    }


def load_cache() -> dict:
    data = load_json(WX_FILE)
    if not isinstance(data, dict):
        return {}
    kept = {}
    for place in PLACES:
        entry = data.get(place["city"])
        if isinstance(entry, dict) and entry.get("text") and entry.get("lines"):
            kept[place["city"]] = entry
    return kept


def read_index() -> int:
    try:
        index = int(INDEX.read_text().strip())
    except (OSError, ValueError):
        index = 0
    return index % len(PLACES)


def write_index(index: int) -> None:
    INDEX.parent.mkdir(parents=True, exist_ok=True)
    INDEX.write_text(str(index))


def ready(entry: dict | None) -> bool:
    return bool(
        isinstance(entry, dict)
        and entry.get("text")
        and entry.get("lines")
        and entry.get("label")
        and "temp" in entry
        and "feels" in entry
    )


def ensure(cache: dict, place: dict) -> dict | None:
    cached = cache.get(place["city"])
    if fresh(cached, WX_MAX_AGE) and ready(cached):
        return cached
    try:
        result = forecast(place)
    except (OSError, ValueError, KeyError, json.JSONDecodeError):
        return cached
    cache[place["city"]] = result
    save_json(WX_FILE, cache)
    return result


def other_line(place: dict, result: dict | None) -> str:
    if result and result.get("label"):
        left = (
            f"{place['city']}, {result['label']} {result['temp']}°,"
            f" feels like {result['feels']}°"
        )
    else:
        left = place["city"]
    return fill(left, "See forecast")


def menu_for(cache: dict, viewed: dict) -> str:
    result = ensure(cache, viewed)
    if result and result.get("lines"):
        body = "\n".join(result["lines"])
    else:
        body = fill(viewed["city"], "Weather unavailable")
    others = [
        other_line(place, ensure(cache, place))
        for place in PLACES
        if place["city"] != viewed["city"]
    ]
    return body + "\n\n" + "\n".join(others)


def picked_place(line: str) -> dict | None:
    if not line.endswith("See forecast"):
        return None
    for place in PLACES:
        if line.startswith(place["city"]):
            return place
    return None


def show_menus() -> None:
    viewed = PLACES[read_index()]
    while True:
        with LOCK_FILE.open("a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            text = menu_for(load_cache(), viewed)
        chosen = subprocess.run(
            [
                "fuzzel",
                "--dmenu",
                "--no-sort",
                "--minimal-lines",
                "--prompt",
                "Weather  ",
                "--width",
                str(MENU_WIDTH),
                "--lines",
                "36",
            ],
            input=text + "\n",
            text=True,
            capture_output=True,
            check=False,
        ).stdout.rstrip("\n")
        nxt = picked_place(chosen)
        if nxt is None:
            return
        viewed = nxt


def main() -> None:
    CACHE.mkdir(parents=True, exist_ok=True)
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "next":
        write_index((read_index() + 1) % len(PLACES))
        subprocess.run(["pkill", f"-RTMIN+{SIGNAL}", "-x", "waybar"], check=False)
        return
    if cmd == "detail":
        show_menus()
        return
    with LOCK_FILE.open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        cache = load_cache()
        if cmd == "lines":
            print(menu_for(cache, PLACES[read_index()]))
            return
        place = PLACES[read_index()]
        result = ensure(cache, place)
        if result and result.get("text"):
            emit(chip(result["text"]), result.get("tooltip") or result["text"])
        else:
            emit("—", f"{place['city']}\nWeather unavailable")


if __name__ == "__main__":
    main()
