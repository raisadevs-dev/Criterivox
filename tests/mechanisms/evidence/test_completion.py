from criterivox.s8 import ArtifactKind, DebateArena, EvidenceResearchBureau


def test_dependency_aware_revision_requires_authorization():
    bureau = EvidenceResearchBureau()
    a = bureau.add_artifact(ArtifactKind.EVIDENCE, {"v": 1}, tenant_id="t", context_id="c")
    intervention = bureau.challenge("human", (a.artifact_id,), tenant_id="t", context_id="c", proposed_alternative="v=2")
    try:
        bureau.record_revision(intervention.intervention_id, (a.artifact_id,), ("revised-1",), (a.artifact_id,))
    except PermissionError:
        pass
    else:
        raise AssertionError("unauthorized revision must be rejected")
    bureau.authorize_challenge(intervention.intervention_id, actor_id="human")
    revision = bureau.record_revision(intervention.intervention_id, (a.artifact_id,), ("revised-1",), (a.artifact_id,))
    assert revision.preserved_original


def test_authorized_reevaluation_records_only_dependency_affected_artifacts():
    bureau = EvidenceResearchBureau()
    source = bureau.add_artifact(ArtifactKind.EVIDENCE, {"v": 1}, tenant_id="t", context_id="c")
    derived = bureau.add_artifact(ArtifactKind.VERIFICATION, {"claim": "v"}, source_ids=(source.artifact_id,), tenant_id="t", context_id="c")
    unrelated = bureau.add_artifact(ArtifactKind.EVIDENCE, {"other": True}, tenant_id="t", context_id="c")
    intervention = bureau.challenge("human", (source.artifact_id,), tenant_id="t", context_id="c")
    bureau.authorize_challenge(intervention.intervention_id, actor_id="human")
    event = bureau.reevaluate(intervention.intervention_id, actor_id="human", tenant_id="t", context_id="c")
    assert derived.artifact_id in event.artifact_ids
    assert unrelated.artifact_id not in event.artifact_ids


def test_memory_consolidation_preserves_epistemic_metadata():
    bureau = EvidenceResearchBureau()
    a = bureau.add_artifact(ArtifactKind.EVIDENCE, {"v": 1}, tenant_id="t", context_id="c")
    memory = bureau.consolidate_memory((a.artifact_id,), tenant_id="t", context_id="c")
    assert memory.kind is ArtifactKind.MEMORY
    assert memory.payload["retains_provenance"]
    assert memory.payload["retains_temporal_history"]
    assert memory.payload["retains_verification"]
    assert memory.payload["retains_integrity"]
    assert memory.payload["retains_uncertainty"]


def test_local_debate_arena_is_provisional_and_artifact_grounded():
    interpretation = DebateArena().interpret("I challenge this conclusion; show the evidence", artifact_ids=("S8A-1",))
    assert interpretation.operation == "challenge"
    assert interpretation.targets == ("S8A-1",)
    assert interpretation.uncertainty
