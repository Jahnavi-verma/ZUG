

import os
import pickle

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "model.pkl")

with open(MODEL_PATH, "rb") as f:
    model = pickle.load(f)

def predict_risk_ml(rain, temp, traffic, rto):
    try:
        features = [[rain, temp, traffic, rto]]
        return float(model.predict(features)[0])
    except Exception as e:
        print("ML prediction failed:", e)
        return 0