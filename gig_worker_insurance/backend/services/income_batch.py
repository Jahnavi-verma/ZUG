import pandas as pd
import os

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")

input_file = os.path.join(DATA_DIR, "gig_worker_weekly_income.csv")
percentile_file = os.path.join(DATA_DIR, "weekly_income_distribution.csv")
bracket_file = os.path.join(DATA_DIR, "worker_income_brackets.csv")

# Load data
df = pd.read_csv(input_file)

# Compute percentiles
percentiles = df.groupby("week_start")["weekly_income_inr"].quantile([0.25, 0.5, 0.75]).unstack()
percentiles.columns = ["p25", "p50", "p75"]
percentiles = percentiles.reset_index()

# Save percentile table
percentiles.to_csv(percentile_file, index=False)

# Merge
df = df.merge(percentiles, on="week_start")

# Assign brackets
def get_bracket(row):
    if row["weekly_income_inr"] <= row["p25"]:
        return "A"
    elif row["weekly_income_inr"] <= row["p50"]:
        return "B"
    elif row["weekly_income_inr"] <= row["p75"]:
        return "C"
    else:
        return "D"

df["income_bracket"] = df.apply(get_bracket, axis=1)

# Save result
df[["eshram_id", "week_start", "income_bracket"]].to_csv(bracket_file, index=False)

print("Batch job completed.")