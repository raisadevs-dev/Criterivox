from criterivox.s8 import ArtifactKind, EvidenceResearchBureau, HumanXAIEvaluation, S7Adapter


def test_human_xai_evaluation_records_protocol_dimensions_without_universal_score():
    evaluation = HumanXAIEvaluation()
    response = evaluation.record("participant-01", "S8A-1", "traceability", True, task_id="task-1", notes="Found source chain")
    assert response.dimension == "traceability"
    exported = evaluation.export()
    assert exported[0]["artifact_id"] == "S8A-1"
    assert "score" not in exported[0]


def test_s7_adapter_contract_round_trip_is_dependency_free():
    adapter = S7Adapter()
    envelope = adapter.export("s7-01", "context", {"claim": "sample"}, source_ids=("s7-source",), context_id="ctx-1")
    parsed = adapter.ingest(envelope)
    assert parsed.artifact_id == "s7-01"
    assert parsed.kind == "context"
    assert parsed.source_ids == ("s7-source",)
    assert parsed.context_id == "ctx-1"


def test_transformation_and_dependency_impact_are_explicit():
    bureau = EvidenceResearchBureau()
    source = bureau.add_artifact(ArtifactKind.EVIDENCE, {"value": 1}, tenant_id="t", context_id="c")
    transformed = bureau.record_transformation(
        (source.artifact_id,), operation="normalize", mechanism="deterministic-normalizer",
        tenant_id="t", context_id="c",
    )
    derived = bureau.add_artifact(
        ArtifactKind.VERIFICATION, {"claim": "normalized"}, source_ids=(transformed.artifact_id,),
        tenant_id="t", context_id="c",
    )
    impacted = bureau.downstream_impact((source.artifact_id,), tenant_id="t", context_id="c")
    assert transformed.artifact_id in impacted
    assert derived.artifact_id in impacted
