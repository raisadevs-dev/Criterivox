from __future__ import annotations
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Mapping
from criterivox.mechanisms.evidence.bureau import EvidenceResearchBureau
from criterivox.runtime.characters.backbone.set4 import VerificationRecord

@dataclass(frozen=True)
class VerificationAssessment:
    verification_id: str
    claim: str
    status: str
    evidence_ids: tuple[str,...]
    contradiction_ids: tuple[str,...]
    limitations: tuple[str,...]
    provenance_id: str|None
    verification_method: str="artifact-reference-trace"
    def to_dict(self): return self.__dict__.copy()

class VeridatVerifier:
    """Character-owned verification facade over the authoritative evidence bureau."""
    def __init__(self, bureau: EvidenceResearchBureau|None=None, store=None):
        self.bureau=bureau or EvidenceResearchBureau()
        self.store=store

    def verify(self, claim: str, evidence_ids: tuple[str,...], *, tenant_id=None, context_id=None) -> VerificationAssessment:
        if not claim or not claim.strip(): raise ValueError("claim is required")
        result=self.bureau.verify_claim(claim.strip(),tuple(evidence_ids),tenant_id=tenant_id,context_id=context_id)
        return VerificationAssessment(result.verification_id,result.claim,result.status,result.evidence_ids,result.contradiction_ids,result.limitations,result.provenance_id)

    def record(self, *, verification_id: str, target_type: str, target_id: str,
               assessment: VerificationAssessment, verification_method: str|None=None,
               source_refs=(), checks=(), temporal_validity="UNKNOWN",
               integrity_status="UNKNOWN", verifier="veridat",
               uncertainty=(), limitations=()) -> str:
        if self.store is None: raise RuntimeError("A Set4 store is required to persist verification records")
        now=datetime.now(timezone.utc).isoformat()
        record=VerificationRecord(
            verification_id=verification_id,target_type=target_type,target_id=target_id,
            verification_method=verification_method or assessment.verification_method,
            source_refs=tuple(source_refs) or assessment.evidence_ids,
            checks=tuple(checks),contradictions=assessment.contradiction_ids,
            temporal_validity=temporal_validity,integrity_status=integrity_status,
            verifier=verifier,timestamp=now,result=assessment.status,
            uncertainty=tuple(uncertainty),limitations=tuple(limitations) or assessment.limitations,
            provenance={"bureau_verification_id":assessment.verification_id,"provenance_id":assessment.provenance_id})
        return self.store.record_verification(record)
