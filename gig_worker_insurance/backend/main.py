# pyre-ignore-all-errors
from fastapi import FastAPI

from backend.services.weather_service import weather_service
from backend.services.traffic_service import traffic_service
from backend.services.rto_service import rto_service

import backend.ml.predict as predict
app = FastAPI()


@app.get("/")
def root():
    return {"message": "ZUG AI backend running 🚀"}


@app.post("/predict-risk")
def predict_risk():
    print("API HIT")

    # -------------------------
    # FETCH DATA
    # -------------------------
    weather = weather_service()
    traffic = traffic_service()
    rto = rto_service()

    print("All services fetched")

    # -------------------------
    # SAFE FEATURE EXTRACTION
    # -------------------------
    rain = weather.get("current", {}).get("rain", 0)
    temp = weather.get("current", {}).get("temp", 0)
    traffic_val = traffic.get("current", 0)
    rto_val = rto.get("today", 0)

    # -------------------------
    # ML PREDICTION
    # -------------------------
    ml_risk = predict.predict_risk_ml(rain, temp, traffic_val, rto_val)
    # -------------------------
    # RULE-BASED SUPPORT (HYBRID AI)
    # -------------------------
    rule_risk = 0

    if rain > 70:
        rule_risk += 0.3
    if temp > 45:
        rule_risk += 0.3
    if traffic_val > 0.8:
        rule_risk += 0.2
    if rto_val > 2:
        rule_risk += 0.2

    # -------------------------
    # FINAL HYBRID RISK
    # -------------------------
    final_risk = round((ml_risk * 0.7 + rule_risk * 0.3), 2)
    final_risk = min(final_risk, 1.0)

    # -------------------------
    # TRIGGER LOGIC
    # -------------------------
    trigger = (
        weather.get("trigger")
        or traffic.get("trigger")
        or rto.get("trigger")
    )

    # -------------------------
    # PRICING
    # -------------------------
    premium = int(20 + final_risk * 30)
    coverage = premium * 20

    # -------------------------
    # CONFIDENCE SCORE (VERY IMPRESSIVE)
    # -------------------------
    confidence = round(1 - abs(ml_risk - rule_risk), 2)

    # -------------------------
    # FEATURE IMPORTANCE (EXPLAINABILITY)
    # -------------------------
    feature_contribution = {
        "rain": round(rain / 100, 2),
        "temp": round(temp / 100, 2),
        "traffic": round(traffic_val, 2),
        "rto": round(rto_val / 5, 2)
    }

    return {
        "risk_score": final_risk,
        "ml_risk": round(ml_risk, 2),
        "rule_risk": round(rule_risk, 2),
        "confidence": confidence,

        "premium": premium,
        "coverage": coverage,

        "trigger": trigger,
        "fraud": rto.get("fraud"),
        "payout": rto.get("payout"),

        "explainability": feature_contribution,

        "details": {
            "weather": weather,
            "traffic": traffic,
            "rto": rto
        }
    }