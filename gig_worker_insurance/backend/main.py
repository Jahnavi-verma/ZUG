# pyre-ignore-all-errors
import sys
import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import razorpay
from dotenv import load_dotenv

# Load Environment Variables
load_dotenv()

# Setup Path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.ml.predict import predict_risk_ml
from backend.services.pricing_service import calculate_pricing
from backend.services.weather_service import weather_service
from backend.services.traffic_service import traffic_service
from backend.services.rto_service import rto_service

app = FastAPI()

# Razorpay Client Initialization
RAZORPAY_ID = os.getenv("RAZORPAY_KEY_ID", "rzp_test_SdHevaeLdpy7Ym")
RAZORPAY_SECRET = os.getenv("RAZORPAY_KEY_SECRET", "")

razorpay_client = razorpay.Client(auth=(RAZORPAY_ID, RAZORPAY_SECRET))

class OrderRequest(BaseModel):
    weekly_income: int
    bracket: str
    premium: int

class VerifyRequest(BaseModel):
    order_id: str
    payment_id: str
    signature: str

@app.get("/")
def root():
    return {"message": "ZUG AI backend running 🚀"}

@app.post("/predict-risk")
def predict_risk():
    print("API HIT: /predict-risk")
    try:
        weather = weather_service() or {}
        traffic = traffic_service() or {}
        rto = rto_service() or {}

        rain = weather.get("current", {}).get("rain", 0)
        temp = weather.get("current", {}).get("temp", 0)
        traffic_val = traffic.get("current", 0)
        rto_val = rto.get("today", 0)

        # Calling ML function directly (No "predict." prefix)
        try:
            ml_risk = predict_risk_ml(rain, temp, traffic_val, rto_val)
        except Exception as e:
            print(f"ML Prediction Error: {e}")
            ml_risk = 0.1

        rule_risk = 0
        if rain > 70: rule_risk += 0.3
        if temp > 45: rule_risk += 0.3
        if traffic_val > 0.8: rule_risk += 0.2
        if rto_val > 2: rule_risk += 0.2

        final_risk = min(1.0, round((ml_risk * 0.7 + rule_risk * 0.3), 2))
        pricing = calculate_pricing(final_risk, 5000)

        return {
            "risk_score": final_risk,
            "trigger": weather.get("trigger") or traffic.get("trigger") or rto.get("trigger"),
            "fraud": rto.get("fraud", False),
            "premium": pricing["premium"],
            "payout": pricing["payout"],
            "details": {"weather": weather, "traffic": traffic, "rto": rto}
        }
    except Exception as e:
        print(f"Predict Risk Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/create-order")
def create_order(data: OrderRequest):
    print(f"API HIT: /create-order for amount {data.premium}")
    if not RAZORPAY_SECRET:
        raise HTTPException(status_code=500, detail="RAZORPAY_KEY_SECRET is missing in backend/.env")
    try:
        amount = int(data.premium * 100)
        order = razorpay_client.order.create({
            "amount": amount,
            "currency": "INR",
            "payment_capture": 1
        })
        return {"order_id": order["id"], "amount_paise": amount}
    except Exception as e:
        print(f"Razorpay Order Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/verify-payment")
def verify_payment(data: VerifyRequest):
    try:
        razorpay_client.utility.verify_payment_signature({
            'razorpay_order_id': data.order_id,
            'razorpay_payment_id': data.payment_id,
            'razorpay_signature': data.signature
        })
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
