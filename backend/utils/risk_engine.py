def calculate_final_result(weather, traffic, rto):

    risk = 0
    trigger = None

    # -------------------------
    # ADD RISKS
    # -------------------------
    risk += weather["risk"]
    risk += traffic["risk"]
    risk += rto["risk"]

    # -------------------------
    # TRIGGER PRIORITY
    # -------------------------
    trigger = (
        weather["trigger"]
        or traffic["trigger"]
        or rto["trigger"]
    )

    # cap risk
    risk = min(risk, 1.0)

    return {
        "risk_score": round(risk, 2),
        "trigger": trigger
    }