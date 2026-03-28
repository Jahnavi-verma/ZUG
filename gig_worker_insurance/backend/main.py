from fastapi import FastAPI

app = FastAPI()

@app.post("/predict-risk")
def predict_risk(data: dict):

    rain = data.get("rain", 0)
    traffic = data.get("traffic", 0)
    rto = data.get("zone_rto_rate", 0)

    # simple logic (acts like ML for now)
    risk_score = (0.4 * rain) + (0.3 * traffic) + (0.3 * rto)

    premium = int(20 + (risk_score * 30))
    coverage = premium * 20

    return {
        "risk_score": round(risk_score, 2),
        "premium": premium,
        "coverage": coverage
    }