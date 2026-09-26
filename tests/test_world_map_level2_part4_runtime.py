from criterivox.world.level2_part4 import (
    INTELLIGENCE_ROOMS,
    DECISION_ROOMS,
    Part4Runtime,
    LIVE,
    SIMULATED,
    HISTORICAL,
)

def test_canonical_part4_registry():
    x = Part4Runtime()
    state = x.state()
    assert len(INTELLIGENCE_ROOMS) == 12
    assert len(DECISION_ROOMS) == 15
    assert state["homes"]["intelligence"]["resident"] == "Vivren"
    assert state["homes"]["decision"]["resident"] == "Pramon"
    assert state["integration"]["duplicate_engines"] == []


def test_reasoning_search_is_bounded_and_real():
    x = Part4Runtime()
    h = x.create_hypothesis("A candidate explanation", ["assumption"], ["e1"])
    result = x.search(h["hypothesis_id"], "DEEP", depth=20, budget=500)
    assert result["mode"] == "DEEP"
    assert result["depth"] == 12
    assert result["budget"] == 100
    assert result["truth"] == SIMULATED
    assert result["branches"]


def test_debate_audit_and_boundary_handoff():
    x = Part4Runtime()
    h = x.create_hypothesis("Claim", evidence_refs=["e1"])
    assert x.debate(h["hypothesis_id"], "unsupported premise")["status"] == "UNDER_REVIEW"
    assert x.audit(h["hypothesis_id"], [{"category": "ASSUMPTION", "detail": "missing"}])["status"] == "NEEDS_REVIEW"
    assert x.handoff(h["hypothesis_id"], "objective", ["e1"], [], "medium")["status"] == "VALIDATED"
    assert x.handoff("", "objective", [], [], "")["status"] == "REJECTED"


def test_counterfactual_reflexion_goal_and_formal():
    x = Part4Runtime()
    h = x.create_hypothesis("Claim")
    assert x.counterfactual(h["hypothesis_id"], {"x": 2})["truth"] == SIMULATED
    assert x.reflexion(h["hypothesis_id"], "failed branch", "revise assumption")["truth"] == HISTORICAL
    assert x.goal_alignment("buy a book", "buy a book today")["score"] > 0
    assert x.formalize("A implies B", [{"from": "A", "to": "B"}])["status"] == "STRUCTURED"


def test_decision_contract_risk_and_review():
    x = Part4Runtime()
    c = x.action_contract("act", "rationale", [], [], ["approved"], {}, {}, ["result"])
    assert x.blast_radius(c["contract_id"], "STATE_CHANGE")["state"] == "REVIEW"
    assert x.peer_review(c["contract_id"], "manis")["status"] == "APPROVED"
    assert x.peer_review(c["contract_id"], "manis", ["objection"])["status"] == "CHALLENGED"


def test_tradeoff_contingency_proof_and_archive():
    x = Part4Runtime()
    assert x.tradeoff([{"id": "a", "cost": 1}], ["cost"])["method"] == "DECLARED_METRICS"
    assert x.contingency("primary", [{"condition": "failure", "path": "fallback"}])["fallbacks"]
    assert x.proof("claim", ["e1"])["status"] == "SUFFICIENT"
    assert x.archive_decision({"decision_id": "d1"})["decision_id"] == "d1"


def test_resource_finops_tool_health_replay():
    x = Part4Runtime()
    r = x.resource_budget(20, 100, api_calls=2)
    assert r["remaining_budget"] == 80
    assert x.finops(12, 10, True)["throttle_required"] is True
    assert x.register_tool("tool-a", {}, "search", ["read"])["health"] == "HEALTHY"
    assert x.tool_health_update("tool-a", failures=3)["state"] == "ISOLATED"
    assert x.replay("cp-1", [{"type": "event"}])["rehydrated"] is True
