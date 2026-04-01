# pyre-ignore-all-errors
import requests
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("OPENWEATHER_API_KEY")
CITY = os.getenv("CITY")

RAIN_THRESHOLD = 70
HEAT_THRESHOLD = 50


# -------------------------
# API CALLS
# -------------------------

def fetch_current_weather():
    url = f"https://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={API_KEY}&units=metric"
    data = requests.get(url, timeout=5).json()
    print("CURRENT RAW:", data)   # debug
    return data


def fetch_forecast():
    url = f"https://api.openweathermap.org/data/2.5/forecast?q={CITY}&appid={API_KEY}&units=metric"
    data = requests.get(url, timeout=5).json()
    print("FORECAST RAW:", data)  # debug
    return data


# -------------------------
# PREDICTIVE LOGIC (FORECAST)
# -------------------------

def calculate_weather_risk(forecast_data):
    if "list" not in forecast_data:
        print("Forecast API failed:", forecast_data)
        return 0

    daily_rain = {}
    high_heat_days = 0

    for item in forecast_data["list"]:
        date = item["dt_txt"].split(" ")[0]

        temp = item.get("main", {}).get("temp", 0)
        rain = item.get("rain", {}).get("3h", 0)

        daily_rain[date] = daily_rain.get(date, 0) + rain

        if temp > HEAT_THRESHOLD:
            high_heat_days += 1

    high_rain_days = sum(1 for r in daily_rain.values() if r > RAIN_THRESHOLD)

    risk = 0
    if high_rain_days >= 2:
        risk += 0.3
    if high_heat_days >= 2:
        risk += 0.3

    return risk


# -------------------------
# REAL-TIME TRIGGER
# -------------------------

def check_weather_trigger(current_data):
    if "main" not in current_data:
        print("Current weather API failed:", current_data)
        return None

    temp = current_data.get("main", {}).get("temp", 0)
    rain = current_data.get("rain", {}).get("1h", 0)

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

    # fallback safety
    if "main" not in current:
        current = {"main": {"temp": 0}}

    if "list" not in forecast:
        forecast = {"list": []}

    return {
        "risk": calculate_weather_risk(forecast),
        "trigger": check_weather_trigger(current),
        "current": {
            "temp": current.get("main", {}).get("temp", 0),
            "rain": current.get("rain", {}).get("1h", 0)
        }
    }