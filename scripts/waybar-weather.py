#!/usr/bin/env python3
"""Waybar weather chip. Open-Meteo, Fahrenheit, cached for 30 minutes.

The chip is the current temperature and condition. Hover shows the
short summary. A click opens the week in Fuzzel.

Location comes from the public IP and is cached for a day. If that
lookup fails, the last saved place is used, then Citrus Heights.
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
LOC_FILE = CACHE / "weather-location.json"
WX_FILE = CACHE / "weather.json"
LOCK_FILE = CACHE / "weather.lock"
LOC_MAX_AGE = 24 * 60 * 60
WX_MAX_AGE = 30 * 60
FALLBACK = {"city": "Citrus Heights", "lat": 38.7071, "lon": -121.2811}

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


def location(cached: dict | None) -> dict:
    if fresh(cached, LOC_MAX_AGE) and "lat" in cached and "lon" in cached:
        return cached
    try:
        data = fetch_json("https://ipinfo.io/json")
        lat_s, lon_s = data["loc"].split(",")
        found = {
            "city": data.get("city") or FALLBACK["city"],
            "lat": float(lat_s),
            "lon": float(lon_s),
            "fetched": time.time(),
        }
        save_json(LOC_FILE, found)
        return found
    except (OSError, ValueError, KeyError, json.JSONDecodeError):
        if cached and "lat" in cached and "lon" in cached:
            return cached
        return dict(FALLBACK)


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
        city,
        f"{label}, {temp}°",
        f"Feels like {feels}°",
        f"Humidity {humidity}%",
        f"Wind {wind} mph {direction}",
        f"Clouds {clouds}%",
        rain_line,
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
        lines.append(
            f"{name:<6} {dlabel:<16} {high:>3} / {low:<3}  rain {chance_s:<4}  UV {uv_s}"
        )
        lines.append(
            f"       sunrise {clock(daily['sunrise'][index])}"
            f"   sunset {clock(daily['sunset'][index])}"
        )
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
    city = loc.get("city") or FALLBACK["city"]
    return {
        "text": f"{temp}° {icon}",
        "tooltip": f"{city}\n{label}\n{temp}°   high {high}°   low {low}°",
        "lines": report_lines(city, data),
        "fetched": time.time(),
    }


def cached_or_fresh() -> dict | None:
    cached = load_json(WX_FILE)
    if fresh(cached, WX_MAX_AGE) and cached.get("text") and cached.get("lines"):
        return cached
    try:
        result = forecast(location(load_json(LOC_FILE)))
        save_json(WX_FILE, result)
        return result
    except (OSError, ValueError, KeyError, json.JSONDecodeError):
        if cached and cached.get("text"):
            return cached
        return None


def main() -> None:
    CACHE.mkdir(parents=True, exist_ok=True)
    with LOCK_FILE.open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        result = cached_or_fresh()
        if len(sys_argv_detail()):
            lines = (result or {}).get("lines") or ["Weather unavailable"]
            if sys_argv_detail() == "lines":
                print("\n".join(lines))
                return
            subprocess.run(
                [
                    "fuzzel",
                    "--dmenu",
                    "--prompt",
                    "Weather  ",
                    "--width",
                    "78",
                    "--lines",
                    "22",
                ],
                input="\n".join(lines) + "\n",
                text=True,
                check=False,
            )
            return
        if result and result.get("text"):
            emit(chip(result["text"]), result.get("tooltip") or result["text"])
        else:
            emit("—", "Weather unavailable")


def sys_argv_detail() -> str:
    if len(sys.argv) > 1 and sys.argv[1] in {"detail", "lines"}:
        return sys.argv[1]
    return ""


if __name__ == "__main__":
    main()
