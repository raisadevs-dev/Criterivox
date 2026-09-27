from criterivox.Veridat import VeridatVerifier
from criterivox.s8.bureau import EvidenceResearchBureau
from criterivox.s8.models import ArtifactKind

def test_veridat_reports_insufficient_evidence():
    v=VeridatVerifier(EvidenceResearchBureau())
    r=v.verify("Claim",("missing",))
    assert r.status=="insufficient_evidence"

def test_veridat_detects_contradiction():
    b=EvidenceResearchBureau()
    e=b.add_artifact(ArtifactKind.EVIDENCE,{"observation":"support"})
    b.add_contradiction((e.artifact_id,),description="Conflict")
    c=[a.artifact_id for a in b.artifacts.values() if a.kind is ArtifactKind.CONTRADICTION]
    r=VeridatVerifier(b).verify("Claim",tuple([e.artifact_id,c[0]]))
    assert r.status=="contradictory"
    assert c[0] in r.contradiction_ids

def test_veridat_keeps_pending_validation_distinct():
    b=EvidenceResearchBureau()
    e=b.add_artifact(ArtifactKind.EVIDENCE,{"observation":"support"})
    r=VeridatVerifier(b).verify("Claim",(e.artifact_id,))
    assert r.status=="grounded_pending_validation"
