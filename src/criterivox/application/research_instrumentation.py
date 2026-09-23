"""Research instrumentation for Criterivox.

Operational telemetry and research-participant records are deliberately
separated. This V1 implementation uses local SQLite. The repository boundary
allows a later server-backed implementation without changing the event model.

Default policy:
- never store passwords;
- never store secrets or credentials;
- do not store raw human messages as research data unless the caller has
  explicitly enabled the corresponding research consent;
- store structured, minimally necessary interaction events;
- keep participant identity (name/email) separate from event payloads.
"""
from __future__ import annotations

import json
import secrets
import sqlite3
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[3]
DEFAULT_DB = ROOT / "data" / "runtime" / "criterivox_research.sqlite3"


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _id(prefix: str) -> str:
    return f"{prefix}-{secrets.token_urlsafe(12)}"


@dataclass(frozen=True, slots=True)
class ResearchParticipant:
    participant_id: str
    display_name: str
    email: str
    created_at: str


@dataclass(frozen=True, slots=True)
class ResearchConsent:
    participant_id: str
    consent_version: str
    research_data: bool
    identifiable_data: bool
    raw_text: bool
    outcome_follow_up: bool
    granted_at: str | None


@dataclass(frozen=True, slots=True)
class ResearchSession:
    session_id: str
    participant_id: str | None
    started_at: str
    ended_at: str | None
    language_mode: str
    source: str


class ResearchInstrumentationStore:
    """SQLite V1 research instrumentation boundary."""

    def __init__(self, path: str | Path = DEFAULT_DB) -> None:
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._create_schema()

    def _connect(self) -> sqlite3.Connection:
        db = sqlite3.connect(self.path)
        db.row_factory = sqlite3.Row
        return db

    def _create_schema(self) -> None:
        with self._connect() as db:
            db.executescript(
                """
                CREATE TABLE IF NOT EXISTS research_participants (
                    participant_id TEXT PRIMARY KEY,
                    display_name TEXT NOT NULL,
                    email TEXT NOT NULL,
                    created_at TEXT NOT NULL
                );

                CREATE TABLE IF NOT EXISTS research_consents (
                    participant_id TEXT PRIMARY KEY,
                    consent_version TEXT NOT NULL,
                    research_data INTEGER NOT NULL DEFAULT 0,
                    identifiable_data INTEGER NOT NULL DEFAULT 0,
                    raw_text INTEGER NOT NULL DEFAULT 0,
                    outcome_follow_up INTEGER NOT NULL DEFAULT 0,
                    granted_at TEXT,
                    FOREIGN KEY(participant_id)
                        REFERENCES research_participants(participant_id)
                );

                CREATE TABLE IF NOT EXISTS research_sessions (
                    session_id TEXT PRIMARY KEY,
                    participant_id TEXT,
                    started_at TEXT NOT NULL,
                    ended_at TEXT,
                    language_mode TEXT NOT NULL DEFAULT 'auto',
                    source TEXT NOT NULL DEFAULT 'criterivox',
                    FOREIGN KEY(participant_id)
                        REFERENCES research_participants(participant_id)
                );

                CREATE TABLE IF NOT EXISTS research_events (
                    event_id TEXT PRIMARY KEY,
                    session_id TEXT NOT NULL,
                    participant_id TEXT,
                    event_type TEXT NOT NULL,
                    occurred_at TEXT NOT NULL,
                    research_scope TEXT NOT NULL,
                    payload_json TEXT NOT NULL,
                    FOREIGN KEY(session_id)
                        REFERENCES research_sessions(session_id)
                );

                CREATE TABLE IF NOT EXISTS research_outcomes (
                    outcome_id TEXT PRIMARY KEY,
                    session_id TEXT NOT NULL,
                    participant_id TEXT NOT NULL,
                    success_state TEXT NOT NULL,
                    helped_score REAL,
                    improvement_request TEXT,
                    outcome_summary TEXT,
                    recorded_at TEXT NOT NULL,
                    FOREIGN KEY(session_id)
                        REFERENCES research_sessions(session_id)
                );

                CREATE INDEX IF NOT EXISTS idx_research_events_session
                    ON research_events(session_id, occurred_at);
                CREATE INDEX IF NOT EXISTS idx_research_events_type
                    ON research_events(event_type, occurred_at);
                CREATE INDEX IF NOT EXISTS idx_research_sessions_participant
                    ON research_sessions(participant_id, started_at);
                """
            )

    def register_participant(self, *, display_name: str, email: str) -> ResearchParticipant:
        display_name = display_name.strip()
        email = email.strip().lower()
        if not display_name or not email:
            raise ValueError("display_name and email are required")
        participant = ResearchParticipant(_id("participant"), display_name, email, _now())
        with self._connect() as db:
            db.execute(
                "INSERT INTO research_participants VALUES (?,?,?,?)",
                (participant.participant_id, participant.display_name,
                 participant.email, participant.created_at),
            )
        return participant

    def record_consent(
        self,
        *,
        participant_id: str,
        consent_version: str,
        research_data: bool,
        identifiable_data: bool = False,
        raw_text: bool = False,
        outcome_follow_up: bool = False,
    ) -> ResearchConsent:
        granted = _now() if research_data else None
        consent = ResearchConsent(
            participant_id, consent_version, research_data,
            identifiable_data, raw_text, outcome_follow_up, granted
        )
        with self._connect() as db:
            db.execute(
                """
                INSERT INTO research_consents
                (participant_id,consent_version,research_data,identifiable_data,
                 raw_text,outcome_follow_up,granted_at)
                VALUES (?,?,?,?,?,?,?)
                ON CONFLICT(participant_id) DO UPDATE SET
                  consent_version=excluded.consent_version,
                  research_data=excluded.research_data,
                  identifiable_data=excluded.identifiable_data,
                  raw_text=excluded.raw_text,
                  outcome_follow_up=excluded.outcome_follow_up,
                  granted_at=excluded.granted_at
                """,
                (
                    participant_id, consent.consent_version,
                    int(consent.research_data), int(consent.identifiable_data),
                    int(consent.raw_text), int(consent.outcome_follow_up),
                    consent.granted_at,
                ),
            )
        return consent

    def start_session(
        self,
        *,
        participant_id: str | None = None,
        language_mode: str = "auto",
        source: str = "criterivox",
    ) -> ResearchSession:
        session = ResearchSession(
            _id("session"), participant_id, _now(), None,
            language_mode, source
        )
        with self._connect() as db:
            db.execute(
                "INSERT INTO research_sessions VALUES (?,?,?,?,?,?)",
                (
                    session.session_id, session.participant_id,
                    session.started_at, session.ended_at,
                    session.language_mode, session.source,
                ),
            )
        return session

    def end_session(self, session_id: str) -> None:
        with self._connect() as db:
            db.execute(
                "UPDATE research_sessions SET ended_at=? WHERE session_id=?",
                (_now(), session_id),
            )

    def record_event(
        self,
        *,
        session_id: str,
        event_type: str,
        payload: dict[str, Any] | None = None,
        participant_id: str | None = None,
        research_scope: str = "operational",
        contains_raw_text: bool = False,
    ) -> str:
        """Record a minimal event.

        'research' scope requires an enabled research_data consent when a
        participant is attached. Raw human text must additionally require
        raw_text consent and should be supplied only intentionally.
        """
        if research_scope not in {"operational", "research"}:
            raise ValueError("research_scope must be operational or research")

        if research_scope == "research" and participant_id:
            consent = self._consent(participant_id)
            if not consent or not consent["research_data"]:
                raise PermissionError("research_data consent is required")
            if contains_raw_text and not consent["raw_text"]:
                raise PermissionError("raw_text consent is required")
        if contains_raw_text and research_scope != "research":
            raise PermissionError("raw_text can only be recorded as research data")

        event_id = _id("event")
        with self._connect() as db:
            db.execute(
                """
                INSERT INTO research_events
                (event_id,session_id,participant_id,event_type,occurred_at,
                 research_scope,payload_json)
                VALUES (?,?,?,?,?,?,?)
                """,
                (
                    event_id, session_id, participant_id, event_type, _now(),
                    research_scope, json.dumps(payload or {}, sort_keys=True,
                                               default=str),
                ),
            )
        return event_id

    def record_outcome(
        self,
        *,
        session_id: str,
        participant_id: str,
        success_state: str,
        helped_score: float | None = None,
        improvement_request: str | None = None,
        outcome_summary: str | None = None,
    ) -> str:
        consent = self._consent(participant_id)
        if not consent or not consent["research_data"]:
            raise PermissionError("research_data consent is required")
        if not consent["outcome_follow_up"]:
            raise PermissionError("outcome_follow_up consent is required")
        if helped_score is not None and not 0 <= helped_score <= 10:
            raise ValueError("helped_score must be between 0 and 10")

        outcome_id = _id("outcome")
        with self._connect() as db:
            db.execute(
                """
                INSERT INTO research_outcomes
                (outcome_id,session_id,participant_id,success_state,helped_score,
                 improvement_request,outcome_summary,recorded_at)
                VALUES (?,?,?,?,?,?,?,?)
                """,
                (
                    outcome_id, session_id, participant_id, success_state,
                    helped_score, improvement_request, outcome_summary, _now(),
                ),
            )
        return outcome_id

    def _consent(self, participant_id: str) -> sqlite3.Row | None:
        with self._connect() as db:
            return db.execute(
                "SELECT * FROM research_consents WHERE participant_id=?",
                (participant_id,),
            ).fetchone()


class ResearchQuestionAnalyzer:
    """Derives descriptive research evidence from recorded events.

    This deliberately returns counts and traceable aggregates. It does not
    turn observational telemetry into causal claims.
    """

    def __init__(self, store: ResearchInstrumentationStore) -> None:
        self.store = store

    def event_counts(self, *, event_type: str | None = None) -> dict[str, int]:
        query = "SELECT event_type, COUNT(*) AS n FROM research_events"
        params: tuple[Any, ...] = ()
        if event_type:
            query += " WHERE event_type=?"
            params = (event_type,)
        query += " GROUP BY event_type ORDER BY event_type"
        with self.store._connect() as db:
            rows = db.execute(query, params).fetchall()
        return {row["event_type"]: int(row["n"]) for row in rows}

    def outcome_summary(self) -> dict[str, Any]:
        with self.store._connect() as db:
            row = db.execute(
                """
                SELECT COUNT(*) AS n,
                       AVG(helped_score) AS avg_helped,
                       SUM(CASE WHEN success_state='succeeded' THEN 1 ELSE 0 END)
                         AS succeeded
                FROM research_outcomes
                """
            ).fetchone()
        return {
            "outcomes": int(row["n"] or 0),
            "average_helped_score": row["avg_helped"],
            "succeeded": int(row["succeeded"] or 0),
        }


research_instrumentation = ResearchInstrumentationStore()

__all__ = [
    "ResearchConsent",
    "ResearchInstrumentationStore",
    "ResearchParticipant",
    "ResearchQuestionAnalyzer",
    "ResearchSession",
    "research_instrumentation",
]
