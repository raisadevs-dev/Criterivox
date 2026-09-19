from __future__ import annotations

import json
import sqlite3
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Iterator, Mapping


DB = Path(__file__).resolve().parents[3] / "data" / "home03" / "home03.sqlite3"
DB.parent.mkdir(parents=True, exist_ok=True)


class Home03Store:
    """
    Persistent Home 03 conversation and state-awareness store.

    Connection policy
    -----------------
    File-backed SQLite databases:
        A fresh connection is created for each operation and closed when the
        operation finishes. This prevents Windows file-handle leakage.

    In-memory SQLite databases:
        One connection is retained for the lifetime of the store because
        SQLite gives every :memory: connection a separate database.

    This distinction is important for pytest fixtures that use:
        Home03Store(":memory:")
    """

    def __init__(self, path: str | Path = DB):
        self.path = str(path)
        self._memory_connection: sqlite3.Connection | None = None

        if self._is_memory_database():
            self._memory_connection = self._new_connection()

        self._init()

    # ------------------------------------------------------------------
    # SQLite connection lifecycle
    # ------------------------------------------------------------------

    def _is_memory_database(self) -> bool:
        return self.path == ":memory:"

    def _new_connection(self) -> sqlite3.Connection:
        connection = sqlite3.connect(
            self.path,
            timeout=30.0,
        )

        connection.row_factory = sqlite3.Row

        # Allow short-lived concurrent SQLite contention to resolve rather
        # than immediately raising "database is locked".
        connection.execute("PRAGMA busy_timeout = 30000")

        return connection

    @contextmanager
    def _db(self) -> Iterator[sqlite3.Connection]:
        """
        Yield a usable SQLite connection.

        For :memory:, the same connection must remain alive for the entire
        store lifetime.

        For file-backed databases, the connection is explicitly closed after
        the operation. This is important on Windows because SQLite keeps the
        database file open while the connection exists.
        """
        if self._is_memory_database():
            if self._memory_connection is None:
                self._memory_connection = self._new_connection()

            yield self._memory_connection
            return

        connection = self._new_connection()

        try:
            yield connection
        finally:
            connection.close()

    def close(self) -> None:
        """
        Close the retained in-memory connection.

        File-backed connections are already closed after each operation.
        """
        if self._memory_connection is not None:
            self._memory_connection.close()
            self._memory_connection = None

    # ------------------------------------------------------------------
    # Database initialization
    # ------------------------------------------------------------------

    def _init(self) -> None:
        """
        Create Home 03 tables and indexes if they do not already exist.

        This also upgrades an older Home 03 database by adding the state
        awareness tables without destroying existing data.
        """
        with self._db() as connection:
            connection.executescript(
                """
                CREATE TABLE IF NOT EXISTS state_journeys (
                    journey_id TEXT PRIMARY KEY,
                    conversation_id TEXT NOT NULL,
                    task_id TEXT UNIQUE NOT NULL,
                    goal TEXT NOT NULL,
                    status TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL,
                    context_reference TEXT
                );

                CREATE INDEX IF NOT EXISTS
                    idx_state_journey_conversation
                ON state_journeys(conversation_id);

                CREATE INDEX IF NOT EXISTS
                    idx_state_journey_task
                ON state_journeys(task_id);


                CREATE TABLE IF NOT EXISTS state_checkpoints (
                    checkpoint_id TEXT PRIMARY KEY,
                    journey_id TEXT NOT NULL,
                    task_id TEXT NOT NULL,
                    timestamp TEXT NOT NULL,
                    payload TEXT NOT NULL
                );

                CREATE INDEX IF NOT EXISTS
                    idx_state_checkpoint_task
                ON state_checkpoints(task_id, timestamp);


                CREATE TABLE IF NOT EXISTS state_events (
                    event_id TEXT PRIMARY KEY,
                    journey_id TEXT NOT NULL,
                    task_id TEXT NOT NULL,
                    timestamp TEXT NOT NULL,
                    event_type TEXT NOT NULL,
                    payload TEXT NOT NULL
                );

                CREATE INDEX IF NOT EXISTS
                    idx_state_event_task
                ON state_events(task_id, timestamp);


                CREATE TABLE IF NOT EXISTS conversations (
                    id TEXT PRIMARY KEY,
                    created REAL NOT NULL,
                    updated REAL NOT NULL
                );


                CREATE TABLE IF NOT EXISTS messages (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    conversation_id TEXT,
                    branch_id TEXT,
                    role TEXT,
                    content TEXT,
                    metadata TEXT,
                    created REAL NOT NULL
                );


                CREATE TABLE IF NOT EXISTS branches (
                    id TEXT PRIMARY KEY,
                    conversation_id TEXT,
                    parent_message INTEGER,
                    name TEXT,
                    state TEXT,
                    created REAL NOT NULL
                );


                CREATE TABLE IF NOT EXISTS checkpoints (
                    id TEXT PRIMARY KEY,
                    conversation_id TEXT,
                    branch_id TEXT,
                    state TEXT,
                    state_hash TEXT,
                    created REAL NOT NULL
                );


                CREATE TABLE IF NOT EXISTS events (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    event_type TEXT,
                    task_id TEXT,
                    payload TEXT,
                    created REAL NOT NULL
                );


                CREATE TABLE IF NOT EXISTS pollen (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    task_id TEXT,
                    source TEXT,
                    target TEXT,
                    payload TEXT,
                    confidence REAL,
                    created REAL NOT NULL
                );
                """
            )

            connection.commit()

    # ------------------------------------------------------------------
    # Conversation storage
    # ------------------------------------------------------------------

    def conversation(self, cid: str) -> str:
        now = time.time()

        with self._db() as connection:
            connection.execute(
                """
                INSERT OR IGNORE INTO conversations(
                    id,
                    created,
                    updated
                )
                VALUES (?, ?, ?)
                """,
                (
                    cid,
                    now,
                    now,
                ),
            )

            connection.execute(
                """
                UPDATE conversations
                SET updated = ?
                WHERE id = ?
                """,
                (
                    now,
                    cid,
                ),
            )

            connection.commit()

        return cid

    # ------------------------------------------------------------------
    # Message storage
    # ------------------------------------------------------------------

    def message(
        self,
        cid: str,
        branch: str,
        role: str,
        content: str,
        metadata: Mapping[str, Any] | None = None,
    ) -> int:
        self.conversation(cid)

        with self._db() as connection:
            cursor = connection.execute(
                """
                INSERT INTO messages(
                    conversation_id,
                    branch_id,
                    role,
                    content,
                    metadata,
                    created
                )
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                (
                    cid,
                    branch,
                    role,
                    content,
                    json.dumps(metadata or {}),
                    time.time(),
                ),
            )

            connection.commit()

            return int(cursor.lastrowid)

    # ------------------------------------------------------------------
    # Branch storage
    # ------------------------------------------------------------------

    def branch(
        self,
        bid: str,
        cid: str,
        parent: int | None,
        name: str,
        state: Mapping[str, Any] | None = None,
    ) -> str:
        with self._db() as connection:
            connection.execute(
                """
                INSERT OR REPLACE INTO branches(
                    id,
                    conversation_id,
                    parent_message,
                    name,
                    state,
                    created
                )
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                (
                    bid,
                    cid,
                    parent,
                    name,
                    json.dumps(state or {}),
                    time.time(),
                ),
            )

            connection.commit()

        return bid

    # ------------------------------------------------------------------
    # Conversation checkpoint storage
    # ------------------------------------------------------------------

    def checkpoint(
        self,
        cid: str,
        bid: str,
        state: Mapping[str, Any],
        state_hash: str,
    ) -> str:
        checkpoint_id = f"cp-{int(time.time() * 1_000_000)}"

        with self._db() as connection:
            connection.execute(
                """
                INSERT INTO checkpoints(
                    id,
                    conversation_id,
                    branch_id,
                    state,
                    state_hash,
                    created
                )
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                (
                    checkpoint_id,
                    cid,
                    bid,
                    json.dumps(state),
                    state_hash,
                    time.time(),
                ),
            )

            connection.commit()

        return checkpoint_id

    # ------------------------------------------------------------------
    # Generic event storage
    # ------------------------------------------------------------------

    def event(
        self,
        event_type: str,
        task_id: str,
        payload: Mapping[str, Any],
    ) -> None:
        with self._db() as connection:
            connection.execute(
                """
                INSERT INTO events(
                    event_type,
                    task_id,
                    payload,
                    created
                )
                VALUES (?, ?, ?, ?)
                """,
                (
                    event_type,
                    task_id,
                    json.dumps(payload),
                    time.time(),
                ),
            )

            connection.commit()

    # ------------------------------------------------------------------
    # Pollen storage
    # ------------------------------------------------------------------

    def pollen(
        self,
        task_id: str,
        source: str,
        target: str,
        payload: Mapping[str, Any],
        confidence: float,
    ) -> None:
        with self._db() as connection:
            connection.execute(
                """
                INSERT INTO pollen(
                    task_id,
                    source,
                    target,
                    payload,
                    confidence,
                    created
                )
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                (
                    task_id,
                    source,
                    target,
                    json.dumps(payload),
                    confidence,
                    time.time(),
                ),
            )

            connection.commit()

    # ------------------------------------------------------------------
    # Conversation tree
    # ------------------------------------------------------------------

    def tree(self, cid: str) -> dict[str, Any]:
        with self._db() as connection:
            branches = [
                dict(row)
                for row in connection.execute(
                    """
                    SELECT
                        id,
                        conversation_id,
                        parent_message,
                        name,
                        state,
                        created
                    FROM branches
                    WHERE conversation_id = ?
                    ORDER BY created
                    """,
                    (cid,),
                )
            ]

            messages = [
                dict(row)
                for row in connection.execute(
                    """
                    SELECT
                        id,
                        conversation_id,
                        branch_id,
                        role,
                        content,
                        metadata,
                        created
                    FROM messages
                    WHERE conversation_id = ?
                    ORDER BY id
                    """,
                    (cid,),
                )
            ]

        return {
            "conversation_id": cid,
            "branches": branches,
            "messages": messages,
        }

    # ==================================================================
    # STATE AWARENESS
    # ==================================================================

    # ------------------------------------------------------------------
    # Journey
    # ------------------------------------------------------------------

    def _state_row(
        self,
        task_id: str,
    ) -> dict[str, Any] | None:
        with self._db() as connection:
            row = connection.execute(
                """
                SELECT
                    journey_id,
                    conversation_id,
                    task_id,
                    goal,
                    status,
                    created_at,
                    updated_at,
                    context_reference
                FROM state_journeys
                WHERE task_id = ?
                """,
                (task_id,),
            ).fetchone()

            if row is None:
                return None

            return dict(row)

    def state_journey(
        self,
        row: Mapping[str, Any],
    ) -> None:
        """
        Insert a state-awareness journey.

        Existing journeys are preserved. Updating an existing journey must
        go through update_state_journey().
        """
        with self._db() as connection:
            connection.execute(
                """
                INSERT OR IGNORE INTO state_journeys(
                    journey_id,
                    conversation_id,
                    task_id,
                    goal,
                    status,
                    created_at,
                    updated_at,
                    context_reference
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    row["journey_id"],
                    row["conversation_id"],
                    row["task_id"],
                    row["goal"],
                    row["status"],
                    row["created_at"],
                    row["updated_at"],
                    row.get("context_reference"),
                ),
            )

            connection.commit()

    def update_state_journey(
        self,
        task_id: str,
        fields: Mapping[str, Any],
    ) -> None:
        if not fields:
            return

        allowed = {
            "goal",
            "status",
            "updated_at",
            "context_reference",
        }

        items = [
            (key, value)
            for key, value in fields.items()
            if key in allowed
        ]

        if not items:
            return

        assignments = ", ".join(
            f"{key} = ?"
            for key, _ in items
        )

        values = [
            value
            for _, value in items
        ]

        values.append(task_id)

        with self._db() as connection:
            connection.execute(
                f"""
                UPDATE state_journeys
                SET {assignments}
                WHERE task_id = ?
                """,
                values,
            )

            connection.commit()

    def get_state_journey_by_task(
        self,
        task_id: str,
    ) -> dict[str, Any] | None:
        return self._state_row(task_id)

    def state_journeys_by_conversation(
        self,
        cid: str,
    ) -> list[dict[str, Any]]:
        with self._db() as connection:
            return [
                dict(row)
                for row in connection.execute(
                    """
                    SELECT
                        journey_id,
                        conversation_id,
                        task_id,
                        goal,
                        status,
                        created_at,
                        updated_at,
                        context_reference
                    FROM state_journeys
                    WHERE conversation_id = ?
                    ORDER BY updated_at DESC
                    """,
                    (cid,),
                )
            ]

    def active_state_journeys(self) -> list[dict[str, Any]]:
        with self._db() as connection:
            return [
                dict(row)
                for row in connection.execute(
                    """
                    SELECT
                        journey_id,
                        conversation_id,
                        task_id,
                        goal,
                        status,
                        created_at,
                        updated_at,
                        context_reference
                    FROM state_journeys
                    WHERE status NOT IN (
                        'COMPLETED',
                        'FAILED',
                        'CANCELLED'
                    )
                    ORDER BY updated_at DESC
                    """
                )
            ]

    # ------------------------------------------------------------------
    # State checkpoints
    # ------------------------------------------------------------------

    def state_checkpoint(
        self,
        row: Mapping[str, Any],
    ) -> None:
        with self._db() as connection:
            connection.execute(
                """
                INSERT INTO state_checkpoints(
                    checkpoint_id,
                    journey_id,
                    task_id,
                    timestamp,
                    payload
                )
                VALUES (?, ?, ?, ?, ?)
                """,
                (
                    row["checkpoint_id"],
                    row["journey_id"],
                    row["task_id"],
                    row["timestamp"],
                    json.dumps(row, sort_keys=True),
                ),
            )

            connection.commit()

    def latest_state_checkpoint(
        self,
        task_id: str,
    ) -> dict[str, Any] | None:
        with self._db() as connection:
            row = connection.execute(
                """
                SELECT payload
                FROM state_checkpoints
                WHERE task_id = ?
                ORDER BY timestamp DESC
                LIMIT 1
                """,
                (task_id,),
            ).fetchone()

            if row is None:
                return None

            return json.loads(row["payload"])

    # ------------------------------------------------------------------
    # State events
    # ------------------------------------------------------------------

    def state_event(
        self,
        row: Mapping[str, Any],
    ) -> None:
        with self._db() as connection:
            connection.execute(
                """
                INSERT INTO state_events(
                    event_id,
                    journey_id,
                    task_id,
                    timestamp,
                    event_type,
                    payload
                )
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                (
                    row["event_id"],
                    row["journey_id"],
                    row["task_id"],
                    row["timestamp"],
                    row["event_type"],
                    json.dumps(row, sort_keys=True),
                ),
            )

            connection.commit()

    def state_events(
        self,
        task_id: str,
    ) -> list[dict[str, Any]]:
        with self._db() as connection:
            rows = connection.execute(
                """
                SELECT payload
                FROM state_events
                WHERE task_id = ?
                ORDER BY timestamp, event_id
                """,
                (task_id,),
            )

            return [
                json.loads(row["payload"])
                for row in rows
            ]


# ----------------------------------------------------------------------
# Shared application-level store
# ----------------------------------------------------------------------

home03_store = Home03Store()
