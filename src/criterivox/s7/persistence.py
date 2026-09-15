from __future__ import annotations

import json
import sqlite3
from pathlib import Path
from typing import Any

from criterivox.s7.models import AnalysisSession, Artifact, S7Event


class S7SQLiteStore:
    """Offline-first append-preserving store for S7 analytical history."""

    def __init__(self, path: str | Path = "data/s7/reasoning_history.sqlite3") -> None:
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._db = sqlite3.connect(self.path)
        self._db.row_factory = sqlite3.Row
        self._db.executescript("""
        PRAGMA foreign_keys = ON;
        CREATE TABLE IF NOT EXISTS sessions (
          session_id TEXT PRIMARY KEY, task TEXT NOT NULL, context_json TEXT NOT NULL,
          status TEXT NOT NULL, branch_id TEXT NOT NULL, missing_json TEXT NOT NULL
        );
        CREATE TABLE IF NOT EXISTS artifacts (
          artifact_id TEXT PRIMARY KEY, session_id TEXT NOT NULL, kind TEXT NOT NULL,
          content TEXT NOT NULL, metadata_json TEXT NOT NULL, version INTEGER NOT NULL,
          branch_id TEXT NOT NULL, parent_artifact_id TEXT, created_at TEXT NOT NULL,
          FOREIGN KEY(session_id) REFERENCES sessions(session_id)
        );
        CREATE TABLE IF NOT EXISTS events (
          event_id TEXT PRIMARY KEY, session_id TEXT NOT NULL, event_type TEXT NOT NULL,
          payload_json TEXT NOT NULL, created_at TEXT NOT NULL,
          FOREIGN KEY(session_id) REFERENCES sessions(session_id)
        );
        CREATE INDEX IF NOT EXISTS idx_artifacts_session ON artifacts(session_id);
        CREATE INDEX IF NOT EXISTS idx_events_session ON events(session_id);
        """)
        self._db.commit()

    def save(self, session: AnalysisSession) -> None:
        self._db.execute(
            "INSERT OR IGNORE INTO sessions VALUES (?,?,?,?,?,?)",
            (session.session_id, session.task, json.dumps(session.context, sort_keys=True),
             session.status.value, session.branch_id, json.dumps(session.missing_information)),
        )
        self._db.execute(
            "UPDATE sessions SET status=?, branch_id=?, missing_json=? WHERE session_id=?",
            (session.status.value, session.branch_id, json.dumps(session.missing_information), session.session_id),
        )
        for artifact in session.artifacts:
            self._db.execute(
                "INSERT OR IGNORE INTO artifacts VALUES (?,?,?,?,?,?,?,?,?)",
                (artifact.artifact_id, session.session_id, artifact.kind.value, artifact.content,
                 json.dumps(artifact.metadata, sort_keys=True), artifact.version, artifact.branch_id,
                 artifact.parent_artifact_id, artifact.created_at),
            )
        for event in session.events:
            self._db.execute(
                "INSERT OR IGNORE INTO events VALUES (?,?,?,?,?)",
                (event.event_id, session.session_id, event.event_type,
                 json.dumps(event.payload, sort_keys=True), event.created_at),
            )
        self._db.commit()

    def close(self) -> None:
        self._db.close()
