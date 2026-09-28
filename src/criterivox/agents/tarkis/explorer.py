from __future__ import annotations
from dataclasses import dataclass
from typing import Any
from criterivox.mechanisms.reasoning.models import AnalysisSession, ArtifactKind
from criterivox.mechanisms.reasoning.mechanisms import build_hypotheses, compare_hypotheses

@dataclass(frozen=True, slots=True)
class HypothesisExploration:
    session_id: str
    hypothesis_artifact_id: str
    candidates: tuple[dict[str, Any], ...]
    comparisons: tuple[dict[str, Any], ...]
    status: str
    evidence_status: str = "not_established"
    def to_dict(self) -> dict[str, Any]:
        return {"session_id":self.session_id,"hypothesis_artifact_id":self.hypothesis_artifact_id,"candidates":[dict(x) for x in self.candidates],"comparisons":[dict(x) for x in self.comparisons],"status":self.status,"evidence_status":self.evidence_status}

class TarkisExplorer:
    """Character-owned facade over shared S7 hypothesis mechanisms."""
    def explore(self, session: AnalysisSession, reasoning_artifact_id: str) -> HypothesisExploration:
        artifact=build_hypotheses(session, reasoning_artifact_id)
        candidates=tuple({"hypothesis": x, "status": "candidate_not_established"} for x in artifact.content.get("candidates",()))
        comparisons=tuple(compare_hypotheses(
            [a.content for a in session.artifacts if a.kind in {ArtifactKind.INPUT,ArtifactKind.EVALUATION}],
            [{"id": str(i+1), "statement": x} for i,x in enumerate(artifact.content.get("candidates",()))],
        ))
        return HypothesisExploration(session.session_id,artifact.artifact_id,candidates,tuple(comparisons),"bounded_exploration")

    def comparisons(self, session: AnalysisSession) -> tuple[dict[str, Any], ...]:
        return ()

    def branch_summary(self, session: AnalysisSession) -> dict[str, Any]:
        return {"truth_claim": "none", "branches": ()}
