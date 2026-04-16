# backend/services/pricing_service.py

# -----------------------------
# CONFIG
# -----------------------------

BRACKETS = {
    "A": {
        "risk_multiplier": 0.8,
        "premium_range": (10, 20),
        "rep_income": 3000   # representative weekly income
    },
    "B": {
        "risk_multiplier": 1.0,
        "premium_range": (20, 30),
        "rep_income": 5000
    },
    "C": {
        "risk_multiplier": 1.2,
        "premium_range": (30, 40),
        "rep_income": 7000
    },
    "D": {
        "risk_multiplier": 1.5,
        "premium_range": (40, 50),
        "rep_income": 10000
    },
}

MAX_PAYOUT = 100
LOSS_RATIO_TARGET = 0.6
EVENT_PROBABILITY = 0.2

# -----------------------------
# HELPERS
# -----------------------------

def clamp_risk(risk):
    risk = max(0.0, min(risk, 1.0))
    return max(0.05, min(risk, 0.9))


def get_bracket(weekly_income):
    if weekly_income <= 4000:
        return "A"
    elif weekly_income <= 6000:
        return "B"
    elif weekly_income <= 8000:
        return "C"
    else:
        return "D"

#check

# -----------------------------
# MAIN FUNCTION
# -----------------------------

def calculate_pricing(risk, weekly_income):

    # -------------------------
    # Step 1: sanitize
    # -------------------------
    risk = clamp_risk(risk)
    weekly_income = max(0, weekly_income)

    # -------------------------
    # Step 2: bucket income
    # -------------------------
    bracket = get_bracket(weekly_income)
    config = BRACKETS[bracket]

    risk_multiplier = config["risk_multiplier"]
    min_p, max_p = config["premium_range"]
    rep_income = config["rep_income"]   # ✅ USE THIS, NOT raw income

    adjusted_risk = risk * risk_multiplier

    # -------------------------
    # Step 3: premium (banded)
    # -------------------------
    premium = min_p + (max_p - min_p) * (0.3*adjusted_risk)
    premium = round(premium, 2)

    # -------------------------
    # Step 4: payout (based on representative income)
    # -------------------------
    raw_payout = min(
        MAX_PAYOUT,
        0.5 * rep_income   # ✅ uses bucketed income
    )

    payout = min(
        raw_payout,
        2 * premium,
        (LOSS_RATIO_TARGET / max(adjusted_risk, 0.01)) * premium
    )

    payout = round(payout, 2)

    # -------------------------
    # Step 5: expected loss
    # -------------------------
    expected_loss = adjusted_risk * payout * EVENT_PROBABILITY

    loss_ratio = expected_loss / premium if premium > 0 else 0

    # -------------------------
    # Step 6: return
    # -------------------------
    return {
        "premium": premium,
        "payout": payout,
        "expected_loss": round(expected_loss, 2),

        # observability
        "risk": round(risk, 3),
        "adjusted_risk": round(adjusted_risk, 3),
        "bracket": bracket,
        "loss_ratio": round(loss_ratio, 2)
    }