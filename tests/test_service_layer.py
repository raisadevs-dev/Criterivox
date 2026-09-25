from criterivox.service_layer import ServiceRequest, ServiceComposer
from criterivox.service_layer.services import EvidenceDataService, AnalyticalService

def test_analysis_composition_runs_real_computation():
    req = ServiceRequest("REQ-1", "Analyze this dataset", supplied_data="x,y\n1,2\n3,4\n5,6")
    composer = ServiceComposer()
    plan, results = composer.execute(req)
    assert "analytical_reporting" in plan.services
    analysis = results["analytical_reporting"]
    assert analysis.status == "OK"
    assert analysis.structured_data["row_count"] == 3
    assert analysis.structured_data["numeric_summary"]["x"]["mean"] == 3.0
    assert results["verification_explanation"].artifact_refs

def test_insufficient_evidence_is_truthful():
    req = ServiceRequest("REQ-2", "Analyze this dataset")
    result = EvidenceDataService().execute(req)
    assert result.status == "INSUFFICIENT"
    assert "No user/system evidence" in result.content["reason"]

def test_strategy_composition_preserves_human_authority():
    req = ServiceRequest("REQ-3", "Help me choose a strategy for a project")
    plan, results = ServiceComposer().execute(req)
    assert "decision_support" in plan.services
    assert results["decision_support"].authorization_state == "human-decision-required"
    assert len(results["strategy_construction"].alternatives) >= 2

def test_simple_request_does_not_force_strategy():
    req = ServiceRequest("REQ-4", "What is the situation?")
    plan, _ = ServiceComposer().execute(req)
    assert "strategy_construction" not in plan.services
