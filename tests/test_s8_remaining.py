from criterivox.s8.bureau import EvidenceResearchBureau
from criterivox.s8.models import ArtifactKind
from criterivox.s8.persistence import S8SQLiteStore
from criterivox.s8.policy import AuthorizationError


def test_sqlite_round_trip_and_context_filter():
    store = S8SQLiteStore()
    bureau = EvidenceResearchBureau(store=store)
    a = bureau.add_artifact(ArtifactKind.EVIDENCE, {"claim": "A"}, tenant_id="t1", context_id="c1")
    bureau.add_artifact(ArtifactKind.EVIDENCE, {"claim": "B"}, tenant_id="t2", context_id="c2")
    assert store.get_artifact(a.artifact_id).content_hash == a.content_hash
    assert [x.artifact_id for x in store.list_artifacts(tenant_id="t1", context_id="c1")] == [a.artifact_id]


def test_integrity_artifact_is_explicit():
    bureau = EvidenceResearchBureau()
    artifact = bureau.add_artifact(ArtifactKind.EVIDENCE, {"value": 1})
    integrity = bureau.verify_integrity(artifact.artifact_id)
    assert integrity.kind is ArtifactKind.INTEGRITY
    assert integrity.payload["valid"] is True


def test_contradiction_and_uncertainty_remain_explicit():
    bureau = EvidenceResearchBureau()
    a = bureau.add_artifact(ArtifactKind.EVIDENCE, {"claim": "A"})
    b = bureau.add_artifact(ArtifactKind.EVIDENCE, {"claim": "not A"})
    contradiction = bureau.add_contradiction((a.artifact_id, b.artifact_id), description="Competing claims")
    uncertainty = bureau.add_uncertainty((a.artifact_id,), dimensions={"source_quality": "unknown"}, reason="Source quality has not been established")
    result = bureau.verify_claim("A", (a.artifact_id, contradiction.artifact_id))
    assert result.status == "contradictory"
    assert contradiction.status == "unresolved"
    assert uncertainty.status == "unknown"


def test_cross_context_inspection_is_denied():
    bureau = EvidenceResearchBureau()
    a = bureau.add_artifact(ArtifactKind.EVIDENCE, {"x": 1}, tenant_id="t1", context_id="c1")
    try:
        bureau.explain(a.artifact_id, actor_id="human", tenant_id="t1", context_id="c2")
    except AuthorizationError:
        pass
    else:
        raise AssertionError("cross-context inspection must be denied")


def test_intervention_requires_explicit_authorization_for_revision():
    bureau = EvidenceResearchBureau()
    a = bureau.add_artifact(ArtifactKind.EVIDENCE, {"x": 1})
    intervention = bureau.challenge("human", (a.artifact_id,), proposed_alternative="x=2")
    try:
        bureau.record_revision(intervention.intervention_id, (a.artifact_id,), ("revised-1",), (a.artifact_id,))
    except PermissionError:
        pass
    else:
        raise AssertionError("revision must require authorization")
    bureau.authorize_challenge(intervention.intervention_id, actor_id="human")
    revision = bureau.record_revision(intervention.intervention_id, (a.artifact_id,), ("revised-1",), (a.artifact_id,))
    assert revision.preserved_original is True
