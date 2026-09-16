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


def test_local_debate_arena_is_provisional_and_artifact_grounded():
    interpretation = DebateArena().interpret("I challenge this conclusion; show the evidence", artifact_ids=("S8A-1",))
    assert interpretation.operation == "challenge"
    assert interpretation.targets == ("S8A-1",)
    assert interpretation.uncertainty
