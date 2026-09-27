from criterivox.s7.orchestrator import ReasoningResearchBureau
from criterivox.s7.models import ArtifactKind, SessionStatus


def test_complete_cycle_produces_real_artifacts_and_events():
    bureau = ReasoningResearchBureau()
    session = bureau.start("Compare two possible explanations because the evidence is incomplete.", {"source": "local-test"})
    assert session.status is SessionStatus.COMPLETED
    kinds = {artifact.kind for artifact in session.artifacts}
    assert {ArtifactKind.CAPABILITY_PLAN, ArtifactKind.REASONING, ArtifactKind.HYPOTHESIS, ArtifactKind.EVALUATION, ArtifactKind.RESULT} <= kinds
    assert any(event.event_type == "ANALYSIS_COMPLETED" for event in session.events)


def test_insufficient_information_stops_analysis_honestly():
    bureau = ReasoningResearchBureau()
    session = bureau.start("Assess this claim.", {})
    assert session.status is SessionStatus.WAITING_FOR_INFORMATION
    assert "structured context" in session.missing_information
    assert not any(a.kind is ArtifactKind.RESULT for a in session.artifacts)


def test_human_challenge_creates_a_new_branch_and_event():
    bureau = ReasoningResearchBureau()
    session = bureau.start("Evaluate the supplied claim.", {"source": "local-test"})
    target = next(a for a in session.artifacts if a.kind is ArtifactKind.REASONING)
    updated = bureau.challenge(session.session_id, target.artifact_id, "The supplied context does not support that conclusion.")
    assert updated.branch_id != "main"
    assert any(a.kind is ArtifactKind.HUMAN_INTERVENTION for a in updated.artifacts)
    assert any(e.event_type == "HUMAN_CHALLENGE" for e in updated.events)
