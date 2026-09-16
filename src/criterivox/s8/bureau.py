"""Core portable S8 Evidence Research Bureau services."""
from __future__ import annotations

import hashlib
import json
from collections import defaultdict
from typing import Any, Mapping

from .models import Artifact, ArtifactKind, BureauEvent, VerificationResult, utc_now
from .interventions import InterventionRegistry
from .persistence import S8SQLiteStore
from .policy import AccessRequest, S8Policy


class EvidenceResearchBureau:
    """Deterministic artifact-first S8 coordinator.

    Characters only consume the artifacts/events produced here. The bureau keeps
    unknown, contradiction and uncertainty states explicit and never invents a
    universal confidence score.
    """

    CHARACTERS = {
        "medrus": "knowledge retention / temporal evidence",
        "epistre": "explanation / provenance / audit narrative",
        "veridat": "verification / grounding / contradiction inspection",
    }

    def __init__(self, *, store: S8SQLiteStore | None = None, policy: S8Policy | None = None) -> None:
        self.artifacts: dict[str, Artifact] = {}
        self.events: list[BureauEvent] = []
        self.store = store
        self.policy = policy or S8Policy()
        self.interventions = InterventionRegistry()
        self._sequence = 0

    def _id(self, prefix: str) -> str:
        self._sequence += 1
        return f"{prefix}-{self._sequence:06d}"

    def _record(self, event_type: str, artifact_ids: tuple[str, ...], **payload: Any) -> BureauEvent:
        event = BureauEvent(event_id=self._id("S8E"), event_type=event_type, artifact_ids=artifact_ids, actor=payload.pop("actor", "system"), tenant_id=payload.pop("tenant_id", None), context_id=payload.pop("context_id", None), payload=payload)
        self.events.append(event)
        if self.store:
            self.store.save_event(event)
        return event

    @staticmethod
    def _hash(payload: Mapping[str, Any]) -> str:
        raw = json.dumps(payload, sort_keys=True, default=str, separators=(",", ":")).encode()
        return hashlib.sha256(raw).hexdigest()

    def _authorized(self, artifact: Artifact, *, actor_id: str, operation: str, tenant_id: str | None, context_id: str | None, authorized: bool = False) -> None:
        self.policy.check(AccessRequest(actor_id, operation, tenant_id, context_id, artifact.tenant_id, artifact.context_id, authorized))

    def add_artifact(self, kind: ArtifactKind, payload: Mapping[str, Any], *, source_ids: tuple[str, ...] = (), parent_ids: tuple[str, ...] = (), tenant_id: str | None = None, context_id: str | None = None, status: str = "authoritative") -> Artifact:
        artifact_id = self._id("S8A")
        artifact = Artifact(artifact_id=artifact_id, kind=kind, payload=dict(payload), source_ids=source_ids, parent_ids=parent_ids, tenant_id=tenant_id, context_id=context_id, content_hash=self._hash(payload), status=status)
        self.artifacts[artifact_id] = artifact
        if self.store:
            self.store.save_artifact(artifact)
        self._record("ARTIFACT_CREATED", (artifact_id,), tenant_id=tenant_id, context_id=context_id, kind=kind.value)
        return artifact

    def verify_integrity(self, artifact_id: str, *, actor_id: str = "system", tenant_id: str | None = None, context_id: str | None = None) -> Artifact:
        artifact = self.artifacts[artifact_id]
        self._authorized(artifact, actor_id=actor_id, operation="inspect", tenant_id=tenant_id, context_id=context_id)
        expected = self._hash(artifact.payload)
        valid = expected == artifact.content_hash
        return self.add_artifact(ArtifactKind.INTEGRITY, {"subject_artifact_id": artifact_id, "expected_hash": expected, "recorded_hash": artifact.content_hash, "valid": valid, "method": "sha256-payload-integrity"}, source_ids=(artifact_id,), parent_ids=(artifact_id,), tenant_id=artifact.tenant_id, context_id=artifact.context_id, status="verified" if valid else "tampered")

    def verify_claim(self, claim: str, evidence_ids: tuple[str, ...], *, tenant_id: str | None = None, context_id: str | None = None) -> VerificationResult:
        evidence = [self.artifacts[eid] for eid in evidence_ids if eid in self.artifacts and self.artifacts[eid].tenant_id == tenant_id and self.artifacts[eid].context_id == context_id]
        missing = [eid for eid in evidence_ids if eid not in self.artifacts]
        contradictions = [a.artifact_id for a in evidence if a.kind is ArtifactKind.CONTRADICTION]
        if missing or not evidence:
            status = "insufficient_evidence"
            limitations = (f"Unknown evidence artifact(s): {', '.join(missing)}",) if missing else ("No evidence artifacts were supplied.",)
        elif contradictions:
            status = "contradictory"
            limitations = ("Supplied evidence includes an explicit contradiction artifact.",)
        else:
            status = "grounded_pending_validation"
            limitations = ()
        provenance = self.add_artifact(ArtifactKind.PROVENANCE, {"claim": claim, "evidence_ids": evidence_ids, "method": "artifact-reference-trace"}, source_ids=evidence_ids, tenant_id=tenant_id, context_id=context_id)
        result = VerificationResult(self._id("S8V"), claim, status, evidence_ids, limitations, tuple(contradictions), provenance.artifact_id)
        verification = self.add_artifact(ArtifactKind.VERIFICATION, {"verification_id": result.verification_id, "claim": claim, "status": status, "evidence_ids": evidence_ids, "limitations": limitations, "contradiction_ids": tuple(contradictions)}, source_ids=evidence_ids, parent_ids=(provenance.artifact_id,), tenant_id=tenant_id, context_id=context_id, status=status)
        self._record("VERIFICATION_COMPLETED", (verification.artifact_id, provenance.artifact_id), tenant_id=tenant_id, context_id=context_id, status=status)
        return result

    def add_contradiction(self, artifact_ids: tuple[str, ...], *, description: str, tenant_id: str | None = None, context_id: str | None = None) -> Artifact:
        return self.add_artifact(ArtifactKind.CONTRADICTION, {"artifact_ids": artifact_ids, "description": description, "resolution": "unresolved", "human_resolution_available": True}, source_ids=artifact_ids, tenant_id=tenant_id, context_id=context_id, status="unresolved")

    def add_uncertainty(self, affected_artifact_ids: tuple[str, ...], *, dimensions: Mapping[str, Any], reason: str, tenant_id: str | None = None, context_id: str | None = None) -> Artifact:
        return self.add_artifact(ArtifactKind.UNCERTAINTY, {"affected_artifact_ids": affected_artifact_ids, "dimensions": dict(dimensions), "reason": reason, "resolution_paths": []}, source_ids=affected_artifact_ids, tenant_id=tenant_id, context_id=context_id, status="unknown")

    def record_temporal_fact(self, subject: str, predicate: str, value: Any, *, valid_from=None, valid_to=None, recorded_at=None, source_ids: tuple[str, ...] = (), tenant_id: str | None = None, context_id: str | None = None) -> Artifact:
        return self.add_artifact(ArtifactKind.TEMPORAL, {"subject": subject, "predicate": predicate, "value": value, "valid_from": valid_from.isoformat() if valid_from else None, "valid_to": valid_to.isoformat() if valid_to else None, "recorded_at": (recorded_at or utc_now()).isoformat(), "bitemporal": True}, source_ids=source_ids, tenant_id=tenant_id, context_id=context_id)

    def invalidate(self, artifact_id: str, *, reason: str, affected_artifact_ids: tuple[str, ...] = ()) -> BureauEvent:
        artifact = self.artifacts[artifact_id]
        updated = Artifact(**{**artifact.__dict__, "status": "invalidated"})
        self.artifacts[artifact_id] = updated
        if self.store:
            self.store.save_artifact(updated)
        affected = (artifact_id,) + tuple(affected_artifact_ids)
        return self._record("ARTIFACT_INVALIDATED", affected, tenant_id=artifact.tenant_id, context_id=artifact.context_id, reason=reason)

    def explain(self, artifact_id: str, *, actor_id: str = "system", tenant_id: str | None = None, context_id: str | None = None) -> Artifact:
        artifact = self.artifacts[artifact_id]
        self._authorized(artifact, actor_id=actor_id, operation="inspect", tenant_id=tenant_id, context_id=context_id)
        payload = {"subject_artifact_id": artifact_id, "kind": artifact.kind.value, "sources": artifact.source_ids, "parents": artifact.parent_ids, "created_at": artifact.created_at.isoformat(), "status": artifact.status, "content_hash": artifact.content_hash, "limitations": artifact.payload.get("limitations", ()), "provenance_available": bool(artifact.parent_ids or artifact.source_ids)}
        explanation = self.add_artifact(ArtifactKind.EXPLANATION, payload, source_ids=(artifact_id,), parent_ids=artifact.parent_ids, tenant_id=artifact.tenant_id, context_id=artifact.context_id)
        self._record("EXPLANATION_AVAILABLE", (explanation.artifact_id,), tenant_id=artifact.tenant_id, context_id=artifact.context_id)
        return explanation

    def challenge(self, actor_id: str, target_artifact_ids: tuple[str, ...], *, evidence_ids: tuple[str, ...] = (), context: str = "", proposed_alternative: str = "", tenant_id: str | None = None, context_id: str | None = ()):
        targets = [self.artifacts[i] for i in target_artifact_ids if i in self.artifacts]
        if not targets:
            raise ValueError("A challenge target must identify an existing artifact.")
        intervention = self.interventions.create(actor_id, target_artifact_ids, evidence_ids=evidence_ids, context=context, proposed_alternative=proposed_alternative)
        self._record("HUMAN_CHALLENGE_RECORDED", target_artifact_ids, actor=actor_id, tenant_id=tenant_id, context_id=context_id, intervention_id=intervention.intervention_id)
        return intervention

    def authorize_challenge(self, intervention_id: str, *, actor_id: str) -> Any:
        intervention = self.interventions.authorize(intervention_id, actor_id=actor_id)
        self._record("HUMAN_INTERVENTION_AUTHORIZED", intervention.target_artifact_ids, actor=actor_id, intervention_id=intervention_id)
        return intervention

    def record_revision(self, intervention_id: str, original_ids: tuple[str, ...], revised_ids: tuple[str, ...], affected_ids: tuple[str, ...]) -> Any:
        revision = self.interventions.revise(intervention_id, original_ids, revised_ids, affected_ids)
        self._record("REVISED_STATE_RECORDED", original_ids + revised_ids, intervention_id=intervention_id, revision_id=revision.revision_id, affected_artifact_ids=affected_ids)
        return revision

    def snapshot(self) -> dict[str, Any]:
        return {"artifacts": len(self.artifacts), "events": len(self.events), "characters": dict(self.CHARACTERS), "generated_at": utc_now().isoformat()}
