# pyre-ignore-all-errors
import pandas as pd
from statistics import mode
def load_rto_data():
    try:
        df = pd.read_csv("backend/data/rto_data.csv")
        return df["rto"].tolist()
    except:
        return [1, 2, 2, 3, 2, 1]  # fallback
high_rto_streak = 0


def fetch_today_rto():
    return 3  # mock


def calculate_rto_risk(today, mode_rto):
    if today > mode_rto:
        return 0.25
    return 0


def check_rto_trigger(today):
    if today > 0:
        return "RTO"
    return None


def detect_fraud(today, mode_rto):
    global high_rto_streak

    if today > mode_rto:
        high_rto_streak += 1
    else:
        high_rto_streak = 0

    return high_rto_streak >= 3


def rto_service():
    past_rto_data = load_rto_data()   #from CSV

    today = fetch_today_rto()
    mode_rto = mode(past_rto_data) if past_rto_data else 0

    return {
        "risk": calculate_rto_risk(today, mode_rto),
        "trigger": check_rto_trigger(today),
        "fraud": detect_fraud(today, mode_rto),
        "payout": today * 5,
        "today": today,
        "mode": mode_rto
    }