from __future__ import annotations

import json
import sqlite3
import time
from pathlib import Path
from typing import Callable, TypeVar

from criterivox.s7.models import (
    AnalysisSession,
    Artifact,
    ArtifactKind,
    S7Event,
    SessionStatus,
)


T = TypeVar("T")


class S7SQLiteStore:
    """
    Durable SQLite store for S7 reasoning history.

    Design rules:
    - SQLite is the durable source of truth.
    - Artifacts and events are append-preserving.
    - Existing artifact/event rows are never overwritten.
    - A SQLite connection is created per operation/thread.
    - WAL mode allows readers while writes are occurring.
    - Transient lock contention is retried.
    """

    _MAX_RETRIES = 6
    _RETRY_DELAY_SECONDS = 0.05

    def __init__(self, path: str | Path = "data/s7/reasoning_history.sqlite3"):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)

        # Bootstrap schema once. Individual operations use their own
        # connections so FastAPI/TestClient threads never share a connection.
        with self._connect() as db:
            self._configure_connection(db)
            self._create_schema(db)

    def _connect(self) -> sqlite3.Connection:
        """
        Create a fresh SQLite connection.

        check_same_thread=False is intentionally used as an additional
        safeguard, but connections are still not shared between operations.
        """
        db = sqlite3.connect(
            self.path,
            timeout=30.0,
            check_same_thread=False,
        )
        db.row_factory = sqlite3.Row
        return db

    @staticmethod
    def _configure_connection(db: sqlite3.Connection) -> None:
        db.execute("PRAGMA foreign_keys = ON")
        db.execute("PRAGMA journal_mode = WAL")
        db.execute("PRAGMA synchronous = NORMAL")
        db.execute("PRAGMA busy_timeout = 30000")

    @staticmethod
    def _create_schema(db: sqlite3.Connection) -> None:
        db.executescript(
            """
            CREATE TABLE IF NOT EXISTS sessions (
                session_id TEXT PRIMARY KEY,
                task TEXT NOT NULL,
                context_json TEXT NOT NULL,
                status TEXT NOT NULL,
                branch_id TEXT NOT NULL,
                missing_json TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS artifacts (
                artifact_id TEXT PRIMARY KEY,
                session_id TEXT NOT NULL,
                kind TEXT NOT NULL,
                title TEXT NOT NULL,
                content_json TEXT NOT NULL,
                parent_ids_json TEXT NOT NULL,
                version INTEGER NOT NULL,
                branch_id TEXT NOT NULL,
                created_at TEXT NOT NULL,
                FOREIGN KEY(session_id)
                    REFERENCES sessions(session_id)
            );

            CREATE TABLE IF NOT EXISTS events (
                event_id TEXT PRIMARY KEY,
                session_id TEXT NOT NULL,
                event_type TEXT NOT NULL,
                payload_json TEXT NOT NULL,
                created_at TEXT NOT NULL,
                FOREIGN KEY(session_id)
                    REFERENCES sessions(session_id)
            );

            CREATE INDEX IF NOT EXISTS idx_artifacts_session
                ON artifacts(session_id);

            CREATE INDEX IF NOT EXISTS idx_events_session
                ON events(session_id);
            """
        )
        db.commit()

    def _with_retry(
        self,
        operation: Callable[[sqlite3.Connection], T],
    ) -> T:
        """
        Execute one database operation with bounded retry handling for
        transient SQLite lock contention.
        """
        last_error: sqlite3.OperationalError | None = None

        for attempt in range(self._MAX_RETRIES):
            try:
                with self._connect() as db:
                    self._configure_connection(db)
                    return operation(db)

            except sqlite3.OperationalError as exc:
                message = str(exc).lower()

                if "locked" not in message and "busy" not in message:
                    raise

                last_error = exc

                if attempt == self._MAX_RETRIES - 1:
                    raise

                time.sleep(self._RETRY_DELAY_SECONDS * (2**attempt))

        # Defensive fallback. The loop either returns or raises.
        assert last_error is not None
        raise last_error

    def save(self, session: AnalysisSession) -> None:
        def operation(db: sqlite3.Connection) -> None:
            # Keep the entire session persistence operation atomic.
            db.execute("BEGIN IMMEDIATE")

            db.execute(
                """
                INSERT INTO sessions (
                    session_id,
                    task,
                    context_json,
                    status,
                    branch_id,
                    missing_json
                )
                VALUES (?, ?, ?, ?, ?, ?)
                ON CONFLICT(session_id) DO UPDATE SET
                    task = excluded.task,
                    context_json = excluded.context_json,
                    status = excluded.status,
                    branch_id = excluded.branch_id,
                    missing_json = excluded.missing_json
                """,
                (
                    session.session_id,
                    session.task,
                    json.dumps(dict(session.context), sort_keys=True),
                    session.status.value,
                    session.branch_id,
                    json.dumps(session.missing_information),
                ),
            )

            # IMPORTANT:
            # artifacts has exactly 9 columns.
            # Therefore this INSERT has exactly 9 values.
            #
            # INSERT OR IGNORE preserves historical artifacts and prevents
            # an existing immutable artifact from being overwritten.
            for artifact in session.artifacts:
                db.execute(
                    """
                    INSERT OR IGNORE INTO artifacts (
                        artifact_id,
                        session_id,
                        kind,
                        title,
                        content_json,
                        parent_ids_json,
                        version,
                        branch_id,
                        created_at
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        artifact.artifact_id,
                        session.session_id,
                        artifact.kind.value,
                        artifact.title,
                        json.dumps(
                            dict(artifact.content),
                            sort_keys=True,
                        ),
                        json.dumps(list(artifact.parent_ids)),
                        artifact.version,
                        artifact.branch_id,
                        artifact.created_at,
                    ),
                )

            # Events are also append-preserving.
            for event in session.events:
                db.execute(
                    """
                    INSERT OR IGNORE INTO events (
                        event_id,
                        session_id,
                        event_type,
                        payload_json,
                        created_at
                    )
                    VALUES (?, ?, ?, ?, ?)
                    """,
                    (
                        event.event_id,
                        session.session_id,
                        event.event_type,
                        json.dumps(
                            dict(event.payload),
                            sort_keys=True,
                        ),
                        event.created_at,
                    ),
                )

            db.commit()

        self._with_retry(operation)

    def restore(self, session_id: str) -> AnalysisSession | None:
        def operation(db: sqlite3.Connection) -> AnalysisSession | None:
            row = db.execute(
                """
                SELECT
                    session_id,
                    task,
                    context_json,
                    status,
                    branch_id,
                    missing_json
                FROM sessions
                WHERE session_id = ?
                """,
                (session_id,),
            ).fetchone()

            if row is None:
                return None

            session = AnalysisSession(
                row["session_id"],
                row["task"],
                json.loads(row["context_json"]),
                SessionStatus(row["status"]),
                row["branch_id"],
                [],
                [],
                tuple(json.loads(row["missing_json"])),
            )

            artifact_rows = db.execute(
                """
                SELECT
                    artifact_id,
                    kind,
                    title,
                    content_json,
                    parent_ids_json,
                    version,
                    branch_id,
                    created_at
                FROM artifacts
                WHERE session_id = ?
                ORDER BY rowid
                """,
                (session_id,),
            )

            for row in artifact_rows:
                session.artifacts.append(
                    Artifact(
                        row["artifact_id"],
                        ArtifactKind(row["kind"]),
                        row["title"],
                        json.loads(row["content_json"]),
                        tuple(json.loads(row["parent_ids_json"])),
                        row["version"],
                        row["branch_id"],
                        row["created_at"],
                    )
                )

            event_rows = db.execute(
                """
                SELECT
                    event_id,
                    event_type,
                    payload_json,
                    created_at
                FROM events
                WHERE session_id = ?
                ORDER BY rowid
                """,
                (session_id,),
            )

            for row in event_rows:
                session.events.append(
                    S7Event(
                        row["event_id"],
                        row["event_type"],
                        json.loads(row["payload_json"]),
                        row["created_at"],
                    )
                )

            return session

        return self._with_retry(operation)

    def list_sessions(self) -> list[str]:
        def operation(db: sqlite3.Connection) -> list[str]:
            rows = db.execute(
                """
                SELECT session_id
                FROM sessions
                ORDER BY rowid DESC
                """
            ).fetchall()

            return [row["session_id"] for row in rows]

        return self._with_retry(operation)

    def close(self) -> None:
        """
        Connections are operation-scoped, so there is no persistent
        connection to close.

        Kept for API compatibility with existing callers.
        """
        return None