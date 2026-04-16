# pyre-ignore-all-errors
import sys
import os

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

import razorpay
from dotenv import load_dotenv

# -------------------------
# LOAD ENV
# -------------------------
load_dotenv()

# -------------------------
# IMPORT YOUR MODULES
# -------------------------
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.ml.predict import predict_risk_ml
from backend.services.pricing_service import calculate_pricing
from backend.services.weather_service import weather_service
from backend.services.traffic_service import traffic_service
from backend.services.rto_service import rto_service

# -------------------------
# RAZORPAY CLIENT
# -------------------------
razorpay_client = razorpay.Client(auth=(
    os.getenv("RAZORPAY_KEY_ID"),
    os.getenv("RAZORPAY_KEY_SECRET")
))

# -------------------------
# FASTAPI INIT
# -------------------------
app = FastAPI()

# -------------------------
# REQUEST MODELS
# -------------------------
class OrderRequest(BaseModel):
    weekly_income: int
    bracket: str
    premium: int   # ✅ MUST COME FROM FRONTEND


class VerifyRequest(BaseModel):
    order_id: str
    payment_id: str
    signature: str


# -------------------------
# ROOT
# -------------------------
@app.get("/")
def root():
    return {"message": "ZUG AI backend running 🚀"}


# -------------------------
# RISK + PRICING API
# -------------------------
@app.post("/predict-risk")
def predict_risk():
    try:
        weather = weather_service()
    except:
        weather = {}

    try:
        traffic = traffic_service()
    except:
        traffic = {}

    try:
        rto = rto_service()
    except:
        rto = {}

    rain = (weather or {}).get("current", {}).get("rain", 0)
    temp = (weather or {}).get("current", {}).get("temp", 0)
    traffic_val = (traffic or {}).get("current", 0)
    rto_val = (rto or {}).get("today", 0)

    ml_risk = predict_risk_ml(rain, temp, traffic_val, rto_val)

    if ml_risk == 0:
        raise HTTPException(status_code=500, detail="ML prediction failed")

    # Rule-based adjustments
    rule_risk = 0
    if rain > 70: rule_risk += 0.3
    if temp > 45: rule_risk += 0.3
    if traffic_val > 0.8: rule_risk += 0.2
    if rto_val > 2: rule_risk += 0.2

    final_risk = round((ml_risk * 0.7 + rule_risk * 0.3), 2)
    final_risk = min(final_risk, 1.0)

    pricing = calculate_pricing(final_risk, 5000, "B")

    return {
        "risk_score": final_risk,
        "ml_risk": round(ml_risk, 2),
        "rule_risk": round(rule_risk, 2),
        "premium": pricing["premium"],
        "payout": pricing["payout"],
        "expected_loss": pricing["expected_loss"],
        "details": {
            "weather": weather,
            "traffic": traffic,
            "rto": rto
        }
    }


# -------------------------
# CREATE ORDER (FAST ⚡)
# -------------------------
@app.post("/create-order")
def create_order(data: OrderRequest):
    try:
        # ✅ USE FRONTEND PREMIUM (NO ML HERE)
        amount = int(data.premium * 100)

        order = razorpay_client.order.create({
            "amount": amount,
            "currency": "INR",
            "payment_capture": 1
        })

        return {
            "order_id": order["id"],
            "amount_paise": amount
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# -------------------------
# VERIFY PAYMENT
# -------------------------
@app.post("/verify-payment")
def verify_payment(data: VerifyRequest):
    try:
        razorpay_client.utility.verify_payment_signature({
            'razorpay_order_id': data.order_id,
            'razorpay_payment_id': data.payment_id,
            'razorpay_signature': data.signature
        })

        return {
            "status": "success",
            "order_id": data.order_id,
            "payment_id": data.payment_id
        }

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Verification failed: {str(e)}")


# -------------------------
# RUN SERVER
# -------------------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)