from criterivox.agents.tarkis import TarkisExplorer
from criterivox.mechanisms.reasoning.models import AnalysisSession, ArtifactKind

def test_tarkis_generates_bounded_candidates():
    s=AnalysisSession.create("What could explain the supplied result?",{"observation":"A or B"})
    r=s.artifact(ArtifactKind.REASONING,"Reasoning",{"claims":("A or B",)})
    result=TarkisExplorer().explore(s,r.artifact_id)
    assert result.candidates
    assert result.evidence_status=="not_established"
    assert result.status=="bounded_exploration"

def test_tarkis_exposes_comparison_and_branches_without_claiming_truth():
    s=AnalysisSession.create("Explore alternatives.",{"observation":"x"})
    r=s.artifact(ArtifactKind.REASONING,"Reasoning",{"claims":("x",)})
    TarkisExplorer().explore(s,r.artifact_id)
    assert TarkisExplorer().comparisons(s)==()
    assert TarkisExplorer().branch_summary(s)["truth_claim"]=="none"
