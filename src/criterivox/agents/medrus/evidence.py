from __future__ import annotations
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Mapping
from criterivox.mechanisms.evidence.bureau import EvidenceResearchBureau
from criterivox.mechanisms.evidence.models import ArtifactKind
from criterivox.runtime.characters.backbone.set4 import EvidenceRecord

@dataclass(frozen=True)
class EvidenceAssessment:
    evidence_id: str
    journey_id: str
    question: str
    source_reference: str
    source_type: str
    observation: str
    extracted_claims: tuple[str,...]=()
    interpretation: str|None=None
    temporal_scope: str|None=None
    uncertainty: tuple[str,...]=()
    limitations: tuple[str,...]=()
    def to_dict(self): return self.__dict__.copy()

@dataclass(frozen=True)
class ExperimentAssessment:
    experiment_id: str
    journey_id: str
    question: str
    hypothesis: str
    procedure: tuple[str,...]
    observations: tuple[str,...]
    outcome: str
    evidence_ids: tuple[str,...]
    limitations: tuple[str,...]=()
    status: str="RECORDED"
    def to_dict(self): return self.__dict__.copy()

class MedrusEvidence:
    """Character-owned facade for evidence acquisition and experimental records."""
    def __init__(self, bureau: EvidenceResearchBureau|None=None, store=None):
        self.bureau=bureau or EvidenceResearchBureau()
        self.store=store

    def collect(self, assessment: EvidenceAssessment, *, tenant_id=None, context_id=None):
        artifact=self.bureau.add_artifact(
            ArtifactKind.EVIDENCE,
            {"journey_id":assessment.journey_id,"question":assessment.question,"source_reference":assessment.source_reference,
             "source_type":assessment.source_type,"observation":assessment.observation,
             "extracted_claims":assessment.extracted_claims,"interpretation":assessment.interpretation,
             "temporal_scope":assessment.temporal_scope,"uncertainty":assessment.uncertainty,"limitations":assessment.limitations},
            tenant_id=tenant_id,context_id=context_id,status="raw")
        if artifact.artifact_id != assessment.evidence_id:
            evidence_id=artifact.artifact_id
        else: evidence_id=assessment.evidence_id
        if self.store:
            now=datetime.now(timezone.utc).isoformat()
            self.store.record_evidence(EvidenceRecord(
                evidence_id=evidence_id,journey_id=assessment.journey_id,task_id=None,question=assessment.question,
                source_reference=assessment.source_reference,source_type=assessment.source_type,observation=assessment.observation,
                extracted_claims=assessment.extracted_claims,interpretation=assessment.interpretation,collected_by="medrus",
                collection_method="s8-artifact-intake",timestamp=now,temporal_scope=assessment.temporal_scope,
                provenance={"artifact_id":artifact.artifact_id},verification_status="RAW",
                uncertainty=assessment.uncertainty,limitations=assessment.limitations))
        return artifact

    def experiment(self, assessment: ExperimentAssessment, *, tenant_id=None, context_id=None):
        if not assessment.hypothesis.strip(): raise ValueError("experiment hypothesis is required")
        if not assessment.procedure: raise ValueError("experiment procedure is required")
        artifact=self.bureau.add_artifact(
            ArtifactKind.EXPERIMENT,
            {"journey_id":assessment.journey_id,"question":assessment.question,"hypothesis":assessment.hypothesis,
             "procedure":assessment.procedure,"observations":assessment.observations,"outcome":assessment.outcome,
             "evidence_ids":assessment.evidence_ids,"limitations":assessment.limitations},
            tenant_id=tenant_id,context_id=context_id,status=assessment.status)
        return artifact

    def retrieve(self, subject: str, *, at=None, tenant_id=None, context_id=None):
        return self.bureau.retrieve_temporal(subject,at=at,tenant_id=tenant_id,context_id=context_id)

    def inspect(self, artifact_id: str):
        return self.bureau.artifacts[artifact_id]
