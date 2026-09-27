from criterivox.Tarkis import TarkisExplorer
from criterivox.s7.models import AnalysisSession, ArtifactKind

def test_tarkis_explores_candidates_without_claiming_truth():
    s=AnalysisSession.create("Assess A because B or C",{"source":"test"})
    reasoning=s.artifact(ArtifactKind.REASONING,"Reasoning",{"claims":("Assess A",)})
    result=TarkisExplorer().explore(s,reasoning.artifact_id)
    assert result.candidates
    assert all(x["status"]=="candidate_not_established" for x in result.candidates)
    assert result.status=="bounded_exploration"

def test_tarkis_serializes_comparison():
    s=AnalysisSession.create("Assess A",{"source":"test"})
    reasoning=s.artifact(ArtifactKind.REASONING,"Reasoning",{})
    result=TarkisExplorer().explore(s,reasoning.artifact_id)
    assert result.to_dict()["hypothesis_artifact_id"]==result.hypothesis_artifact_id
