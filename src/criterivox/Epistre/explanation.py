from __future__ import annotations
from dataclasses import dataclass
from typing import Any
from criterivox.s8.bureau import EvidenceResearchBureau

@dataclass(frozen=True)
class ExplanationAssessment:
    explanation_id: str
    subject_artifact_id: str
    kind: str
    source_ids: tuple[str,...]
    parent_ids: tuple[str,...]
    status: str
    content_hash: str
    limitations: tuple[str,...]
    provenance_available: bool
    def to_dict(self): return self.__dict__.copy()

class EpistreExplainer:
    """Character-owned facade over S8's authoritative explanation/provenance path."""
    def __init__(self, bureau: EvidenceResearchBureau|None=None):
        self.bureau=bureau or EvidenceResearchBureau()

    def explain(self, artifact_id: str, *, actor_id="system", tenant_id=None, context_id=None) -> ExplanationAssessment:
        if not artifact_id: raise ValueError("artifact_id is required")
        artifact=self.bureau.explain(artifact_id,actor_id=actor_id,tenant_id=tenant_id,context_id=context_id)
        payload=artifact.payload
        return ExplanationAssessment(
            explanation_id=artifact.artifact_id,
            subject_artifact_id=str(payload.get("subject_artifact_id",artifact_id)),
            kind=str(payload.get("kind","")),
            source_ids=tuple(payload.get("sources",artifact.source_ids)),
            parent_ids=tuple(payload.get("parents",artifact.parent_ids)),
            status=str(payload.get("status",artifact.status)),
            content_hash=artifact.content_hash,
            limitations=tuple(payload.get("limitations",())),
            provenance_available=bool(payload.get("provenance_available",False)),
        )

    def trace(self, artifact_id: str, *, actor_id="system", tenant_id=None, context_id=None) -> dict[str,Any]:
        explanation=self.explain(artifact_id,actor_id=actor_id,tenant_id=tenant_id,context_id=context_id)
        return {"explanation_id":explanation.explanation_id,"subject_artifact_id":explanation.subject_artifact_id,"source_ids":explanation.source_ids,"parent_ids":explanation.parent_ids,"status":explanation.status,"provenance_available":explanation.provenance_available}
