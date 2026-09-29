from __future__ import annotations
from dataclasses import dataclass
from typing import Any, Mapping
from criterivox.mechanisms.reasoning.models import AnalysisSession, ArtifactKind

@dataclass(frozen=True, slots=True)
class CriticalInspection:
    session_id: str
    findings: tuple[str, ...]
    assumptions: tuple[str, ...]
    evidence_refs: tuple[str, ...]
    contradictions: tuple[str, ...]
    decision_factors: tuple[str, ...]
    limitations: tuple[str, ...]
    provenance: tuple[Mapping[str, Any], ...]
    status: str
    def to_dict(self) -> dict[str, Any]:
        return {"session_id": self.session_id, "findings": list(self.findings), "assumptions": list(self.assumptions), "evidence_refs": list(self.evidence_refs), "contradictions": list(self.contradictions), "decision_factors": list(self.decision_factors), "limitations": list(self.limitations), "provenance": [dict(x) for x in self.provenance], "status": self.status, "public_boundary": "structured inspection summary; hidden chain-of-thought is never exposed"}

class VivrenInspector:
    def inspect(self, session: AnalysisSession) -> CriticalInspection:
        evaluations=[a for a in session.artifacts if a.kind==ArtifactKind.EVALUATION]
        reasoning=[a for a in session.artifacts if a.kind==ArtifactKind.REASONING]
        evidence=[a for a in session.artifacts if a.kind in {ArtifactKind.INPUT,ArtifactKind.EVALUATION,ArtifactKind.OBJECTION}]
        findings=[]; assumptions=[]; contradictions=[]; factors=[]; limitations=[]; provenance=[]
        for a in evaluations:
            findings.extend(str(x) for x in a.content.get("findings",()) if x)
            contradictions.extend(str(x) for x in a.content.get("contradictions",()) if x)
        for a in reasoning:
            assumptions.extend(str(x) for x in a.content.get("assumptions",()) if x)
            factors.extend(str(x) for x in a.content.get("decision_factors",()) if x)
        for a in session.artifacts:
            limitations.extend(str(x) for x in a.content.get("limitations",()) if x)
            if a in evidence or a in reasoning or a in evaluations:
                provenance.append({"artifact_id":a.artifact_id,"kind":a.kind.value,"parent_ids":list(a.parent_ids),"branch_id":a.branch_id})
        if not session.context: limitations.append("No structured context was supplied.")
        if not evidence: limitations.append("No explicit evidence artifact is available in the current session.")
        return CriticalInspection(session.session_id,tuple(dict.fromkeys(findings)),tuple(dict.fromkeys(assumptions)),tuple(a.artifact_id for a in evidence),tuple(dict.fromkeys(contradictions)),tuple(dict.fromkeys(factors)),tuple(dict.fromkeys(limitations)),tuple(provenance),"bounded_inspection")
