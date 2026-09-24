"""Local-only Human Residence identity, session and decision persistence.

This is intentionally device-local for the current V1 runtime. The browser
keeps the active residence/session in IndexedDB; Python owns the connected
runtime state and persists durable records to a local SQLite database.
Production remote identity/database services are deliberately not introduced.
"""
from __future__ import annotations

import hashlib
import hmac
import json
import secrets
import sqlite3
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[3]
DEFAULT_DB = ROOT / "data" / "runtime" / "criterivox_human_residence.sqlite3"

def _now() -> str:
    return datetime.now(timezone.utc).isoformat()

def _password_hash(password: str, salt: bytes | None = None) -> str:
    salt = salt or secrets.token_bytes(16)
    digest = hashlib.scrypt(password.encode("utf-8"), salt=salt, n=2**14, r=8, p=1)
    return f"scrypt${salt.hex()}${digest.hex()}"

def _password_matches(password: str, encoded: str) -> bool:
    try:
        _, salt_hex, _ = encoded.split("$", 2)
        return hmac.compare_digest(_password_hash(password, bytes.fromhex(salt_hex)), encoded)
    except (ValueError, TypeError):
        return False

class HumanResidenceLocalStore:
    def __init__(self, path: str | Path = DEFAULT_DB) -> None:
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._sessions: dict[str, str] = {}
        self._create_schema()

    def _connect(self) -> sqlite3.Connection:
        db = sqlite3.connect(self.path)
        db.row_factory = sqlite3.Row
        return db

    def _create_schema(self) -> None:
        with self._connect() as db:
            db.executescript("""
                CREATE TABLE IF NOT EXISTS identities (
                    owner_id TEXT PRIMARY KEY,
                    email TEXT NOT NULL UNIQUE,
                    display_name TEXT NOT NULL,
                    password_hash TEXT NOT NULL,
                    avatar_data_url TEXT,
                    role TEXT NOT NULL DEFAULT 'owner',
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                );
                CREATE TABLE IF NOT EXISTS residences (
                    residence_id TEXT PRIMARY KEY,
                    owner_id TEXT NOT NULL,
                    residence_type TEXT NOT NULL,
                    display_name TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL,
                    payload_json TEXT NOT NULL
                );
                CREATE TABLE IF NOT EXISTS decisions (
                    decision_id TEXT PRIMARY KEY,
                    owner_id TEXT NOT NULL,
                    residence_id TEXT NOT NULL,
                    title TEXT NOT NULL,
                    goal TEXT NOT NULL,
                    strategy_json TEXT NOT NULL,
                    trace_json TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_decisions_owner ON decisions(owner_id, created_at DESC);
                CREATE TABLE IF NOT EXISTS decision_events (
                    event_id TEXT PRIMARY KEY,
                    decision_id TEXT NOT NULL,
                    owner_id TEXT NOT NULL,
                    event_type TEXT NOT NULL,
                    payload_json TEXT NOT NULL,
                    created_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_decision_events_decision ON decision_events(decision_id, created_at ASC);
                CREATE TABLE IF NOT EXISTS calendar_events (
                    calendar_id TEXT PRIMARY KEY,
                    owner_id TEXT NOT NULL,
                    residence_id TEXT NOT NULL,
                    decision_id TEXT NOT NULL,
                    title TEXT NOT NULL,
                    starts_at TEXT NOT NULL,
                    ends_at TEXT,
                    status TEXT NOT NULL,
                    strategy_id TEXT,
                    notes TEXT NOT NULL DEFAULT '',
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS idx_calendar_owner ON calendar_events(owner_id, starts_at ASC);
            """)
            try:
                db.execute("ALTER TABLE identities ADD COLUMN oauth_provider TEXT")
            except sqlite3.OperationalError:
                pass
            try:
                db.execute("ALTER TABLE identities ADD COLUMN oauth_subject TEXT")
            except sqlite3.OperationalError:
                pass

    def signup(self, *, email: str, password: str, display_name: str, residence_id: str,
               residence_type: str, avatar_data_url: str | None = None, role: str = "owner") -> dict[str, Any]:
        email = email.strip().lower()
        display_name = display_name.strip()
        if not email or not display_name or len(password) < 8:
            raise ValueError("name, email and an 8+ character password are required")
        owner_id = f"human-{secrets.token_urlsafe(12)}"
        now = _now()
        with self._connect() as db:
            try:
                db.execute(
                    """INSERT INTO identities
                    (owner_id,email,display_name,password_hash,avatar_data_url,role,created_at,updated_at)
                    VALUES (?,?,?,?,?,?,?,?)""",
                    (owner_id, email, display_name, _password_hash(password), avatar_data_url, role, now, now),
                )
                db.execute(
                    """INSERT INTO residences
                    (residence_id,owner_id,residence_type,display_name,created_at,updated_at,payload_json)
                    VALUES (?,?,?,?,?,?,?)""",
                    (residence_id, owner_id, residence_type, display_name, now, now, json.dumps({}, sort_keys=True)),
                )
            except sqlite3.IntegrityError as exc:
                raise ValueError("an account with that email already exists") from exc
        return self._identity(owner_id)

    def oauth_identity(self, *, provider: str, subject: str, email: str, display_name: str,
                       avatar_data_url: str = "") -> tuple[dict[str, Any], dict[str, Any]]:
        provider = provider.strip().lower()
        subject = subject.strip()
        email = email.strip().lower()
        if not provider or not subject or not email:
            raise ValueError("OAuth identity is incomplete")
        now = _now()
        with self._connect() as db:
            row = db.execute(
                "SELECT owner_id FROM identities WHERE oauth_provider=? AND oauth_subject=?",
                (provider, subject),
            ).fetchone()
            if row is None:
                row = db.execute(
                    "SELECT owner_id FROM identities WHERE email=?",
                    (email,),
                ).fetchone()
            if row is None:
                owner_id = f"human-{secrets.token_urlsafe(12)}"
                residence_id = f"res-google-{secrets.token_urlsafe(8)}"
                db.execute(
                    """INSERT INTO identities
                    (owner_id,email,display_name,password_hash,avatar_data_url,role,created_at,updated_at,oauth_provider,oauth_subject)
                    VALUES (?,?,?,?,?,?,?,?,?,?)""",
                    (owner_id, email, display_name, _password_hash(secrets.token_urlsafe(32)),
                     avatar_data_url or None, "owner", now, now, provider, subject),
                )
                db.execute(
                    """INSERT INTO residences
                    (residence_id,owner_id,residence_type,display_name,created_at,updated_at,payload_json)
                    VALUES (?,?,?,?,?,?,?)""",
                    (residence_id, owner_id, "private", display_name, now, now, json.dumps({
                        "oauth_provider": provider,
                        "oauth_subject": subject,
                        "google_account": True,
                    }, sort_keys=True)),
                )
                owner_id_value = owner_id
            else:
                owner_id_value = row["owner_id"]
                db.execute(
                    "UPDATE identities SET display_name=?,avatar_data_url=?,oauth_provider=?,oauth_subject=?,updated_at=? WHERE owner_id=?",
                    (display_name, avatar_data_url or None, provider, subject, now, owner_id_value),
                )
        identity = self._identity(owner_id_value)
        with self._connect() as db:
            residence_row = db.execute(
                "SELECT * FROM residences WHERE owner_id=? ORDER BY created_at ASC LIMIT 1",
                (owner_id_value,),
            ).fetchone()
        if residence_row is None:
            raise ValueError("Google identity has no Human Residence")
        residence = dict(residence_row)
        return identity, {
            "residence_id": residence["residence_id"],
            "owner_id": residence["owner_id"],
            "display_name": residence["display_name"],
            "email": identity["email"],
            "residence_type": residence["residence_type"],
            "created_at": residence["created_at"],
            "members": [{"role": "owner", "owner_id": owner_id_value}],
            "metadata": json.loads(residence["payload_json"] or "{}"),
        }

    def login(self, *, email: str, password: str) -> dict[str, Any]:
        with self._connect() as db:
            row = db.execute("SELECT * FROM identities WHERE email=?", (email.strip().lower(),)).fetchone()
        if row is None or not _password_matches(password, row["password_hash"]):
            raise ValueError("invalid email or password")
        return self._identity(row["owner_id"])

    def _identity(self, owner_id: str) -> dict[str, Any]:
        with self._connect() as db:
            row = db.execute(
                "SELECT owner_id,email,display_name,avatar_data_url,role,created_at,updated_at FROM identities WHERE owner_id=?",
                (owner_id,),
            ).fetchone()
        if row is None:
            raise ValueError("identity not found")
        return dict(row)

    def issue_session(self, owner_id: str) -> str:
        token = secrets.token_urlsafe(32)
        self._sessions[token] = owner_id
        return token

    def owner_for_session(self, token: str) -> str | None:
        return self._sessions.get(token)

    def update_profile(self, *, owner_id: str, display_name: str | None = None,
                       avatar_data_url: str | None = None, role: str | None = None) -> dict[str, Any]:
        current = self._identity(owner_id)
        with self._connect() as db:
            db.execute(
                """UPDATE identities SET display_name=?, avatar_data_url=?, role=?, updated_at=?
                WHERE owner_id=?""",
                (display_name.strip() if display_name else current["display_name"],
                 avatar_data_url if avatar_data_url is not None else current["avatar_data_url"],
                 role.strip() if role else current["role"], _now(), owner_id),
            )
        return self._identity(owner_id)

    def save_residence(self, payload: dict[str, Any]) -> dict[str, Any]:
        residence_id = str(payload.get("residence_id", "")).strip()
        owner_id = str(payload.get("owner_id", "")).strip()
        if not residence_id or not owner_id:
            raise ValueError("residence_id and owner_id are required")
        now = _now()
        with self._connect() as db:
            db.execute(
                """INSERT INTO residences
                (residence_id,owner_id,residence_type,display_name,created_at,updated_at,payload_json)
                VALUES (?,?,?,?,?,?,?)
                ON CONFLICT(residence_id) DO UPDATE SET
                owner_id=excluded.owner_id,residence_type=excluded.residence_type,
                display_name=excluded.display_name,updated_at=excluded.updated_at,payload_json=excluded.payload_json""",
                (residence_id, owner_id, str(payload.get("residence_type","private")),
                 str(payload.get("display_name","")), str(payload.get("created_at",now)), now,
                 json.dumps(payload, default=str, sort_keys=True)),
            )
        return dict(payload)

    def save_decision(self, *, owner_id: str, residence_id: str, title: str, goal: str,
                      strategy: dict[str, Any], trace: list[dict[str, Any]] | None = None) -> dict[str, Any]:
        decision_id = f"decision-{secrets.token_urlsafe(12)}"
        now = _now()
        with self._connect() as db:
            db.execute(
                """INSERT INTO decisions
                (decision_id,owner_id,residence_id,title,goal,strategy_json,trace_json,created_at,updated_at)
                VALUES (?,?,?,?,?,?,?,?,?)""",
                (decision_id, owner_id, residence_id, title.strip() or "Criterivox Strategy", goal,
                 json.dumps(strategy, default=str, sort_keys=True),
                 json.dumps(trace or [], default=str, sort_keys=True), now, now),
            )
        return self.get_decision(decision_id) or {}

    def list_decisions(self, owner_id: str, query: str = "") -> list[dict[str, Any]]:
        with self._connect() as db:
            rows = db.execute(
                """SELECT * FROM decisions
                WHERE owner_id=? AND (title LIKE ? OR goal LIKE ?)
                ORDER BY created_at DESC""",
                (owner_id, f"%{query}%", f"%{query}%"),
            ).fetchall()
        return [self._decision_row(row) for row in rows]

    def record_decision_event(self, *, decision_id: str, owner_id: str, event_type: str, payload: dict[str, Any]) -> dict[str, Any]:
        event_id = f"event-{secrets.token_urlsafe(12)}"
        now = _now()
        with self._connect() as db:
            row = db.execute("SELECT owner_id FROM decisions WHERE decision_id=?", (decision_id,)).fetchone()
            if row is None or row["owner_id"] != owner_id:
                raise ValueError("decision not found")
            db.execute(
                "INSERT INTO decision_events(event_id,decision_id,owner_id,event_type,payload_json,created_at) VALUES (?,?,?,?,?,?)",
                (event_id, decision_id, owner_id, event_type, json.dumps(payload, default=str, sort_keys=True), now),
            )
        return {"event_id": event_id, "decision_id": decision_id, "event_type": event_type, "payload": payload, "created_at": now}

    def decision_events(self, *, decision_id: str, owner_id: str) -> list[dict[str, Any]]:
        with self._connect() as db:
            rows = db.execute(
                "SELECT * FROM decision_events WHERE decision_id=? AND owner_id=? ORDER BY created_at ASC",
                (decision_id, owner_id),
            ).fetchall()
        return [
            {
                "event_id": row["event_id"],
                "decision_id": row["decision_id"],
                "event_type": row["event_type"],
                "payload": json.loads(row["payload_json"]),
                "created_at": row["created_at"],
            }
            for row in rows
        ]

    def create_calendar_event(self, *, owner_id: str, residence_id: str, decision_id: str,
                              title: str, starts_at: str, ends_at: str | None = None,
                              strategy_id: str | None = None, notes: str = "") -> dict[str, Any]:
        if not self.get_decision(decision_id):
            raise ValueError("decision not found")
        calendar_id = f"calendar-{secrets.token_urlsafe(12)}"
        now = _now()
        with self._connect() as db:
            db.execute(
                """INSERT INTO calendar_events
                (calendar_id,owner_id,residence_id,decision_id,title,starts_at,ends_at,status,strategy_id,notes,created_at,updated_at)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?)""",
                (calendar_id, owner_id, residence_id, decision_id, title.strip() or "Criterivox strategy",
                 starts_at, ends_at, "scheduled", strategy_id, notes, now, now),
            )
        return self.get_calendar_event(calendar_id) or {}

    def get_calendar_event(self, calendar_id: str) -> dict[str, Any] | None:
        with self._connect() as db:
            row = db.execute("SELECT * FROM calendar_events WHERE calendar_id=?", (calendar_id,)).fetchone()
        return dict(row) if row else None

    def list_calendar_events(self, owner_id: str, *, from_at: str | None = None, to_at: str | None = None) -> list[dict[str, Any]]:
        clauses = ["owner_id=?"]
        params: list[Any] = [owner_id]
        if from_at:
            clauses.append("starts_at>=?")
            params.append(from_at)
        if to_at:
            clauses.append("starts_at<=?")
            params.append(to_at)
        with self._connect() as db:
            rows = db.execute(
                "SELECT * FROM calendar_events WHERE " + " AND ".join(clauses) + " ORDER BY starts_at ASC",
                params,
            ).fetchall()
        return [dict(row) for row in rows]

    def update_calendar_event(self, *, calendar_id: str, owner_id: str, status: str | None = None,
                              starts_at: str | None = None, ends_at: str | None = None) -> dict[str, Any]:
        event = self.get_calendar_event(calendar_id)
        if not event or event["owner_id"] != owner_id:
            raise ValueError("calendar event not found")
        with self._connect() as db:
            db.execute(
                "UPDATE calendar_events SET status=?, starts_at=?, ends_at=?, updated_at=? WHERE calendar_id=?",
                (status or event["status"], starts_at or event["starts_at"], ends_at if ends_at is not None else event["ends_at"], _now(), calendar_id),
            )
        return self.get_calendar_event(calendar_id) or {}

    def get_decision(self, decision_id: str) -> dict[str, Any] | None:
        with self._connect() as db:
            row = db.execute("SELECT * FROM decisions WHERE decision_id=?", (decision_id,)).fetchone()
        return self._decision_row(row) if row else None

    @staticmethod
    def _decision_row(row: sqlite3.Row) -> dict[str, Any]:
        return {
            "decision_id": row["decision_id"], "owner_id": row["owner_id"], "residence_id": row["residence_id"],
            "title": row["title"], "goal": row["goal"], "strategy": json.loads(row["strategy_json"]),
            "trace": json.loads(row["trace_json"]), "created_at": row["created_at"], "updated_at": row["updated_at"],
        }

human_residence_local = HumanResidenceLocalStore()
