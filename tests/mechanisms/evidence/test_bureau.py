from criterivox.s8 import ArtifactKind, EvidenceResearchBureau


def test_verification_is_evidence_linked_and_explicitly_limited() -> None:
    bureau = EvidenceResearchBureau()
    evidence = bureau.add_artifact(
        ArtifactKind.EVIDENCE,
        {"claim": "sample", "source": "local-test"},
        source_ids=("source-1",),
    )

    result = bureau.verify_claim("sample", (evidence.artifact_id,))

    assert result.status == "grounded_pending_validation"
    assert result.evidence_ids == (evidence.artifact_id,)
    assert result.provenance_id is not None
    assert any(a.kind is ArtifactKind.VERIFICATION for a in bureau.artifacts.values())


def test_missing_evidence_does_not_become_success() -> None:
    bureau = EvidenceResearchBureau()
    result = bureau.verify_claim("unknown", ("missing",))

    assert result.status == "insufficient_evidence"
    assert result.limitations


def test_contradiction_remains_explicit() -> None:
    bureau = EvidenceResearchBureau()
    contradiction = bureau.add_artifact(
        ArtifactKind.CONTRADICTION,
        {"claim": "sample", "reason": "conflicting sources"},
    )
    result = bureau.verify_claim("sample", (contradiction.artifact_id,))

    assert result.status == "contradictory"
    assert result.contradiction_ids == (contradiction.artifact_id,)


def test_bitemporal_fact_and_explanation_are_inspectable() -> None:
    bureau = EvidenceResearchBureau()
    fact = bureau.record_temporal_fact("x", "status", "active")
    explanation = bureau.explain(fact.artifact_id)

    assert fact.kind is ArtifactKind.TEMPORAL
    assert fact.payload["bitemporal"] is True
    assert explanation.kind is ArtifactKind.EXPLANATION
    assert explanation.source_ids == (fact.artifact_id,)
