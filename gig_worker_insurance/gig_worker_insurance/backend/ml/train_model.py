import pandas as pd
from sklearn.linear_model import LinearRegression
import pickle

# load data
data = pd.read_csv("backend/data/risk_data.csv")

X = data[["rain", "temp", "traffic", "rto"]]
y = data["risk"]

# train model
model = LinearRegression()
model.fit(X, y)

# save model
with open("backend/ml/model.pkl", "wb") as f:
    pickle.dump(model, f)

print("Model trained ✅")