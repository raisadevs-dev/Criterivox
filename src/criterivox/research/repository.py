from __future__ import annotations

import json
import sqlite3
import threading
from pathlib import Path
from typing import Any

from .models import ResearchConsent, ResearchEvent, ResearchSession


class ResearchRepository:
    """SQLite-backed research evidence store.

    The interface is intentionally storage-agnostic so production deployment
    can replace SQLite with PostgreSQL without changing the research event API.
    """

    def __init__(self, path: str | Path = "data/research/criterivox_research.sqlite3") -> None:
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._lock = threading.RLock()
        self._initialize()

    def _connect(self) -> sqlite3.Connection:
        connection = sqlite3.connect(self.path, timeout=30)
        connection.row_factory = sqlite3.Row
        connection.execute("PRAGMA foreign_keys = ON")
        connection.execute("PRAGMA journal_mode = WAL")
        return connection

    def _initialize(self) -> None:
        with self._lock, self._connect() as db:
            db.executescript(
                """
                CREATE TABLE IF NOT EXISTS participants (
                    participant_id TEXT PRIMARY KEY,
                    created_at TEXT NOT NULL,
                    metadata_json TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS consents (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    participant_id TEXT NOT NULL,
                    consent_version TEXT NOT NULL,
                    usage_analytics INTEGER NOT NULL DEFAULT 0,
                    interaction_research INTEGER NOT NULL DEFAULT 0,
                    feedback_research INTEGER NOT NULL DEFAULT 0,
                    follow_up_contact INTEGER NOT NULL DEFAULT 0,
                    recorded_interview INTEGER NOT NULL DEFAULT 0,
                    recorded_at TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS sessions (
                    session_id TEXT PRIMARY KEY,
                    participant_id TEXT NOT NULL,
                    study_id TEXT,
                    app_version TEXT,
                    started_at TEXT NOT NULL,
                    metadata_json TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS events (
                    event_id TEXT PRIMARY KEY,
                    session_id TEXT NOT NULL,
                    participant_id TEXT NOT NULL,
                    event_type TEXT NOT NULL,
                    purpose TEXT NOT NULL,
                    timestamp TEXT NOT NULL,
                    workflow_stage TEXT,
                    payload_json TEXT NOT NULL
                );

                CREATE INDEX IF NOT EXISTS idx_events_session ON events(session_id);
                CREATE INDEX IF NOT EXISTS idx_events_participant ON events(participant_id);
                CREATE INDEX IF NOT EXISTS idx_events_type ON events(event_type);
                CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp);
                """
            )

    def upsert_participant(self, participant_id: str, created_at: str, metadata: dict[str, Any] | None = None) -> None:
        with self._lock, self._connect() as db:
            db.execute(
                "INSERT OR IGNORE INTO participants(participant_id, created_at, metadata_json) VALUES(?,?,?)",
                (participant_id, created_at, json.dumps(metadata or {}, sort_keys=True, default=str)),
            )

    def record_consent(self, consent: ResearchConsent) -> None:
        with self._lock, self._connect() as db:
            db.execute(
                """INSERT INTO consents(
                    participant_id, consent_version, usage_analytics,
                    interaction_research, feedback_research, follow_up_contact,
                    recorded_interview, recorded_at
                ) VALUES(?,?,?,?,?,?,?,?)""",
                (
                    consent.participant_id, consent.consent_version,
                    int(consent.usage_analytics), int(consent.interaction_research),
                    int(consent.feedback_research), int(consent.follow_up_contact),
                    int(consent.recorded_interview), consent.recorded_at,
                ),
            )

    def latest_consent(self, participant_id: str) -> ResearchConsent | None:
        with self._lock, self._connect() as db:
            row = db.execute(
                "SELECT * FROM consents WHERE participant_id=? ORDER BY id DESC LIMIT 1",
                (participant_id,),
            ).fetchone()
        if row is None:
            return None
        return ResearchConsent(
            participant_id=row["participant_id"],
            consent_version=row["consent_version"],
            usage_analytics=bool(row["usage_analytics"]),
            interaction_research=bool(row["interaction_research"]),
            feedback_research=bool(row["feedback_research"]),
            follow_up_contact=bool(row["follow_up_contact"]),
            recorded_interview=bool(row["recorded_interview"]),
            recorded_at=row["recorded_at"],
        )

    def record_session(self, session: ResearchSession) -> None:
        self.upsert_participant(session.participant_id, session.started_at, session.metadata)
        with self._lock, self._connect() as db:
            db.execute(
                """INSERT OR REPLACE INTO sessions(
                    session_id, participant_id, study_id, app_version,
                    started_at, metadata_json
                ) VALUES(?,?,?,?,?,?)""",
                (
                    session.session_id, session.participant_id, session.study_id,
                    session.app_version, session.started_at,
                    json.dumps(session.metadata, sort_keys=True, default=str),
                ),
            )

    def record_event(self, event: ResearchEvent) -> bool:
        consent = self.latest_consent(event.participant_id)
        if consent is None or not consent.allows(event.purpose):
            return False
        with self._lock, self._connect() as db:
            db.execute(
                """INSERT OR IGNORE INTO events(
                    event_id, session_id, participant_id, event_type,
                    purpose, timestamp, workflow_stage, payload_json
                ) VALUES(?,?,?,?,?,?,?,?)""",
                (
                    event.event_id, event.session_id, event.participant_id,
                    event.event_type, event.purpose, event.timestamp,
                    event.workflow_stage,
                    json.dumps(event.payload, sort_keys=True, default=str),
                ),
            )
        return True

    def counts(self) -> dict[str, int]:
        with self._lock, self._connect() as db:
            return {
                "participants": int(db.execute("SELECT COUNT(*) FROM participants").fetchone()[0]),
                "sessions": int(db.execute("SELECT COUNT(*) FROM sessions").fetchone()[0]),
                "events": int(db.execute("SELECT COUNT(*) FROM events").fetchone()[0]),
                "consent_records": int(db.execute("SELECT COUNT(*) FROM consents").fetchone()[0]),
            }

    def list_sessions(self, limit: int = 100) -> list[dict[str, Any]]:
        limit = max(1, min(int(limit), 1000))
        with self._lock, self._connect() as db:
            rows = db.execute(
                "SELECT * FROM sessions ORDER BY started_at DESC LIMIT ?", (limit,)
            ).fetchall()
        return [
            {
                "session_id": row["session_id"],
                "participant_id": row["participant_id"],
                "study_id": row["study_id"],
                "app_version": row["app_version"],
                "started_at": row["started_at"],
                "metadata": json.loads(row["metadata_json"]),
            }
            for row in rows
        ]

    def list_events(self, session_id: str | None = None, limit: int = 500) -> list[dict[str, Any]]:
        limit = max(1, min(int(limit), 5000))
        with self._lock, self._connect() as db:
            if session_id:
                rows = db.execute(
                    "SELECT * FROM events WHERE session_id=? ORDER BY timestamp ASC LIMIT ?",
                    (session_id, limit),
                ).fetchall()
            else:
                rows = db.execute(
                    "SELECT * FROM events ORDER BY timestamp DESC LIMIT ?", (limit,)
                ).fetchall()
        return [
            {
                "event_id": row["event_id"],
                "session_id": row["session_id"],
                "participant_id": row["participant_id"],
                "event_type": row["event_type"],
                "purpose": row["purpose"],
                "timestamp": row["timestamp"],
                "workflow_stage": row["workflow_stage"],
                "payload": json.loads(row["payload_json"]),
            }
            for row in rows
        ]

    def export_tables(self) -> dict[str, list[dict[str, Any]]]:
        with self._lock, self._connect() as db:
            participants = [dict(row) for row in db.execute("SELECT * FROM participants ORDER BY created_at")]
            consents = [dict(row) for row in db.execute("SELECT * FROM consents ORDER BY recorded_at")]
            sessions = [dict(row) for row in db.execute("SELECT * FROM sessions ORDER BY started_at")]
            events = [dict(row) for row in db.execute("SELECT * FROM events ORDER BY timestamp")]
        for row in participants:
            row["metadata"] = json.loads(row.pop("metadata_json"))
        for row in consents:
            for key in ("usage_analytics", "interaction_research", "feedback_research", "follow_up_contact", "recorded_interview"):
                row[key] = bool(row[key])
        for row in sessions:
            row["metadata"] = json.loads(row.pop("metadata_json"))
        for row in events:
            row["payload"] = json.loads(row.pop("payload_json"))
        return {
            "participants": participants,
            "consents": consents,
            "sessions": sessions,
            "events": events,
        }
