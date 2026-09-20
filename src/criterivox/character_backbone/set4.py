from __future__ import annotations

import json
import sqlite3
from contextlib import contextmanager
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterator, Mapping
from uuid import uuid4


ROOT = Path(__file__).resolve().parents[3]
STORE_PATH = ROOT / "data" / "s8" / "character_operations.sqlite3"


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def uid(prefix: str) -> str:
    return f"{prefix}-{uuid4()}"


@dataclass(frozen=True)
class JourneyRecord:
    journey_id: str
    originating_conversation: str | None
    problem: str
    status: str = "ACTIVE"
    task_ids: tuple = ()
    event_lineage: tuple = ()
    created_at: str = ""
    updated_at: str = ""
    provenance: Mapping = field(default_factory=dict)


@dataclass(frozen=True)
class EvidenceRecord:
    evidence_id: str
    journey_id: str
    task_id: str | None
    question: str
    source_reference: str
    source_type: str
    observation: str
    extracted_claims: tuple = ()
    interpretation: str | None = None
    collected_by: str = "medrus"
    collection_method: str = "recorded"
    timestamp: str = ""
    temporal_scope: str | None = None
    provenance: Mapping = field(default_factory=dict)
    verification_status: str = "RAW"
    contradiction_refs: tuple = ()
    uncertainty: tuple = ()
    limitations: tuple = ()


@dataclass(frozen=True)
class VerificationRecord:
    verification_id: str
    target_type: str
    target_id: str
    verification_method: str
    source_refs: tuple
    checks: tuple
    contradictions: tuple
    temporal_validity: str
    integrity_status: str
    verifier: str
    timestamp: str
    result: str
    uncertainty: tuple = ()
    limitations: tuple = ()
    provenance: Mapping = field(default_factory=dict)


@dataclass(frozen=True)
class ReasoningExplanation:
    reasoning_id: str
    journey_id: str
    question: str
    conclusion: str
    supporting_evidence: tuple
    relevant_context: tuple
    assumptions: tuple
    alternatives: tuple
    rejected_alternatives: tuple
    contradictions: tuple
    decision_factors: tuple
    uncertainty: tuple
    limitations: tuple
    provenance: Mapping = field(default_factory=dict)


@dataclass(frozen=True)
class HypothesisRecord:
    hypothesis_id: str
    journey_id: str
    question: str
    statement: str
    origin: str
    supporting_evidence: tuple = ()
    contradicting_evidence: tuple = ()
    assumptions: tuple = ()
    alternatives: tuple = ()
    status: str = "PROPOSED"
    test_reference: str | None = None
    verification_reference: str | None = None
    provenance: Mapping = field(default_factory=dict)


@dataclass(frozen=True)
class ChallengeRecord:
    challenge_id: str
    journey_id: str
    target_type: str
    target_id: str
    human_input: str
    challenge_type: str
    objection: str
    affected_assumptions: tuple = ()
    affected_evidence: tuple = ()
    requested_change: str | None = None
    created_at: str = ""
    resolution_status: str = "OPEN"
    resolution: str | None = None
    provenance: Mapping = field(default_factory=dict)


@dataclass(frozen=True)
class DecisionRecord:
    decision_id: str
    journey_id: str
    options: tuple
    recommendation: str | None
    recommendation_basis: tuple
    selected_option: str | None
    human_actor: str | None
    human_modification: str | None
    rationale: str | None
    constraints: tuple
    evidence_refs: tuple
    uncertainty: tuple
    authorization_state: str
    timestamp: str
    provenance: Mapping = field(default_factory=dict)


@dataclass(frozen=True)
class OutcomeRecord:
    outcome_id: str
    journey_id: str
    task_id: str | None
    decision_reference: str | None
    plan_reference: str | None
    execution_reference: str | None
    expected_outcome: str
    actual_outcome: str | None
    observed_evidence: tuple
    deviations: tuple
    success_status: str
    verification_status: str
    lessons: tuple
    created_at: str
    provenance: Mapping = field(default_factory=dict)


@dataclass(frozen=True)
class KnowledgeRecord:
    knowledge_id: str
    journey_id: str
    subject: str
    statement: str
    source_artifacts: tuple
    evidence_refs: tuple
    verification_refs: tuple
    context_conditions: tuple
    applicability: tuple
    limitations: tuple
    uncertainty: tuple
    maturity: str
    created_at: str
    updated_at: str
    provenance: Mapping = field(default_factory=dict)


@dataclass(frozen=True)
class AdaptationRecord:
    adaptation_id: str
    journey_id: str
    source_context: str
    previous_version: str | None
    new_version: str | None
    trigger: str
    affected_artifacts: tuple
    adaptation_action: str
    status: str
    provenance: Mapping = field(default_factory=dict)


@dataclass(frozen=True)
class TransferRecord:
    transfer_id: str
    journey_id: str
    source_home: str
    destination_home: str
    source_artifact: str
    source_context: str | None
    target_context: str | None
    compatibility: str
    adaptation_required: bool
    adaptation_reference: str | None
    status: str
    provenance: Mapping = field(default_factory=dict)


class Set4Store:
    """
    Durable SQLite store for Set 4 records.

    Connections are intentionally short-lived. This prevents SQLite database
    handles from remaining open after individual operations, which is
    especially important on Windows where an open handle can prevent a
    TemporaryDirectory from being removed.
    """

    def __init__(self, path: str | Path = STORE_PATH):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._initialize()

    @contextmanager
    def _connection(self) -> Iterator[sqlite3.Connection]:
        connection = sqlite3.connect(str(self.path))
        connection.row_factory = sqlite3.Row

        try:
            yield connection
            connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    def _initialize(self) -> None:
        with self._connection() as connection:
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS set4_records(
                    record_id TEXT PRIMARY KEY,
                    record_type TEXT NOT NULL,
                    journey_id TEXT NOT NULL,
                    task_id TEXT,
                    owner TEXT,
                    status TEXT,
                    payload_json TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                )
                """
            )

            connection.execute(
                """
                CREATE INDEX IF NOT EXISTS idx_set4_journey
                ON set4_records(journey_id, created_at)
                """
            )

    @staticmethod
    def _decode(row: sqlite3.Row) -> dict[str, Any]:
        payload = json.loads(row["payload_json"])

        return {
            **payload,
            "_record_type": row["record_type"],
            "_journey_id": row["journey_id"],
            "_task_id": row["task_id"],
            "_status": row["status"],
            "_owner": row["owner"],
        }

    def save(
        self,
        record_type: str,
        payload: Mapping[str, Any],
        *,
        journey_id: str,
        task_id: str | None = None,
        owner: str | None = None,
        status: str | None = None,
        record_id: str | None = None,
    ) -> str:
        rid = record_id or str(payload.get("id") or uid("S4"))
        stamp = now()

        with self._connection() as connection:
            connection.execute(
                """
                INSERT OR REPLACE INTO set4_records(
                    record_id,
                    record_type,
                    journey_id,
                    task_id,
                    owner,
                    status,
                    payload_json,
                    created_at,
                    updated_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    rid,
                    record_type,
                    journey_id,
                    task_id,
                    owner,
                    status,
                    json.dumps(
                        dict(payload),
                        default=str,
                        sort_keys=True,
                    ),
                    stamp,
                    stamp,
                ),
            )

        return rid

    def get(self, record_id: str) -> dict[str, Any] | None:
        with self._connection() as connection:
            row = connection.execute(
                """
                SELECT *
                FROM set4_records
                WHERE record_id = ?
                """,
                (record_id,),
            ).fetchone()

        return None if row is None else self._decode(row)

    def list(
        self,
        *,
        journey_id: str | None = None,
        record_type: str | None = None,
    ) -> list[dict[str, Any]]:
        query = "SELECT * FROM set4_records"
        conditions: list[str] = []
        values: list[Any] = []

        if journey_id is not None:
            conditions.append("journey_id = ?")
            values.append(journey_id)

        if record_type is not None:
            conditions.append("record_type = ?")
            values.append(record_type)

        if conditions:
            query += " WHERE " + " AND ".join(conditions)

        query += " ORDER BY created_at"

        with self._connection() as connection:
            rows = connection.execute(query, values).fetchall()

        return [self._decode(row) for row in rows]


class Set4Runtime:
    RECORD_TYPES = (
        "journey",
        "chat",
        "context",
        "data",
        "evidence",
        "reasoning",
        "hypothesis",
        "contradiction",
        "challenge",
        "decision",
        "action_plan",
        "authorization",
        "execution",
        "outcome",
        "verification",
        "knowledge",
        "adaptation",
        "transfer",
        "event",
    )

    def __init__(self, store: Set4Store | None = None):
        self.store = store or Set4Store()

    def _record(
        self,
        kind: str,
        payload: Mapping[str, Any],
        journey_id: str,
        **kwargs: Any,
    ) -> str:
        return self.store.save(
            kind,
            payload,
            journey_id=journey_id,
            **kwargs,
        )

    def event(
        self,
        event_type: str,
        journey_id: str,
        *,
        actor: str,
        task_id: str | None = None,
        inputs: Mapping[str, Any] | None = None,
        outputs: Mapping[str, Any] | None = None,
        caused_by: str | None = None,
        parent_event: str | None = None,
    ) -> str:
        eid = uid("S4E")

        payload = {
            "id": eid,
            "event_type": event_type,
            "journey_id": journey_id,
            "task_id": task_id,
            "actor": actor,
            "timestamp": now(),
            "inputs": dict(inputs or {}),
            "outputs": dict(outputs or {}),
            "caused_by": caused_by,
            "parent_event": parent_event,
            "provenance": {"source": "set4-runtime"},
        }

        return self._record(
            "event",
            payload,
            journey_id,
            task_id=task_id,
            owner=actor,
            record_id=eid,
        )

    def create_journey(
        self,
        problem: str,
        *,
        conversation_id: str | None = None,
        task_id: str | None = None,
        journey_id: str | None = None,
    ) -> JourneyRecord:
        jid = journey_id or uid("JRN")
        stamp = now()

        record = JourneyRecord(
            journey_id=jid,
            originating_conversation=conversation_id,
            problem=problem,
            created_at=stamp,
            updated_at=stamp,
        )

        self._record(
            "journey",
            asdict(record),
            jid,
            task_id=task_id,
            owner="syvax",
            status="ACTIVE",
            record_id=jid,
        )

        self.event(
            "JOURNEY_CREATED",
            jid,
            actor="syvax",
            task_id=task_id,
            inputs={"problem": problem},
        )

        return record

    def chat(
        self,
        journey_id: str,
        *,
        character: str,
        message: str,
        task_id: str | None = None,
    ) -> str:
        return self._record(
            "chat",
            {
                "id": uid("CHAT"),
                "character": character,
                "message": message,
                "timestamp": now(),
            },
            journey_id,
            task_id=task_id,
            owner=character,
        )

    def record_evidence(self, record: EvidenceRecord) -> str:
        if (
            record.verification_status == "VERIFIED"
            and not record.provenance.get("verification_id")
        ):
            raise ValueError(
                "Evidence cannot be VERIFIED without a verification reference."
            )

        return self._record(
            "evidence",
            asdict(record),
            record.journey_id,
            task_id=record.task_id,
            owner=record.collected_by,
            status=record.verification_status,
            record_id=record.evidence_id,
        )

    def _journey_for(self, target_id: str) -> str:
        existing = self.store.get(target_id)
        return existing["_journey_id"] if existing else "UNBOUND"

    def record_verification(
        self,
        record: VerificationRecord,
        *,
        task_id: str | None = None,
    ) -> str:
        return self._record(
            "verification",
            asdict(record),
            self._journey_for(record.target_id),
            task_id=task_id,
            owner=record.verifier,
            status=record.result,
            record_id=record.verification_id,
        )

    def record_reasoning(self, record: ReasoningExplanation) -> str:
        return self._record(
            "reasoning",
            asdict(record),
            record.journey_id,
            owner="vivren",
            record_id=record.reasoning_id,
        )

    def record_hypothesis(self, record: HypothesisRecord) -> str:
        if record.status == "VERIFIED":
            raise ValueError(
                "Hypotheses cannot be marked VERIFIED directly."
            )

        return self._record(
            "hypothesis",
            asdict(record),
            record.journey_id,
            owner="tarkis",
            status=record.status,
            record_id=record.hypothesis_id,
        )

    def record_challenge(self, record: ChallengeRecord) -> str:
        return self._record(
            "challenge",
            asdict(record),
            record.journey_id,
            owner="manis",
            status=record.resolution_status,
            record_id=record.challenge_id,
        )

    def record_decision(self, record: DecisionRecord) -> str:
        if record.selected_option and not record.human_actor:
            raise ValueError(
                "A selected decision must identify the human decision-maker."
            )

        return self._record(
            "decision",
            asdict(record),
            record.journey_id,
            owner="pramon",
            record_id=record.decision_id,
        )

    def record_outcome(self, record: OutcomeRecord) -> str:
        if (
            record.success_status == "SUCCESSFUL"
            and record.verification_status != "VERIFIED"
        ):
            raise ValueError(
                "SUCCESSFUL outcome requires VERIFIED status."
            )

        return self._record(
            "outcome",
            asdict(record),
            record.journey_id,
            task_id=record.task_id,
            owner="veridat",
            status=record.success_status,
            record_id=record.outcome_id,
        )

    def record_knowledge(self, record: KnowledgeRecord) -> str:
        if (
            record.maturity in {"VERIFIED", "REUSABLE"}
            and not record.verification_refs
        ):
            raise ValueError(
                "Verified/reusable knowledge requires verification references."
            )

        return self._record(
            "knowledge",
            asdict(record),
            record.journey_id,
            owner="viveda",
            status=record.maturity,
            record_id=record.knowledge_id,
        )

    def record_adaptation(self, record: AdaptationRecord) -> str:
        return self._record(
            "adaptation",
            asdict(record),
            record.journey_id,
            owner="anuka",
            status=record.status,
            record_id=record.adaptation_id,
        )

    def record_transfer(self, record: TransferRecord) -> str:
        return self._record(
            "transfer",
            asdict(record),
            record.journey_id,
            owner="anukor",
            status=record.status,
            record_id=record.transfer_id,
        )

    def dependency_status(
        self,
        journey_id: str,
        changed_record_id: str,
    ) -> dict[str, Any]:
        rows = self.store.list(journey_id=journey_id)

        affected = [
            str(row.get("id"))
            for row in rows
            if changed_record_id in json.dumps(row, sort_keys=True)
            and row.get("id") != changed_record_id
        ]

        return {
            "changed": [changed_record_id],
            "affected": [item for item in affected if item != "None"],
            "status": "REQUIRES_REVIEW" if affected else "VALID",
        }

    def inspect_journey(self, journey_id: str) -> dict[str, Any]:
        rows = self.store.list(journey_id=journey_id)

        if not rows:
            return {
                "journey_id": journey_id,
                "status": "NOT_RECORDED",
            }

        grouped: dict[str, list[dict[str, Any]]] = {
            key: [] for key in self.RECORD_TYPES
        }

        for row in rows:
            grouped.setdefault(row["_record_type"], []).append(row)

        return {
            "journey_id": journey_id,
            "journey": (
                grouped["journey"][0]
                if grouped["journey"]
                else None
            ),
            "stages": {
                key: (values or [{"status": "NOT_RECORDED"}])
                for key, values in grouped.items()
            },
            "record_count": len(rows),
        }

    def character_answer(
        self,
        character_id: str,
        question: str,
        *,
        journey_id: str | None = None,
    ) -> str:
        rows = (
            self.store.list(journey_id=journey_id)
            if journey_id
            else []
        )

        answers = {
            "syvax": (
                "I can explain recorded journey and routing state; "
                "I will not invent evidence or execution records."
            ),
            "dharen": (
                "I can report recorded context and dependencies; "
                "I will not claim context that is not stored."
            ),
            "sandre": (
                "I can report recorded data sources and provenance; "
                "I cannot invent source provenance."
            ),
            "kaelen": (
                "I can explain recorded transformations and experimental "
                "outputs; experimental material is not automatically canonical."
            ),
            "anuka": (
                "I can report recorded context adaptations and triggers; "
                "I do not silently adapt context."
            ),
            "vivren": (
                "I can provide structured reasoning summaries with evidence, "
                "assumptions, alternatives, contradictions, uncertainty and "
                "limitations. Hidden chain-of-thought is not exposed."
            ),
            "tarkis": (
                "I can report hypotheses and alternatives with their status. "
                "A hypothesis remains distinct from a verified finding."
            ),
            "pramon": (
                "I can report recommendations and decision structure. "
                "A human-selected option is only claimed when a human "
                "decision record exists."
            ),
            "bodhex": (
                "I can report prepared action contracts and execution records. "
                "Preparing an action is not execution."
            ),
            "medrus": (
                "I can report evidence records, observations and limitations. "
                "Acquisition is not verification."
            ),
            "epistre": (
                "I can trace recorded provenance and explanation lineage. "
                "Incomplete lineage remains incomplete."
            ),
            "manis": (
                "I can report persisted human challenges. "
                "I cannot make the human decision."
            ),
            "viveda": (
                "I can report consolidated knowledge and its evidence "
                "and verification references."
            ),
            "anukor": (
                "I can report recorded cross-home transfers, compatibility, "
                "adaptation and rejection. Sending a message is not "
                "transfer success."
            ),
        }

        if character_id == "veridat":
            verifications = [
                row
                for row in rows
                if row["_record_type"] == "verification"
            ]

            return (
                "Recorded verification: "
                + "; ".join(
                    str(row.get("result"))
                    for row in verifications
                )
                if verifications
                else
                "No authoritative verification record exists "
                "for this journey yet."
            )

        return answers.get(
            character_id,
            "No grounded responsibility record is available for this character.",
        )