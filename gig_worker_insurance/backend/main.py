# pyre-ignore-all-errors
from fastapi import FastAPI
from backend.services.weather_service import weather_service
from backend.services.traffic_service import traffic_service
from backend.services.rto_service import rto_service

from backend.utils.risk_engine import calculate_final_result

app = FastAPI()


@app.get("/")
def root():
    return {"message": "ZUG backend running 🚀"}


@app.post("/predict-risk")
def predict_risk():
    print("API HIT")
    weather = weather_service()
    print("Weather done ")
    traffic = traffic_service()
    print("Traffic done")
    rto = rto_service()
    print("RTO done")

    result = calculate_final_result(weather, traffic, rto)

    risk_score = result["risk_score"]
    premium = int(20 + result["risk_score"] * 30)
    coverage = premium * 20

    return {
        "risk_score": result["risk_score"],
        "premium": premium,
        "coverage": coverage,
        "trigger": result["trigger"],
        "fraud": rto["fraud"],
        "payout": rto["payout"],
        "details": {
            "weather": weather,
            "traffic": traffic,
            "rto": rto
        }
    }