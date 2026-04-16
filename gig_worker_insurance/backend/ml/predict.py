import os
import pickle
import pandas as pd


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "model.pkl")

with open(MODEL_PATH, "rb") as f:
    model,scaler= pickle.load(f)

def predict_risk_ml(rain, temp, traffic, rto):
    print("ML INPUT:", {
    "rain": rain,
    "temp": temp,
    "traffic": traffic,
    "rto": rto
})
    try:
        FEATURES = ["rain", "temp", "traffic", "rto"]
        features = pd.DataFrame([[rain, temp, traffic, rto]], columns=FEATURES)        
        return float(model.predict(features)[0])
    except Exception as e:
            print("ML prediction failed:", e)
            return 0