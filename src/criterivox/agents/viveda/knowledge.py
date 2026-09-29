from __future__ import annotations
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Mapping
from criterivox.runtime.characters.backbone.set4 import KnowledgeRecord

@dataclass(frozen=True)
class KnowledgeAssessment:
    subject: str
    statement: str
    source_artifacts: tuple[str,...]
    evidence_refs: tuple[str,...]
    verification_refs: tuple[str,...]
    context_conditions: tuple[str,...]
    applicability: tuple[str,...]
    limitations: tuple[str,...]
    uncertainty: tuple[str,...]
    maturity: str
    def to_dict(self):
        return {"subject":self.subject,"statement":self.statement,"source_artifacts":list(self.source_artifacts),"evidence_refs":list(self.evidence_refs),"verification_refs":list(self.verification_refs),"context_conditions":list(self.context_conditions),"applicability":list(self.applicability),"limitations":list(self.limitations),"uncertainty":list(self.uncertainty),"maturity":self.maturity}

class VivedaKnowledge:
    """Character-owned facade for consolidating and persisting reusable knowledge."""
    VALID_MATURITY={"CANDIDATE","REVIEW_REQUIRED","VERIFIED","REUSABLE","DEPRECATED"}
    def __init__(self, store):
        self.store=store

    def assess(self, *, subject: str, statement: str, source_artifacts=(), evidence_refs=(),
               verification_refs=(), context_conditions=(), applicability=(),
               limitations=(), uncertainty=(), maturity="CANDIDATE") -> KnowledgeAssessment:
        if not subject.strip() or not statement.strip(): raise ValueError("subject and statement are required")
        if maturity not in self.VALID_MATURITY: raise ValueError("unsupported knowledge maturity")
        if maturity in {"VERIFIED","REUSABLE"} and not verification_refs:
            raise ValueError("verified/reusable knowledge requires verification references")
        if maturity=="REUSABLE" and not applicability:
            raise ValueError("reusable knowledge requires applicability conditions")
        return KnowledgeAssessment(subject.strip(),statement.strip(),tuple(source_artifacts),tuple(evidence_refs),tuple(verification_refs),tuple(context_conditions),tuple(applicability),tuple(limitations),tuple(uncertainty),maturity)

    def record(self, *, knowledge_id: str, journey_id: str, assessment: KnowledgeAssessment) -> str:
        stamp=datetime.now(timezone.utc).isoformat()
        record=KnowledgeRecord(
            knowledge_id=knowledge_id, journey_id=journey_id, subject=assessment.subject,
            statement=assessment.statement, source_artifacts=assessment.source_artifacts,
            evidence_refs=assessment.evidence_refs, verification_refs=assessment.verification_refs,
            context_conditions=assessment.context_conditions, applicability=assessment.applicability,
            limitations=assessment.limitations, uncertainty=assessment.uncertainty,
            maturity=assessment.maturity, created_at=stamp, updated_at=stamp,
            provenance={"source":"viveda-knowledge-facade"})
        return self.store.record_knowledge(record)
