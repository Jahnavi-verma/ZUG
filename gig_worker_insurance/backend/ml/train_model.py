import pandas as pd
import pickle

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
from backend.services.weather_service import weather_service
# -------------------------
# LOAD DATA
# -------------------------
data = pd.read_csv("backend/data/risk_data.csv")

X = data[["rain", "temp", "traffic", "rto"]]
y = data["risk"]

# get live weather
weather = weather_service()

rain = weather["current"]["rain"]
temp = weather["current"]["temp"]

# simulate realistic combinations
new_row = {
    "rain": rain,
    "temp": temp,
    "traffic": 0.6,   # assume avg
    "rto": 3,
    "risk": min(1, (rain/80) + (temp/50) * 0.3)
}

data = pd.concat([data, pd.DataFrame([new_row])], ignore_index=True)

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
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# -------------------------
# MODEL
# -------------------------
model = RandomForestRegressor(
    n_estimators=100,
    max_depth=5,
    random_state=42
)

model.fit(X_train, y_train)

# -------------------------
# EVALUATION
# -------------------------
preds = model.predict(X_test)
mse = mean_squared_error(y_test, preds)

print("MSE:", mse)

# -------------------------
# FEATURE IMPORTANCE
# -------------------------
print("\nFeature Importance:")
for feature, imp in zip(["rain", "temp", "traffic", "rto"], model.feature_importances_):
    print(f"{feature}: {round(imp, 3)}")

# -------------------------
# SAVE MODEL
# -------------------------
with open("backend/ml/model.pkl", "wb") as f:
    pickle.dump((model, scaler), f)

print("\nRandom Forest model trained ✅")