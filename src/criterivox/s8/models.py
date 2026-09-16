"""Authoritative S8 artifacts and event contracts.

These models intentionally carry evidence and uncertainty explicitly. They do not
pretend that a presentation character is a computational owner.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Any, Mapping


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


class ArtifactKind(str, Enum):
    EVIDENCE = "evidence"
    VERIFICATION = "verification"
    PROVENANCE = "provenance"
    TEMPORAL = "temporal"
    CONTRADICTION = "contradiction"
    MEMORY = "memory"
    ATTRIBUTION = "attribution"
    AUDIT = "audit"
    UNCERTAINTY = "uncertainty"
    INTEGRITY = "integrity"
    EXPLANATION = "explanation"


@dataclass(frozen=True)
class Artifact:
    artifact_id: str
    kind: ArtifactKind
    payload: Mapping[str, Any]
    source_ids: tuple[str, ...] = ()
    parent_ids: tuple[str, ...] = ()
    created_at: datetime = field(default_factory=utc_now)
    tenant_id: str | None = None
    context_id: str | None = None
    content_hash: str | None = None
    status: str = "authoritative"


@dataclass(frozen=True)
class BureauEvent:
    event_id: str
    event_type: str
    artifact_ids: tuple[str, ...] = ()
    actor: str = "system"
    tenant_id: str | None = None
    context_id: str | None = None
    occurred_at: datetime = field(default_factory=utc_now)
    payload: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class VerificationResult:
    verification_id: str
    claim: str
    status: str
    evidence_ids: tuple[str, ...]
    limitations: tuple[str, ...] = ()
    contradiction_ids: tuple[str, ...] = ()
    provenance_id: str | None = None
    checked_at: datetime = field(default_factory=utc_now)
