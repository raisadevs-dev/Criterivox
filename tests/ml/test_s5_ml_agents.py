from criterivox.ml.corruption import corrupt
from criterivox.ml.kaelen import KaelenMLAgent
from criterivox.ml.sandre import SandreMLAgent


def test_sandre_train_and_predict() -> None:
    clean = [{"id": 1, "value": 10}, {"id": 2, "value": 11}]
    agent = SandreMLAgent()
    baseline = agent.train(clean)
    assert agent.is_trained
    assert baseline["fields"] == 2.0
    prediction = agent.predict(clean + [{"id": 2, "value": 11}])
    assert 0.0 <= prediction.anomaly_score <= 1.0
    assert "duplicate_candidates" in prediction.signals


def test_synthetic_corruption_is_reproducible() -> None:
    rows = [{"id": 1, "value": 10}, {"id": 2, "value": 11}]
    first = corrupt(rows, "numeric_outlier", seed=42)
    second = corrupt(rows, "numeric_outlier", seed=42)
    assert first == second
    assert first.expected_action == "anomaly_review"


def test_kaelen_proposes_only_declared_operations() -> None:
    plan = KaelenMLAgent().propose({"id": "int", "name": "str"}, {"id": "str", "name": "str", "score": "float"})
    assert plan.action == "type_repair"
    KaelenMLAgent.validate_plan(plan)
    assert {operation["op"] for operation in plan.operations} == {"cast", "add_field"}
