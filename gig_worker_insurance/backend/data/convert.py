import pandas as pd
import json

df = pd.read_csv("gig_worker_weekly_income.csv")  # 👈 put your csv name here

data = df.to_dict(orient="records")

with open("mock_users.dart", "w") as f:
    f.write("final List<Map<String, dynamic>> mockUsers = ")
    f.write(json.dumps(data, indent=2))
    f.write(";")