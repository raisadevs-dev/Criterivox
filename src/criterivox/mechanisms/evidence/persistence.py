"""Local SQLite persistence for S8 authoritative artifacts and events.

The store is deliberately small and portable. It persists the epistemic record,
not presentation state, and keeps JSON payloads inspectable.
"""
from __future__ import annotations

import json
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Any

from .models import Artifact, ArtifactKind, BureauEvent


class S8SQLiteStore:
    """Append-oriented local store for S8 artifacts/events."""

    def __init__(self, path: str | Path = ":memory:") -> None:
        self.path = str(path)
        self.connection = sqlite3.connect(self.path)
        self.connection.row_factory = sqlite3.Row
        self._create_schema()

    def _create_schema(self) -> None:
        self.connection.executescript(
            """
            CREATE TABLE IF NOT EXISTS artifacts (
                artifact_id TEXT PRIMARY KEY,
                kind TEXT NOT NULL,
                payload_json TEXT NOT NULL,
                source_ids_json TEXT NOT NULL,
                parent_ids_json TEXT NOT NULL,
                created_at TEXT NOT NULL,
                tenant_id TEXT,
                context_id TEXT,
                content_hash TEXT,
                status TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS events (
                event_id TEXT PRIMARY KEY,
                event_type TEXT NOT NULL,
                artifact_ids_json TEXT NOT NULL,
                actor TEXT NOT NULL,
                tenant_id TEXT,
                context_id TEXT,
                occurred_at TEXT NOT NULL,
                payload_json TEXT NOT NULL
            );
            CREATE INDEX IF NOT EXISTS idx_artifacts_context ON artifacts(context_id);
            CREATE INDEX IF NOT EXISTS idx_artifacts_tenant ON artifacts(tenant_id);
            CREATE INDEX IF NOT EXISTS idx_events_context ON events(context_id);
            """
        )
        self.connection.commit()

    def save_artifact(self, artifact: Artifact) -> None:
        self.connection.execute(
            """INSERT OR REPLACE INTO artifacts
            (artifact_id, kind, payload_json, source_ids_json, parent_ids_json,
             created_at, tenant_id, context_id, content_hash, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                artifact.artifact_id,
                artifact.kind.value,
                json.dumps(dict(artifact.payload), default=str, sort_keys=True),
                json.dumps(artifact.source_ids),
                json.dumps(artifact.parent_ids),
                artifact.created_at.isoformat(),
                artifact.tenant_id,
                artifact.context_id,
                artifact.content_hash,
                artifact.status,
            ),
        )
        self.connection.commit()

    def save_event(self, event: BureauEvent) -> None:
        self.connection.execute(
            """INSERT OR REPLACE INTO events
            (event_id, event_type, artifact_ids_json, actor, tenant_id,
             context_id, occurred_at, payload_json)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                event.event_id,
                event.event_type,
                json.dumps(event.artifact_ids),
                event.actor,
                event.tenant_id,
                event.context_id,
                event.occurred_at.isoformat(),
                json.dumps(dict(event.payload), default=str, sort_keys=True),
            ),
        )
        self.connection.commit()

    def get_artifact(self, artifact_id: str) -> Artifact | None:
        row = self.connection.execute(
            "SELECT * FROM artifacts WHERE artifact_id = ?", (artifact_id,)
        ).fetchone()
        if row is None:
            return None
        return Artifact(
            artifact_id=row["artifact_id"],
            kind=ArtifactKind(row["kind"]),
            payload=json.loads(row["payload_json"]),
            source_ids=tuple(json.loads(row["source_ids_json"])),
            parent_ids=tuple(json.loads(row["parent_ids_json"])),
            created_at=datetime.fromisoformat(row["created_at"]),
            tenant_id=row["tenant_id"],
            context_id=row["context_id"],
            content_hash=row["content_hash"],
            status=row["status"],
        )

    def list_artifacts(self, *, tenant_id: str | None = None, context_id: str | None = None) -> list[Artifact]:
        clauses: list[str] = []
        values: list[Any] = []
        if tenant_id is not None:
            clauses.append("tenant_id = ?")
            values.append(tenant_id)
        if context_id is not None:
            clauses.append("context_id = ?")
            values.append(context_id)
        where = f" WHERE {' AND '.join(clauses)}" if clauses else ""
        rows = self.connection.execute(f"SELECT artifact_id FROM artifacts{where} ORDER BY created_at", values).fetchall()
        return [a for row in rows if (a := self.get_artifact(row["artifact_id"])) is not None]

    def close(self) -> None:
        self.connection.close()
