from criterivox.agents.pramon import PramonPlanner
def test_pramon_builds_three_decision_options():
    options=PramonPlanner().build_options("Choose.",object())
    assert [x["id"] for x in options]==["strategy-rapid","strategy-balanced","strategy-rigor"]
    assert all(set(x["tradeoffs"]) == {"speed", "cost", "reliability"} for x in options)
    assert all(all(isinstance(value, str) for value in x["tradeoffs"].values()) for x in options)
def test_pramon_does_not_select_for_human():
    assert not any(x.get("selected") for x in PramonPlanner().build_options("Choose.",object()))
