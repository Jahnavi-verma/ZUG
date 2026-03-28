# pyre-ignore-all-errors
import requests

API_KEY = "ef9d549f61b80416bc718692e00e94ec"
CITY = "Bangalore"

RAIN_THRESHOLD = 70
HEAT_THRESHOLD = 50

# -------------------------
# API CALLS
# -------------------------

def fetch_current_weather():
    url = f"https://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={API_KEY}&units=metric"
    return requests.get(url, timeout=5).json()


def fetch_forecast():
    url = f"https://api.openweathermap.org/data/2.5/forecast?q={CITY}&appid={API_KEY}&units=metric"
    return requests.get(url, timeout=5).json()


# -------------------------
# PREDICTIVE LOGIC (FORECAST)
# -------------------------

def calculate_weather_risk(forecast_data):
    daily_rain = {}
    high_heat_days = 0

    for item in forecast_data["list"]:
        date = item["dt_txt"].split(" ")[0]

        temp = item["main"]["temp"]
        rain = item.get("rain", {}).get("3h", 0)

        # accumulate rain per day
        daily_rain[date] = daily_rain.get(date, 0) + rain

        if temp > HEAT_THRESHOLD:
            high_heat_days += 1

    # count heavy rain days
    high_rain_days = sum(1 for rain in daily_rain.values() if rain > RAIN_THRESHOLD)

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
    temp = current_data["main"]["temp"]
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

    return {
        "risk": calculate_weather_risk(forecast),
        "trigger": check_weather_trigger(current),
        "current": {
            "temp": current["main"]["temp"],
            "rain": current.get("rain", {}).get("1h", 0)
        }
    }