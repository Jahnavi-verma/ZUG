# pyre-ignore-all-errors
import requests
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("OPENWEATHER_API_KEY")
CITY = os.getenv("CITY")

# -------------------------
# CONFIG (EXTREME EVENTS)
# -------------------------

RAIN_THRESHOLD = 70      # mm/day (extreme rain)
HEAT_THRESHOLD = 50      # °C (extreme heat)

# -------------------------
# API CALLS
# -------------------------

def fetch_current_weather():
    url = f"https://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={API_KEY}&units=metric"
    try:
        response = requests.get(url, timeout=8)
        response.raise_for_status()
        data = response.json()
        print("CURRENT RAW:", data)
        return data
    except Exception as e:
        print("Weather API failed (current):", e)
        return {
            "main": {"temp": 25},
            "rain": {"1h": 0}
        }


def fetch_forecast():
    url = f"https://api.openweathermap.org/data/2.5/forecast?q={CITY}&appid={API_KEY}&units=metric"
    try:
        response = requests.get(url, timeout=8)
        response.raise_for_status()
        data = response.json()
        print("FORECAST RAW:", data)
        return data
    except Exception as e:
        print("Weather API failed (forecast):", e)
        return {"list": []}   # ✅ correct fallback


# -------------------------
# WEEKLY RISK LOGIC
# -------------------------

def calculate_weather_risk(forecast_data):
    if "list" not in forecast_data or not forecast_data["list"]:
        return 0

    daily_rain = {}
    max_temp = -100

    # -------------------------
    # Aggregate forecast → daily
    # -------------------------
    for item in forecast_data["list"]:
        date = item["dt_txt"].split(" ")[0]

        temp = item.get("main", {}).get("temp", 0)
        rain = item.get("rain", {}).get("3h", 0)

        daily_rain[date] = daily_rain.get(date, 0) + rain
        max_temp = max(max_temp, temp)

    # -------------------------
    # Weekly signals
    # -------------------------
    total_week_rain = sum(daily_rain.values())
    max_daily_rain = max(daily_rain.values()) if daily_rain else 0
    rainy_days = sum(1 for r in daily_rain.values() if r > 0)

    # -------------------------
    # Risk calculation (EXTREME focused)
    # -------------------------
    risk = 0

    # Extreme single-day event
    if max_daily_rain > RAIN_THRESHOLD:
        risk += 0.3

    # Sustained bad week
    if total_week_rain > (RAIN_THRESHOLD * 2):
        risk += 0.2

    # Persistent disruption
    if rainy_days >= 3:
        risk += 0.1

    # Extreme heat
    if max_temp > HEAT_THRESHOLD:
        risk += 0.3

    return min(risk, 0.6)


# -------------------------
# REAL-TIME TRIGGER
# -------------------------

def check_weather_trigger(current_data):
    if "main" not in current_data:
        return None

    temp = current_data.get("main", {}).get("temp", 0)
    rain = current_data.get("rain", {}).get("1h", 0)

    # Extreme real-time triggers only
    if rain > RAIN_THRESHOLD:
        return "RAIN"

    if temp > HEAT_THRESHOLD:
        return "HEAT"

    return None


# -------------------------
# FINAL SERVICE FUNCTION
# -------------------------

def weather_service():
    current = fetch_current_weather()
    forecast = fetch_forecast()

    risk = calculate_weather_risk(forecast)
    trigger = check_weather_trigger(current)

    # Optional: predictive trigger (if extreme week ahead)
    if not trigger and risk >= 0.3:
        trigger = "FORECAST_EXTREME"

    return {
        "risk": round(risk, 2),
        "trigger": trigger,
        "current": {
            "temp": current.get("main", {}).get("temp", 25),
            "rain": current.get("rain", {}).get("1h", 0)
        },
        # useful for debugging/demo
        "meta": {
            "city": CITY
        }
    }