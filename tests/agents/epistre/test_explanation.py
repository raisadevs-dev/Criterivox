from criterivox.Epistre import EpistreExplainer
from criterivox.mechanisms.evidence.bureau import EvidenceResearchBureau
from criterivox.mechanisms.evidence.models import ArtifactKind

def test_epistre_explains_artifact_and_preserves_lineage():
    b=EvidenceResearchBureau()
    source=b.add_artifact(ArtifactKind.EVIDENCE,{"observation":"x"})
    derived=b.add_artifact(ArtifactKind.TRANSFORMATION,{"operation":"normalize"},source_ids=(source.artifact_id,))
    r=EpistreExplainer(b).explain(derived.artifact_id)
    assert r.subject_artifact_id==derived.artifact_id
    assert source.artifact_id in r.source_ids
    assert r.provenance_available is True

def test_epistre_trace_is_not_a_truth_claim():
    b=EvidenceResearchBureau()
    a=b.add_artifact(ArtifactKind.EVIDENCE,{"observation":"x"})
    r=EpistreExplainer(b).trace(a.artifact_id)
    assert r["subject_artifact_id"]==a.artifact_id
    assert "provenance_available" in r
