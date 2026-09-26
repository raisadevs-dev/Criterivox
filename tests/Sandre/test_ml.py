from criterivox.Sandre.ml import SandreMLAgent


def test_sandre_train_and_predict() -> None:
    clean = [{"id": 1, "value": 10}, {"id": 2, "value": 11}]
    agent = SandreMLAgent()
    baseline = agent.train(clean)
    assert agent.is_trained
    assert baseline["fields"] == 2.0
    prediction = agent.predict(clean + [{"id": 2, "value": 11}])
    assert 0.0 <= prediction.anomaly_score <= 1.0
    assert "duplicate_candidates" in prediction.signals
