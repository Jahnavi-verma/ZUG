import random

# MOCK (replace with TomTom later)

def fetch_current_traffic():
    return random.uniform(0.3, 0.95)

def fetch_future_traffic():
    return random.uniform(0.4, 0.85)


# LOGIC

def calculate_traffic_risk(future):
    if future > 0.6:
        return 0.2
    return 0


def check_traffic_trigger(current):
    if current > 0.85:
        return "TRAFFIC"
    return None


# FINAL SERVICE

def traffic_service():
    current = fetch_current_traffic()
    future = fetch_future_traffic()

    return {
        "risk": calculate_traffic_risk(future),
        "trigger": check_traffic_trigger(current),
        "current": current,
        "future": future
    }