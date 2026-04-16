# pyre-ignore-all-errors
import sys
import os
from fastapi import FastAPI

# Ensure backend is importable
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.services.pricing_service import calculate_pricing
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
    # INPUT (TEMP)
    # -------------------------
    weekly_income = 5000  # replace later with real input

    # -------------------------
    # FETCH DATA (SAFE)
    # -------------------------
    try:
        weather = weather_service() or {}
    except:
        weather = {}

    try:
        traffic = traffic_service() or {}
    except:
        traffic = {}

    try:
        rto = rto_service() or {}
    except:
        rto = {}

    print("All services fetched")

    # -------------------------
    # FEATURE EXTRACTION (SAFE)
    # -------------------------
    rain = weather.get("current", {}).get("rain", 0)
    temp = weather.get("current", {}).get("temp", 0)
    traffic_val = traffic.get("current", 0)
    rto_val = rto.get("today", 0)

    # -------------------------
    # ML RISK
    # -------------------------
    ml_risk = predict.predict_risk_ml(rain, temp, traffic_val, rto_val)

    # -------------------------
    # RULE-BASED RISK
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
    # FINAL RISK
    # -------------------------
    final_risk = round((ml_risk * 0.7 + rule_risk * 0.3), 2)
    final_risk = min(final_risk, 1.0)

    # -------------------------
    # TRIGGER
    # -------------------------
    trigger = (
        weather.get("trigger")
        or traffic.get("trigger")
        or rto.get("trigger")
    )

    # -------------------------
    # PRICING
    # -------------------------
    pricing = calculate_pricing(final_risk, weekly_income)

    # -------------------------
    # CONFIDENCE
    # -------------------------
    confidence = round(1 - abs(ml_risk - rule_risk), 2)

    # -------------------------
    # FEATURE CONTRIBUTION
    # -------------------------
    feature_contribution = {
        "rain": round(rain / 100, 2),
        "temp": round(temp / 100, 2),
        "traffic": round(traffic_val, 2),
        "rto": round(rto_val / 5, 2)
    }

    # -------------------------
    # DETAILS
    # -------------------------
    details = {
        "weather": weather,
        "traffic": traffic,
        "rto": rto
    }

    # -------------------------
    # EXPLANATION (SAFE)
    # -------------------------
    explanation_parts = []

    if (traffic or {}).get("risk", 0) > 0:
        explanation_parts.append("traffic congestion")

    if (rto or {}).get("risk", 0) > 0:
        explanation_parts.append("RTO activity")

    if (weather or {}).get("risk", 0) > 0:
        explanation_parts.append("weather conditions")

    if not explanation_parts:
        explanation_text = "Low risk due to stable conditions"
    else:
        explanation_text = "Risk driven by " + ", ".join(explanation_parts)

    # -------------------------
    # FINAL RESPONSE
    # -------------------------
    return {
        "risk_score": final_risk,
        "ml_risk": round(ml_risk, 2),
        "rule_risk": round(rule_risk, 2),
        "confidence": confidence,

        "trigger": trigger,
        "fraud": rto.get("fraud"),

        "premium": pricing["premium"],
        "payout": pricing["payout"],
        "expected_loss": pricing["expected_loss"],

        "explainability": feature_contribution,
        "explanation": explanation_text,

        "details": details
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)