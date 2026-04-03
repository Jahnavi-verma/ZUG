import pickle

# load model once
with open("backend/ml/model.pkl", "rb") as f:
    model = pickle.load(f)

def predict_risk_ml(rain, temp, traffic, rto):
    try:
        features = [[rain, temp, traffic, rto]]
        return float(model.predict(features)[0])
    except Exception as e:
        print("ML prediction failed:", e)
        return 0