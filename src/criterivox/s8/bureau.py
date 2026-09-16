"""Core portable S8 Evidence Research Bureau services."""
from __future__ import annotations

import hashlib
import json
from collections import defaultdict
from datetime import datetime
from typing import Any, Mapping

from .models import Artifact, ArtifactKind, BureauEvent, VerificationResult, utc_now


class EvidenceResearchBureau:
    """In-process S8 coordinator with explicit artifact/event boundaries.

    The implementation is intentionally deterministic and dependency-light. It
    records what is known and what is not known rather than inventing a score or
    silently treating missing evidence as success.
    """

    CHARACTERS = {
        "medrus": "knowledge retention / temporal evidence",
        "epistre": "explanation / provenance / audit narrative",
        "veridat": "verification / grounding / contradiction inspection",
    }

    def __init__(self) -> None:
        self.artifacts: dict[str, Artifact] = {}
        self.events: list[BureauEvent] = []
        self._sequence = 0

    def _id(self, prefix: str) -> str:
        self._sequence += 1
        return f"{prefix}-{self._sequence:06d}"

    def _record(self, event_type: str, artifact_ids: tuple[str, ...], **payload: Any) -> BureauEvent:
        event = BureauEvent(
            event_id=self._id("S8E"),
            event_type=event_type,
            artifact_ids=artifact_ids,
            tenant_id=payload.pop("tenant_id", None),
            context_id=payload.pop("context_id", None),
            payload=payload,
        )
        self.events.append(event)
        return event

    @staticmethod
    def _hash(payload: Mapping[str, Any]) -> str:
        raw = json.dumps(payload, sort_keys=True, default=str, separators=(",", ":")).encode()
        return hashlib.sha256(raw).hexdigest()

    def add_artifact(
        self,
        kind: ArtifactKind,
        payload: Mapping[str, Any],
        *,
        source_ids: tuple[str, ...] = (),
        parent_ids: tuple[str, ...] = (),
        tenant_id: str | None = None,
        context_id: str | None = None,
    ) -> Artifact:
        artifact_id = self._id("S8A")
        artifact = Artifact(
            artifact_id=artifact_id,
            kind=kind,
            payload=dict(payload),
            source_ids=source_ids,
            parent_ids=parent_ids,
            tenant_id=tenant_id,
            context_id=context_id,
            content_hash=self._hash(payload),
        )
        self.artifacts[artifact_id] = artifact
        self._record("ARTIFACT_CREATED", (artifact_id,), tenant_id=tenant_id, context_id=context_id, kind=kind.value)
        return artifact

    def verify_claim(
        self,
        claim: str,
        evidence_ids: tuple[str, ...],
        *,
        tenant_id: str | None = None,
        context_id: str | None = None,
    ) -> VerificationResult:
        evidence = [self.artifacts[eid] for eid in evidence_ids if eid in self.artifacts]
        missing = [eid for eid in evidence_ids if eid not in self.artifacts]
        contradictions = []
        for artifact in evidence:
            if artifact.kind is ArtifactKind.CONTRADICTION:
                contradictions.append(artifact.artifact_id)
        if missing:
            status = "insufficient_evidence"
            limitations = (f"Unknown evidence artifact(s): {', '.join(missing)}",)
        elif contradictions:
            status = "contradictory"
            limitations = ("Supplied evidence includes an explicit contradiction artifact.",)
        elif not evidence:
            status = "insufficient_evidence"
            limitations = ("No evidence artifacts were supplied.",)
        else:
            status = "grounded_pending_validation"
            limitations = ()

        provenance = self.add_artifact(
            ArtifactKind.PROVENANCE,
            {"claim": claim, "evidence_ids": evidence_ids, "method": "artifact-reference-trace"},
            source_ids=evidence_ids,
            tenant_id=tenant_id,
            context_id=context_id,
        )
        result = VerificationResult(
            verification_id=self._id("S8V"),
            claim=claim,
            status=status,
            evidence_ids=evidence_ids,
            limitations=limitations,
            contradiction_ids=tuple(contradictions),
            provenance_id=provenance.artifact_id,
        )
        verification_artifact = self.add_artifact(
            ArtifactKind.VERIFICATION,
            {
                "verification_id": result.verification_id,
                "claim": claim,
                "status": status,
                "evidence_ids": evidence_ids,
                "limitations": limitations,
                "contradiction_ids": tuple(contradictions),
            },
            source_ids=evidence_ids,
            parent_ids=(provenance.artifact_id,),
            tenant_id=tenant_id,
            context_id=context_id,
        )
        self._record("VERIFICATION_COMPLETED", (verification_artifact.artifact_id, provenance.artifact_id), tenant_id=tenant_id, context_id=context_id, status=status)
        return result

    def record_temporal_fact(
        self,
        subject: str,
        predicate: str,
        value: Any,
        *,
        valid_from: datetime | None = None,
        valid_to: datetime | None = None,
        recorded_at: datetime | None = None,
        source_ids: tuple[str, ...] = (),
        tenant_id: str | None = None,
        context_id: str | None = None,
    ) -> Artifact:
        return self.add_artifact(
            ArtifactKind.TEMPORAL,
            {
                "subject": subject,
                "predicate": predicate,
                "value": value,
                "valid_from": valid_from.isoformat() if valid_from else None,
                "valid_to": valid_to.isoformat() if valid_to else None,
                "recorded_at": (recorded_at or utc_now()).isoformat(),
                "bitemporal": True,
            },
            source_ids=source_ids,
            tenant_id=tenant_id,
            context_id=context_id,
        )

    def explain(self, artifact_id: str) -> Artifact:
        artifact = self.artifacts[artifact_id]
        provenance = [self.artifacts[parent] for parent in artifact.parent_ids if parent in self.artifacts]
        payload = {
            "subject_artifact_id": artifact_id,
            "kind": artifact.kind.value,
            "sources": artifact.source_ids,
            "parents": artifact.parent_ids,
            "created_at": artifact.created_at.isoformat(),
            "status": artifact.status,
            "content_hash": artifact.content_hash,
            "limitations": artifact.payload.get("limitations", ()),
            "provenance_available": bool(provenance or artifact.source_ids),
        }
        explanation = self.add_artifact(
            ArtifactKind.EXPLANATION,
            payload,
            source_ids=(artifact_id,),
            parent_ids=artifact.parent_ids,
            tenant_id=artifact.tenant_id,
            context_id=artifact.context_id,
        )
        self._record("EXPLANATION_AVAILABLE", (explanation.artifact_id,), tenant_id=artifact.tenant_id, context_id=artifact.context_id)
        return explanation

    def snapshot(self) -> dict[str, Any]:
        return {
            "artifacts": len(self.artifacts),
            "events": len(self.events),
            "characters": dict(self.CHARACTERS),
            "generated_at": utc_now().isoformat(),
        }
