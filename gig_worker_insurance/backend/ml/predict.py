import os
import pickle
import pandas as pd
import numpy as np

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "model.pkl")

# Load model and scaler
with open(MODEL_PATH, "rb") as f:
    data = pickle.load(f)
    if isinstance(data, tuple):
        model, scaler = data
    else:
        # Fallback if only model was saved
        model = data
        scaler = None

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

        # Scale features if scaler exists
        if scaler is not None:
            features_scaled = scaler.transform(features)
        else:
            features_scaled = features

        prediction = model.predict(features_scaled)[0]
        return float(prediction)
    except Exception as e:
        print("ML prediction failed:", e)
        return 0.05 # Default safety fallback
