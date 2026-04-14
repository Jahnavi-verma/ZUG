# backend/services/pricing_service.py

# -----------------------------
# CONFIG
# -----------------------------

BRACKETS = {
    "A": {"base_cost": 5, "risk_multiplier": 0.8},
    "B": {"base_cost": 8, "risk_multiplier": 1.0},
    "C": {"base_cost": 12, "risk_multiplier": 1.2},
    "D": {"base_cost": 15, "risk_multiplier": 1.5},
}

MAX_PAYOUT_BY_BRACKET = {
    "A": 50,
    "B": 80,
    "C": 100,
    "D": 120
}

MAX_PREMIUM = 50
TAX_RATE = 0.18
LOSS_RATIO_TARGET = 0.6   # <-- configurable profitability control


# -----------------------------
# HELPERS
# -----------------------------

def clamp_risk(risk):
    # prevent extreme behavior
    risk = max(0.0, min(risk, 1.0))
    return max(0.05, min(risk, 0.5))  # bounded risk


# -----------------------------
# MAIN FUNCTION
# -----------------------------

def calculate_pricing(risk, weekly_income, bracket):

    # -------------------------
    # Step 1: sanitize
    # -------------------------
    risk = clamp_risk(risk)
    weekly_income = max(0, weekly_income)

    config = BRACKETS.get(bracket, BRACKETS["B"])
    base_cost = config["base_cost"]
    risk_multiplier = config["risk_multiplier"]

    adjusted_risk = risk * risk_multiplier

    # -------------------------
    # Step 2: payout (tier + income blend)
    # -------------------------
    raw_payout = min(
        MAX_PAYOUT_BY_BRACKET.get(bracket, 80),
        0.3 * weekly_income   # keeps some realism
    )

    # -------------------------
    # Step 3: initial premium
    # -------------------------
    expected_loss = adjusted_risk * raw_payout
    premium = base_cost + expected_loss

    # -------------------------
    # Step 4: cap premium
    # -------------------------
    premium = min(premium, MAX_PREMIUM)
    is_capped = premium >= MAX_PREMIUM

    # -------------------------
    # Step 5: enforce constraints
    # -------------------------
    if adjusted_risk > 0:
        payout = min(
            raw_payout,
            2 * premium,
            (LOSS_RATIO_TARGET / adjusted_risk) * premium
        )
    else:
        payout = min(raw_payout, 2 * premium)

    # -------------------------
    # Step 6: recompute expected loss
    # -------------------------
    expected_loss = adjusted_risk * payout

    # -------------------------
    # Step 7: apply tax
    # -------------------------
    premium_with_tax = premium * (1 + TAX_RATE)
    premium_with_tax = min(premium_with_tax, MAX_PREMIUM)

    # -------------------------
    # Step 8: debug / audit info
    # -------------------------
    loss_ratio = expected_loss / premium if premium > 0 else 0

    # -------------------------
    # Step 9: return
    # -------------------------
    return {
        "premium": round(premium_with_tax, 2),
        "payout": round(payout, 2),
        "expected_loss": round(expected_loss, 2),

        # --- observability ---
        "risk": round(risk, 3),
        "adjusted_risk": round(adjusted_risk, 3),
        "bracket": bracket,
        "is_capped": is_capped,
        "loss_ratio": round(loss_ratio, 2)
    }