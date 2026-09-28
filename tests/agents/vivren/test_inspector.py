from criterivox.agents.vivren import VivrenInspector
from criterivox.s7.models import AnalysisSession, ArtifactKind

def test_vivren_inspection_exposes_public_critical_fields():
    s=AnalysisSession.create("Assess the supplied claim.",{"source":"test"})
    r=s.artifact(ArtifactKind.REASONING,"Reasoning",{"assumptions":("The supplied context is relevant.",),"decision_factors":("source quality",)})
    s.artifact(ArtifactKind.EVALUATION,"Evaluation",{"findings":("The claim requires stronger evidence.",),"limitations":("External truth is unverified.",)},parents=(r.artifact_id,))
    report=VivrenInspector().inspect(s)
    assert report.findings==("The claim requires stronger evidence.",)
    assert report.assumptions==("The supplied context is relevant.",)
    assert report.evidence_refs
    assert "External truth is unverified." in report.limitations
    assert "hidden chain-of-thought" in report.to_dict()["public_boundary"]

def test_vivren_does_not_invent_missing_evidence():
    report=VivrenInspector().inspect(AnalysisSession.create("Assess this.",{"source":"test"}))
    assert report.evidence_refs==()
    assert any("No explicit evidence artifact" in x for x in report.limitations)
