"""Canonical Level-2 Part V Evidence integration surface.

This module composes existing S8 Evidence Research Bureau capabilities into the
inspectable contracts required by Part V. It deliberately does not introduce a
second evidence, verification, temporal, provenance, memory, or security engine.
"""
from __future__ import annotations

from collections import Counter
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from math import log2
from typing import Any, Mapping

from .bureau import EvidenceResearchBureau
from .models import Artifact, ArtifactKind


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


@dataclass(frozen=True)
class EvidenceRequest:
    request_id: str
    claim: str
    purpose: str
    requested_by: str
    created_at: str


@dataclass(frozen=True)
class EvidenceHandoff:
    handoff_id: str
    handoff_type: str
    source_refs: tuple[str, ...]
    request_id: str | None
    claim: str
    purpose: str
    validated: bool
    verification_refs: tuple[str, ...]
    provenance_refs: tuple[str, ...]
    limitations: tuple[str, ...]
    assumptions: tuple[str, ...]
    uncertainty: str
    destination: str
    update_reason: str
    created_at: str

@dataclass(frozen=True)
class ProvenanceDossier:
    dossier_id: str
    claim: str
    evidence_ids: tuple[str, ...]
    provenance_ids: tuple[str, ...]
    verification_ids: tuple[str, ...]
    temporal_ids: tuple[str, ...]
    receipt_ids: tuple[str, ...]
    limitations: tuple[str, ...]
    created_at: str


class PartVEvidenceSurface:
    """Canonical adapter from S8 runtime artifacts to Part V rooms."""

    def __init__(self, bureau: EvidenceResearchBureau | None = None) -> None:
        self.bureau = bureau or EvidenceResearchBureau()
        self.requests: dict[str, EvidenceRequest] = {}
        self.transfers: list[dict[str, Any]] = []
        self.reconciliations: list[dict[str, Any]] = []

    def add_evidence(self, payload: Mapping[str, Any], *, tenant_id: str | None = None, context_id: str | None = None) -> Artifact:
        return self.bureau.add_artifact(ArtifactKind.EVIDENCE, payload, tenant_id=tenant_id, context_id=context_id)

    def request_evidence(self, claim: str, purpose: str, requested_by: str) -> EvidenceRequest:
        rid = f"S8R-{len(self.requests)+1:06d}"
        req = EvidenceRequest(rid, claim, purpose, requested_by, _now())
        self.requests[rid] = req
        self.bureau._record("EVIDENCE_REQUESTED", (), actor=requested_by, claim=claim, purpose=purpose, request_id=rid)
        return req

    def verify(self, claim: str, evidence_ids: tuple[str, ...], *, tenant_id=None, context_id=None) -> dict[str, Any]:
        result = self.bureau.verify_claim(claim, evidence_ids, tenant_id=tenant_id, context_id=context_id)
        return asdict(result)

    def reconcile(self, contradiction_id: str, resolution: str, *, actor: str, note: str = "") -> dict[str, Any]:
        artifact = self.bureau.artifacts[contradiction_id]
        if artifact.kind is not ArtifactKind.CONTRADICTION:
            raise ValueError("Reconciliation requires a contradiction artifact.")
        if resolution not in {"accept", "supersede", "quarantine", "unresolved"}:
            raise ValueError("resolution must be accept, supersede, quarantine, or unresolved")
        updated = Artifact(**{**artifact.__dict__, "status": resolution})
        updated_payload = dict(updated.payload)
        updated_payload["resolution"] = resolution
        updated_payload["resolved_by"] = actor
        updated_payload["resolution_note"] = note
        updated = Artifact(**{**updated.__dict__, "payload": updated_payload})
        self.bureau.artifacts[contradiction_id] = updated
        if self.bureau.store:
            self.bureau.store.save_artifact(updated)
        record = {"contradiction_id": contradiction_id, "resolution": resolution, "actor": actor, "note": note, "resolved_at": _now()}
        self.reconciliations.append(record)
        self.bureau._record("CONTRADICTION_RECONCILED", (contradiction_id,), actor=actor, resolution=resolution, note=note)
        return record

    def receipt(self, artifact_id: str, *, actor: str = "system", tenant_id=None, context_id=None) -> dict[str, Any]:
        artifact = self.bureau.artifacts[artifact_id]
        integrity = self.bureau.verify_integrity(artifact_id, actor_id=actor, tenant_id=tenant_id, context_id=context_id)
        return {
            "receipt_id": f"S8RC-{artifact_id}",
            "artifact_id": artifact_id,
            "source_ids": list(artifact.source_ids),
            "timestamp": artifact.created_at.isoformat(),
            "content_hash": artifact.content_hash,
            "integrity": "RECEIPT_VALID" if integrity.payload["valid"] else "INTEGRITY_MISMATCH",
            "transformation_ids": [a.artifact_id for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.TRANSFORMATION and artifact_id in a.source_ids],
        }

    def bitemporal(self, *, subject: str, tenant_id=None, context_id=None) -> list[dict[str, Any]]:
        return [
            {"artifact_id": a.artifact_id, "valid_from": a.payload.get("valid_from"), "valid_to": a.payload.get("valid_to"),
             "recorded_at": a.payload.get("recorded_at"), "status": a.status, "source_ids": list(a.source_ids)}
            for a in self.bureau.artifacts.values()
            if a.kind is ArtifactKind.TEMPORAL and a.payload.get("subject") == subject
            and a.tenant_id == tenant_id and a.context_id == context_id
        ]

    def retrieval(self, subject: str, *, mode: str = "deterministic_temporal", tenant_id=None, context_id=None) -> dict[str, Any]:
        allowed = {"deterministic_temporal", "probabilistic_similarity"}
        if mode not in allowed:
            raise ValueError(f"mode must be one of {sorted(allowed)}")
        artifacts = self.bureau.retrieve_temporal(subject, tenant_id=tenant_id, context_id=context_id) if mode == "deterministic_temporal" else [
            a for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.EVIDENCE and a.tenant_id == tenant_id and a.context_id == context_id and subject.lower() in str(a.payload).lower()
        ]
        return {"mode": mode, "badge": "DETERMINISTIC" if mode == "deterministic_temporal" else "PROBABILISTIC", "artifact_ids": [a.artifact_id for a in artifacts], "count": len(artifacts)}

    def dossier(self, claim: str, evidence_ids: tuple[str, ...], *, tenant_id=None, context_id=None) -> dict[str, Any]:
        provenance = [a.artifact_id for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.PROVENANCE and claim == a.payload.get("claim") and a.tenant_id == tenant_id and a.context_id == context_id]
        verification = [a.artifact_id for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.VERIFICATION and claim == a.payload.get("claim") and a.tenant_id == tenant_id and a.context_id == context_id]
        temporal = [a.artifact_id for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.TEMPORAL and a.tenant_id == tenant_id and a.context_id == context_id and any(e in a.source_ids for e in evidence_ids)]
        limitations = tuple(str(a.payload.get("limitations", "")) for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.VERIFICATION and claim == a.payload.get("claim") and a.payload.get("limitations"))
        receipt_ids = [f"S8RC-{eid}" for eid in evidence_ids]
        return asdict(ProvenanceDossier(f"S8PD-{len(provenance)+1:06d}", claim, evidence_ids, tuple(provenance), tuple(verification), tuple(temporal), tuple(receipt_ids), limitations, _now()))

    def memory_state(self, artifact_ids: tuple[str, ...], *, tenant_id=None, context_id=None) -> dict[str, Any]:
        ids = [a.artifact_id for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.MEMORY and a.tenant_id == tenant_id and a.context_id == context_id and set(a.source_ids) & set(artifact_ids)]
        return {"state": "COMPLETED" if ids else "IDLE", "memory_artifact_ids": ids, "input_artifact_ids": list(artifact_ids), "operations": ["duplicate_detection", "consolidation", "relevance_assessment", "stale_fragment_review"]}

    def security(self, *, actor_id: str, tenant_id=None, context_id=None) -> dict[str, Any]:
        artifacts = [a for a in self.bureau.artifacts.values() if a.tenant_id == tenant_id and a.context_id == context_id]
        return {"workspace": context_id, "tenant": tenant_id, "actor": actor_id, "retrieval_scope": "tenant+context", "visible_records": len(artifacts), "denied_records": sum(1 for a in self.bureau.artifacts.values() if a.tenant_id != tenant_id or a.context_id != context_id), "policy": "S8Policy"}

    def drift(self, values: list[str]) -> dict[str, Any]:
        counts = Counter(values)
        total = sum(counts.values())
        entropy = -sum((n/total) * log2(n/total) for n in counts.values()) if total else 0.0
        return {"metric": "semantic_entropy", "value": round(entropy, 6), "sample_count": total, "distinct_interpretations": len(counts), "status": "RESEARCH_PROTOTYPE", "method": "Shannon entropy over supplied interpretation labels"}

    def attribution(self, claim: str) -> dict[str, Any]:
        records = []
        for a in self.bureau.artifacts.values():
            if a.kind is ArtifactKind.EVIDENCE and (a.payload.get("claim") == claim or claim in str(a.payload.get("text", ""))):
                records.append({"artifact_id": a.artifact_id, "source": a.payload.get("source"), "document": a.payload.get("document"), "chunk": a.payload.get("chunk"), "line_start": a.payload.get("line_start"), "line_end": a.payload.get("line_end"), "verification": a.status})
        return {"claim": claim, "records": records, "granularity": "line_or_chunk_when_supplied"}

    def handoff(
        self,
        evidence_ids: tuple[str, ...],
        *,
        handoff_type: str,
        destination: str,
        claim: str = "",
        purpose: str = "",
        request_id: str | None = None,
        assumptions: list[str] | None = None,
        uncertainty: str = "",
        update_reason: str = "",
        tenant_id=None,
        context_id=None,
    ) -> dict[str, Any]:
        missing = [i for i in evidence_ids if i not in self.bureau.artifacts]
        if missing:
            raise ValueError(f"Unknown evidence artifact(s): {', '.join(missing)}")
        verification = [a for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.VERIFICATION and set(a.source_ids) & set(evidence_ids)]
        provenance = [a.artifact_id for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.PROVENANCE and set(a.source_ids) & set(evidence_ids)]
        limitations = [str(l) for a in verification for l in a.payload.get("limitations", ())]
        result = asdict(EvidenceHandoff(
            f"S8H-{len(self.transfers)+len(self.reconciliations)+1:06d}",
            handoff_type, evidence_ids, request_id, claim, purpose, bool(verification),
            tuple(a.artifact_id for a in verification), tuple(provenance), tuple(limitations),
            tuple(assumptions or []), uncertainty, destination, update_reason, _now()
        ))
        self.transfers.append(result)
        self.bureau._record("EVIDENCE_HANDOFF", evidence_ids, handoff_type=handoff_type, destination=destination, validated=result["validated"])
        return result

    def transfer(self, evidence_ids: tuple[str, ...], *, destination: str, reuse_conditions: list[str] | None = None, tenant_id=None, context_id=None) -> dict[str, Any]:
        missing = [i for i in evidence_ids if i not in self.bureau.artifacts]
        if missing:
            raise ValueError(f"Unknown evidence artifact(s): {', '.join(missing)}")
        verification = [a for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.VERIFICATION and set(a.source_ids) & set(evidence_ids)]
        package = {
            "transfer_id": f"S8T-{len(self.transfers)+1:06d}", "validated_finding": bool(verification),
            "evidence_refs": list(evidence_ids), "provenance": [a.artifact_id for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.PROVENANCE and set(a.source_ids) & set(evidence_ids)],
            "temporal_state": [a.artifact_id for a in self.bureau.artifacts.values() if a.kind is ArtifactKind.TEMPORAL and set(a.source_ids) & set(evidence_ids)],
            "verification_status": [a.status for a in verification], "known_limitations": [l for a in verification for l in a.payload.get("limitations", ())],
            "reuse_conditions": reuse_conditions or [], "destination": destination, "created_at": _now()
        }
        self.transfers.append(package)
        self.bureau._record("EVIDENCE_KNOWLEDGE_TRANSFERRED", tuple(evidence_ids), destination=destination)
        return package

    def overview(self, *, tenant_id=None, context_id=None) -> dict[str, Any]:
        counts = Counter(a.kind.value for a in self.bureau.artifacts.values() if a.tenant_id == tenant_id and a.context_id == context_id)
        return {"mode": "LIVE", "engine": "S8 Evidence Research Bureau", "artifact_counts": dict(counts), "event_count": len([e for e in self.bureau.events if e.tenant_id == tenant_id and e.context_id == context_id]), "capabilities": {
            "grounding_matrix": "LIVE", "provenance_workshop": "LIVE", "temporal_memory": "LIVE", "contradiction_reconciliation": "LIVE", "receipt_vault": "LIVE", "bitemporal": "LIVE", "retrieval_mode": "LIVE", "provenance_dossier": "LIVE", "memory_consolidation": "LIVE", "tenant_security": "LIVE", "semantic_entropy": "RESEARCH_PROTOTYPE", "line_attribution": "LIVE", "knowledge_transfer": "LIVE"
        }}

surface = PartVEvidenceSurface()
