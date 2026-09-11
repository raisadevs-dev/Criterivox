from types import SimpleNamespace

from criterivox.application.s5_feature_runtime import S5FeatureRuntime


def foundation():
    return SimpleNamespace(
        profile=SimpleNamespace(missingness_rate=0.0, duplicate_rate=0.0, column_count=3),
        anomalies=[],
        sources=[SimpleNamespace(source_id="src-1")],
        candidates=[{"id": 1}],
        raw_data=[{"id": 1}],
        canonical_data=[{"id": 1, "value": 10}, {"id": 2, "value": 11}],
        transformations=[],
        confirmation_status=SimpleNamespace(value="user-confirmed"),
    )


def test_readiness_is_bounded_and_auditable():
    result = S5FeatureRuntime().readiness(foundation())
    assert 0 <= result.readiness <= 1
    assert result.decision in {"READY", "REVIEW"}


def test_provenance_has_sha256_payload_hash():
    result = S5FeatureRuntime().provenance(foundation())
    assert len(result["payload_hash"]) == 64
    assert result["timeline_supported"] is True


def test_synthetic_preview_is_local_and_seeded():
    result = S5FeatureRuntime().synthetic_preview(foundation(), seed=17)
    assert result["mode"] == "local-synthetic"
    assert result["training_consent"] is False
    assert result["rows"] == S5FeatureRuntime().synthetic_preview(foundation(), seed=17)["rows"]


def test_semantic_and_vector_surfaces_are_explicit():
    runtime = S5FeatureRuntime()
    semantic = runtime.semantic(foundation())
    vector = runtime.vector_readiness(foundation())
    assert semantic["active_metadata"] is True
    assert semantic["agent_readability_score"] > 0
    assert vector["stage"] == "embedding-ready-representation"
    assert vector["lakehouse"] == "deferred-by-S5-scope"


def test_edd_requires_confirmation():
    f = foundation()
    f.confirmation_status = SimpleNamespace(value="pending")
    result = S5FeatureRuntime().edd_gate(f)
    assert result["status"] == "REVIEW"
    assert result["checks"]["confirmation"] is False
