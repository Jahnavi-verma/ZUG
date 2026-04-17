import os
import pandas as pd
import pickle

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error

# -------------------------
# LOAD DATA
# -------------------------
# Ensure we load from the correct path relative to the project root
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(os.path.dirname(BASE_DIR), "data", "risk_data.csv")
data = pd.read_csv(DATA_PATH)

X = data[["rain", "temp", "traffic", "rto"]]
y = data["risk"]

# -------------------------
# TRAIN-TEST SPLIT
# -------------------------
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# -------------------------
# SCALING
# -------------------------
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# -------------------------
# MODEL
# -------------------------
model = RandomForestRegressor(
    n_estimators=100,
    max_depth=5,
    random_state=42
)

model.fit(X_train_scaled, y_train)

# -------------------------
# EVALUATION
# -------------------------
preds = model.predict(X_test_scaled)
mse = mean_squared_error(y_test, preds)

print("MSE:", mse)

# -------------------------
# SAVE MODEL
# -------------------------
# Save exactly as a (model, scaler) tuple
MODEL_SAVE_PATH = os.path.join(BASE_DIR, "model.pkl")
with open(MODEL_SAVE_PATH, "wb") as f:
    pickle.dump((model, scaler), f)

print(f"\nRandom Forest model trained and saved to {MODEL_SAVE_PATH} ✅")
