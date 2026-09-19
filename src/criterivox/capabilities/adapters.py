from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from typing import Any, Mapping

from criterivox.s8.models import Artifact, ArtifactKind, BureauEvent
from criterivox.s8.persistence import S8SQLiteStore


class S8ArtifactRepository:
    """S9 repository adapter over the existing S8 artifact/event persistence.

    This is an adapter, not a second database. S8 SQLite/IndexedDB remain the
    persistence boundary established by the earlier sprints.
    """
    def __init__(self, store: S8SQLiteStore):
        self.store = store

    def save_artifact(self, artifact: Artifact) -> None:
        self.store.save_artifact(artifact)

    def get_artifact(self, artifact_id: str) -> Artifact | None:
        return self.store.get_artifact(artifact_id)

    def save_event(self, event: BureauEvent) -> None:
        self.store.save_event(event)

    def list_artifacts(self, *, tenant_id: str | None = None, context_id: str | None = None) -> list[Artifact]:
        return self.store.list_artifacts(tenant_id=tenant_id, context_id=context_id)


def artifact_hash(payload: Mapping[str, Any]) -> str:
    canonical = json.dumps(dict(payload), sort_keys=True, separators=(",", ":"), default=str).encode()
    return hashlib.sha256(canonical).hexdigest()


def make_audit_artifact(*, artifact_id: str, payload: Mapping[str, Any], parent_ids: tuple[str, ...] = (), context_id: str | None = None, tenant_id: str | None = None) -> Artifact:
    now = datetime.now(timezone.utc)
    return Artifact(
        artifact_id=artifact_id,
        kind=ArtifactKind.AUDIT,
        payload=dict(payload),
        source_ids=parent_ids,
        parent_ids=parent_ids,
        created_at=now,
        tenant_id=tenant_id,
        context_id=context_id,
        content_hash=artifact_hash(payload),
        status="authoritative",
    )


def verify_artifact_integrity(artifact: Artifact) -> bool:
    return artifact.content_hash == artifact_hash(artifact.payload)


__all__ = ["S8ArtifactRepository", "artifact_hash", "make_audit_artifact", "verify_artifact_integrity"]
