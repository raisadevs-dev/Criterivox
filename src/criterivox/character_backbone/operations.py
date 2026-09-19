"""Set 3 governed operational bridge.

Natural language is never an execution boundary. Commands pass through
capability discovery, authorization, an inspectable action contract, an
adapter, result capture, verification, and durable S8 provenance.
"""

from __future__ import annotations

import hashlib
import json
import os
import shutil
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path
from typing import Any, Mapping, Protocol
from uuid import uuid4

from criterivox.s8.models import Artifact, ArtifactKind, BureauEvent
from criterivox.s8.persistence import S8SQLiteStore


ROOT = Path(__file__).resolve().parents[3]
STORE_PATH = ROOT / "data" / "s8" / "character_operations.sqlite3"
STORE_PATH.parent.mkdir(parents=True, exist_ok=True)


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def uid(prefix: str) -> str:
    return f"{prefix}-{uuid4()}"


class Op(str, Enum):
    QUERY = "QUERY"
    EXPLAIN = "EXPLAIN"
    RECOMMEND = "RECOMMEND"
    MODIFY = "MODIFY"
    CREATE = "CREATE"
    MOVE = "MOVE"
    DELETE = "DELETE"
    EXECUTE = "EXECUTE"
    VERIFY = "VERIFY"
    CANCEL = "CANCEL"
    PAUSE = "PAUSE"
    RESUME = "RESUME"
    TRANSFER = "TRANSFER"


class Decision(str, Enum):
    UNDERSTAND = "UNDERSTAND"
    ANSWER = "ANSWER"
    RECOMMEND = "RECOMMEND"
    REQUEST_APPROVAL = "REQUEST_APPROVAL"
    EXECUTE = "EXECUTE"
    VERIFY = "VERIFY"


class Auth(str, Enum):
    NO_AUTH_REQUIRED = "NO_AUTH_REQUIRED"
    AUTH_REQUIRED = "AUTH_REQUIRED"
    AUTH_PENDING = "AUTH_PENDING"
    AUTHORIZED = "AUTHORIZED"
    DENIED = "DENIED"
    EXPIRED = "EXPIRED"
    REVOKED = "REVOKED"
    NOT_SUPPORTED = "NOT_SUPPORTED"


class Approval(str, Enum):
    APPROVAL_NOT_REQUIRED = "APPROVAL_NOT_REQUIRED"
    APPROVAL_REQUIRED = "APPROVAL_REQUIRED"
    APPROVAL_REQUESTED = "APPROVAL_REQUESTED"
    APPROVED = "APPROVED"
    REJECTED = "REJECTED"
    EXPIRED = "EXPIRED"
    CANCELLED = "CANCELLED"


class Lifecycle(str, Enum):
    REQUESTED = "REQUESTED"
    UNDERSTOOD = "UNDERSTOOD"
    CAPABILITY_RESOLVED = "CAPABILITY_RESOLVED"
    AUTHORIZATION_REQUIRED = "AUTHORIZATION_REQUIRED"
    AUTHORIZED = "AUTHORIZED"
    PLANNED = "PLANNED"
    READY = "READY"
    EXECUTING = "EXECUTING"
    RESULT_CAPTURED = "RESULT_CAPTURED"
    VERIFYING = "VERIFYING"
    VERIFIED = "VERIFIED"
    COMPLETE = "COMPLETE"
    BLOCKED = "BLOCKED"
    DENIED = "DENIED"
    CANCELLED = "CANCELLED"
    FAILED = "FAILED"
    PARTIALLY_SUCCEEDED = "PARTIALLY_SUCCEEDED"
    VERIFICATION_FAILED = "VERIFICATION_FAILED"
    UNKNOWN = "UNKNOWN"
    REEVALUATION_REQUIRED = "REEVALUATION_REQUIRED"


class ExecStatus(str, Enum):
    NOT_STARTED = "NOT_STARTED"
    PREPARING = "PREPARING"
    RUNNING = "RUNNING"
    SUCCEEDED = "SUCCEEDED"
    FAILED = "FAILED"
    PARTIALLY_SUCCEEDED = "PARTIALLY_SUCCEEDED"
    CANCELLED = "CANCELLED"
    TIMED_OUT = "TIMED_OUT"
    BLOCKED = "BLOCKED"
    UNKNOWN = "UNKNOWN"


class Verification(str, Enum):
    VERIFIED = "VERIFIED"
    NOT_VERIFIED = "NOT_VERIFIED"
    PARTIALLY_VERIFIED = "PARTIALLY_VERIFIED"
    VERIFICATION_FAILED = "VERIFICATION_FAILED"
    VERIFICATION_UNAVAILABLE = "VERIFICATION_UNAVAILABLE"


@dataclass(frozen=True)
class CapabilitySpec:
    capability_id: str
    name: str
    owner_character: str
    status: str = "CURRENT"
    authorization_required: bool = True
    supported_operations: tuple[str, ...] = ()
    required_permissions: tuple[str, ...] = ()
    verification_method: str = "adapter_inspection"
    adapter: str | None = None
    description: str = ""


@dataclass(frozen=True)
class Command:
    command_id: str
    conversation_id: str
    journey_id: str
    task_id: str
    created_at: str
    requested_by: str
    raw_message: str
    normalized_request: str
    intent: str
    entities: Mapping[str, Any]
    target_reference: str | None
    requested_capability: str | None
    responsible_character: str | None
    operation_type: str
    decision_state: str
    authorization_state: str
    execution_state: str
    verification_state: str
    status: str
    provenance: Mapping[str, Any] = field(default_factory=dict)
    created_from_event: str | None = None
    supersedes_command: str | None = None
    parent_command: str | None = None


@dataclass(frozen=True)
class AuthorizationRecord:
    authorization_id: str
    journey_id: str
    task_id: str
    command_id: str
    requested_by: str
    requested_action: str
    target: str | None
    scope: str
    risk_level: str
    authorization_state: str
    authorized_at: str | None
    expires_at: str | None
    decision_source: str
    human_confirmation: bool
    provenance: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class ActionContract:
    action_id: str
    command_id: str
    journey_id: str
    task_id: str
    capability_id: str
    operation: str
    actor: str
    target: str | None
    parameters: Mapping[str, Any]
    preconditions: tuple[str, ...]
    authorization_reference: str | None
    expected_effect: str
    expected_output: Mapping[str, Any]
    adapter_reference: str
    timeout: float | None
    retry_policy: Mapping[str, Any]
    verification_method: str
    provenance_requirements: tuple[str, ...]
    status: str = "ACTION_PREPARED"
    idempotency_key: str = ""


@dataclass(frozen=True)
class ExecutionResult:
    execution_id: str
    action_id: str
    started_at: str | None
    completed_at: str | None
    status: str
    adapter: str
    target: str | None
    requested_operation: str
    actual_operation: str | None
    output: Mapping[str, Any] = field(default_factory=dict)
    error: str | None = None
    external_reference: str | None = None
    observed_effect: Mapping[str, Any] = field(default_factory=dict)
    verification_status: str = Verification.VERIFICATION_UNAVAILABLE.value
    provenance: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class VerificationResult:
    verification_id: str
    action_id: str
    status: str
    evidence: Mapping[str, Any]
    checked_at: str
    limitation: str | None = None


class ActionAdapter(Protocol):
    name: str

    def prepare(
        self,
        action: ActionContract,
    ) -> Mapping[str, Any]:
        ...

    def validate(
        self,
        action: ActionContract,
    ) -> tuple[bool, str | None]:
        ...

    def execute(
        self,
        action: ActionContract,
    ) -> ExecutionResult:
        ...

    def cancel(
        self,
        action: ActionContract,
    ) -> ExecutionResult:
        ...

    def inspect(
        self,
        action: ActionContract,
    ) -> Mapping[str, Any]:
        ...

    def verify(
        self,
        action: ActionContract,
        result: ExecutionResult,
    ) -> VerificationResult:
        ...


class LocalFilesystemAdapter:
    name = "filesystem.local"

    def prepare(self, action):
        return {
            "adapter": self.name,
            "target": action.target,
            "operation": action.operation,
        }

    def validate(self, action):
        if action.operation != Op.MOVE.value:
            return False, "Adapter supports MOVE only."

        source = str(
            action.parameters.get("source", "")
        ).strip()

        destination = str(
            action.parameters.get("destination", "")
        ).strip()

        if not source or not destination:
            return False, "source and destination are required."

        if not os.path.exists(source):
            return False, "source does not exist."

        return True, None

    def execute(self, action):
        started = now()

        source = str(action.parameters["source"])
        destination = str(action.parameters["destination"])

        try:
            Path(destination).parent.mkdir(
                parents=True,
                exist_ok=True,
            )

            shutil.move(source, destination)

            observed = {
                "source_exists": os.path.exists(source),
                "destination_exists": os.path.exists(destination),
            }

            return ExecutionResult(
                uid("EX"),
                action.action_id,
                started,
                now(),
                ExecStatus.SUCCEEDED.value,
                self.name,
                action.target,
                action.operation,
                action.operation,
                {
                    "destination": destination,
                },
                None,
                None,
                observed,
            )

        except Exception as exc:
            return ExecutionResult(
                uid("EX"),
                action.action_id,
                started,
                now(),
                ExecStatus.FAILED.value,
                self.name,
                action.target,
                action.operation,
                action.operation,
                {},
                str(exc),
            )

    def cancel(self, action):
        return ExecutionResult(
            uid("EX"),
            action.action_id,
            now(),
            now(),
            ExecStatus.CANCELLED.value,
            self.name,
            action.target,
            action.operation,
            None,
            {},
            "Cancellation requested before adapter execution.",
        )

    def inspect(self, action):
        destination = str(
            action.parameters.get("destination", "")
        )

        return {
            "destination_exists": bool(
                destination
                and os.path.exists(destination)
            ),
            "destination": destination,
        }

    def verify(self, action, result):
        destination = str(
            action.parameters.get("destination", "")
        )

        exists = bool(
            destination
            and os.path.exists(destination)
        )

        return VerificationResult(
            uid("VR"),
            action.action_id,
            (
                Verification.VERIFIED.value
                if exists
                else Verification.NOT_VERIFIED.value
            ),
            {
                "destination": destination,
                "exists": exists,
            },
            now(),
            (
                None
                if exists
                else (
                    "Authoritative filesystem inspection did not "
                    "find the destination."
                )
            ),
        )


class CapabilityRegistry:
    def __init__(self, specs=()):
        self._specs = {
            spec.capability_id: spec
            for spec in specs
        }

    def register(self, spec):
        self._specs[spec.capability_id] = spec

    def get(self, capability_id):
        return self._specs.get(capability_id)

    def all(self):
        return tuple(self._specs.values())

    def discover(self, operation):
        return tuple(
            spec
            for spec in self._specs.values()
            if (
                operation in spec.supported_operations
                and spec.status == "CURRENT"
            )
        )


DEFAULT_CAPABILITIES = (
    CapabilitySpec(
        "artifact.move",
        "Move local artifact",
        "bodhex",
        "CURRENT",
        True,
        (Op.MOVE.value,),
        ("artifact.write",),
        "filesystem inspection",
        "filesystem.local",
        "Bounded local filesystem move.",
    ),
    CapabilitySpec(
        "artifact.verify",
        "Verify local artifact state",
        "veridat",
        "CURRENT",
        False,
        (Op.VERIFY.value,),
        (),
        "filesystem inspection",
        "filesystem.local",
        "Bounded local filesystem verification.",
    ),
)


class OperationStore:
    """S8 SQLite-backed operational record adapter.

    The store opens a short-lived SQLite connection for each persistence
    operation. This prevents temporary test databases from remaining locked
    by an open SQLite connection, particularly on Windows.
    """

    def __init__(
        self,
        path: str | Path = STORE_PATH,
    ):
        self.path = Path(path)

    def _open(self) -> S8SQLiteStore:
        return S8SQLiteStore(self.path)

    def artifact(
        self,
        kind,
        payload,
        parent_ids=(),
    ):
        artifact_id = uid("S3A")

        artifact = Artifact(
            artifact_id,
            kind,
            dict(payload),
            parent_ids=tuple(parent_ids),
            status="authoritative",
        )

        store = self._open()

        try:
            store.save_artifact(artifact)
        finally:
            store.close()

        return artifact

    def event(
        self,
        event_type,
        payload,
        actor="system",
        caused_by=None,
        parent_event=None,
        artifact_ids=(),
    ):
        event_id = uid("S3E")

        body = dict(payload)
        body.update(
            {
                "caused_by": caused_by,
                "parent_event": parent_event,
            }
        )

        event = BureauEvent(
            event_id,
            event_type,
            tuple(artifact_ids),
            actor,
            occurred_at=datetime.now(timezone.utc),
            payload=body,
        )

        store = self._open()

        try:
            store.save_event(event)
        finally:
            store.close()

        return event

    def events_for(self, command_id):
        store = self._open()

        try:
            rows = store.connection.execute(
                "SELECT * FROM events ORDER BY occurred_at"
            ).fetchall()

            events = []

            for row in rows:
                body = json.loads(
                    row["payload_json"]
                )

                if body.get("command_id") != command_id:
                    continue

                events.append(
                    BureauEvent(
                        row["event_id"],
                        row["event_type"],
                        tuple(
                            json.loads(
                                row["artifact_ids_json"]
                            )
                        ),
                        row["actor"],
                        row["tenant_id"],
                        row["context_id"],
                        datetime.fromisoformat(
                            row["occurred_at"]
                        ),
                        body,
                    )
                )

            return events

        finally:
            store.close()

    def close(self):
        """Compatibility method for callers that explicitly close stores."""
        return None


class OperationEngine:
    def __init__(
        self,
        *,
        store=None,
        registry=None,
    ):
        self.store = store or OperationStore()

        self.registry = (
            registry
            or CapabilityRegistry(DEFAULT_CAPABILITIES)
        )

        self.adapters = {
            "filesystem.local": LocalFilesystemAdapter(),
        }

        self.commands = {}
        self.authorizations = {}
        self.actions = {}
        self.executions = {}
        self.verifications = {}

    def _event(
        self,
        typ,
        cmd,
        actor="system",
        **extra,
    ):
        return self.store.event(
            typ,
            {
                "command_id": cmd.command_id,
                "journey_id": cmd.journey_id,
                "task_id": cmd.task_id,
                **extra,
            },
            actor=actor,
        )

    def _record_command(self, cmd):
        self.commands[cmd.command_id] = cmd

        self.store.artifact(
            ArtifactKind.AUDIT,
            {
                "record_type": "COMMAND",
                "command_id": cmd.command_id,
                **asdict(cmd),
            },
        )

        self._event(
            "COMMAND_CREATED",
            cmd,
            actor=cmd.requested_by,
            intent=cmd.intent,
            operation=cmd.operation_type,
        )

    @staticmethod
    def classify(message):
        text = message.strip()
        low = text.lower()

        if not text:
            return "EMPTY", Op.QUERY, {}

        if low in {
            "approve",
            "approve this",
            "authorize",
            "authorize this",
        }:
            return "APPROVE", Op.EXECUTE, {}

        if low in {
            "reject",
            "reject this",
            "deny",
        }:
            return "REJECT", Op.CANCEL, {}

        if low in {
            "cancel",
            "cancel this",
            "stop",
        }:
            return "CANCEL", Op.CANCEL, {}

        if low in {
            "pause",
            "pause this",
            "pause it",
        }:
            return "PAUSE", Op.PAUSE, {}

        if low in {
            "resume",
            "resume this",
            "resume it",
        }:
            return "RESUME", Op.RESUME, {}

        if (
            "verify" in low
            or "did it actually happen" in low
        ):
            return "VERIFY", Op.VERIFY, {}

        if (
            "what can you do" in low
            or "what capability" in low
        ):
            return (
                "CAPABILITY_DISCOVERY",
                Op.QUERY,
                {},
            )

        if (
            "show the plan" in low
            or "action plan" in low
        ):
            return "SHOW_PLAN", Op.EXPLAIN, {}

        if "action contract" in low:
            return "SHOW_CONTRACT", Op.EXPLAIN, {}

        if (
            "what permission" in low
            or "requires approval" in low
        ):
            return (
                "AUTHORIZATION_QUERY",
                Op.QUERY,
                {},
            )

        if "why is this blocked" in low:
            return "BLOCKED_QUERY", Op.QUERY, {}

        if (
            low.startswith("change ")
            or "new requirement" in low
            or "somewhere else" in low
        ):
            return (
                "CHANGE_REQUESTED",
                Op.MODIFY,
                {"raw_change": text},
            )

        if (
            low.startswith("move ")
            or "move this" in low
            or "prepare moving" in low
            or "prepare to move" in low
        ):
            return (
                "MOVE_ARTIFACT",
                Op.MOVE,
                {"raw_target": text},
            )

        return "GENERAL_QUERY", Op.QUERY, {}

    def _replace(
        self,
        cmd,
        **changes,
    ):
        value = asdict(cmd)
        value.update(changes)
        return Command(**value)

    def create_command(
        self,
        message,
        *,
        conversation_id,
        journey_id=None,
        task_id=None,
        requested_by="human",
        context=None,
    ):
        intent, operation, entities = self.classify(message)

        command_id = uid("CMD")
        journey = (
            journey_id
            or f"J-{conversation_id}"
        )
        task = (
            task_id
            or f"T-{conversation_id}"
        )

        context_data = (
            context
            if isinstance(context, Mapping)
            else {}
        )

        target = str(
            context_data.get("target_reference")
            or context_data.get("artifact_id")
            or ""
        ).strip() or None

        if operation is Op.MOVE:
            entities = {
                **entities,
                "target": target,
                "destination": context_data.get(
                    "destination"
                ),
                "source": context_data.get("source"),
            }

        command = Command(
            command_id,
            conversation_id,
            journey,
            task,
            now(),
            requested_by,
            message.strip(),
            message.strip(),
            intent,
            entities,
            target,
            None,
            None,
            operation.value,
            Decision.UNDERSTAND.value,
            Auth.NO_AUTH_REQUIRED.value,
            ExecStatus.NOT_STARTED.value,
            Verification.VERIFICATION_UNAVAILABLE.value,
            Lifecycle.REQUESTED.value,
            {
                "source": "character-chat",
                "classification": "deterministic",
            },
        )

        self._record_command(command)

        self._event(
            "COMMAND_PARSED",
            command,
            intent=intent,
            entities=entities,
        )

        return command

    def discover(self, cmd):
        capabilities = self.registry.discover(
            cmd.operation_type
        )

        if not capabilities:
            self._event(
                "CAPABILITY_DISCOVERED",
                cmd,
                capability=None,
                status="NOT_IMPLEMENTED",
            )

            return self._replace(
                cmd,
                status=Lifecycle.BLOCKED.value,
                requested_capability=None,
                authorization_state=Auth.NOT_SUPPORTED.value,
                responsible_character=None,
            )

        capability = capabilities[0]

        self._event(
            "CAPABILITY_DISCOVERED",
            cmd,
            capability=capability.capability_id,
            status=capability.status,
            owner_character=capability.owner_character,
        )

        authorization = (
            Auth.AUTH_REQUIRED
            if capability.authorization_required
            else Auth.NO_AUTH_REQUIRED
        )

        return self._replace(
            cmd,
            requested_capability=capability.capability_id,
            responsible_character=capability.owner_character,
            authorization_state=authorization.value,
            status=(
                Lifecycle.AUTHORIZATION_REQUIRED.value
                if authorization is Auth.AUTH_REQUIRED
                else Lifecycle.PLANNED.value
            ),
            decision_state=(
                Decision.REQUEST_APPROVAL.value
                if authorization is Auth.AUTH_REQUIRED
                else Decision.EXECUTE.value
            ),
        )

    def request_authorization(
        self,
        cmd,
        risk_level="CONSEQUENTIAL",
    ):
        authorization_id = uid("AUTH")

        record = AuthorizationRecord(
            authorization_id,
            cmd.journey_id,
            cmd.task_id,
            cmd.command_id,
            cmd.requested_by,
            cmd.operation_type,
            cmd.target_reference,
            "task-scope",
            risk_level,
            Auth.AUTH_PENDING.value,
            None,
            None,
            "human-explicit",
            False,
            {
                "recorded_at": now(),
            },
        )

        self.authorizations[
            authorization_id
        ] = record

        self.store.artifact(
            ArtifactKind.AUDIT,
            {
                "record_type": "AUTHORIZATION",
                "authorization_id": authorization_id,
                **asdict(record),
            },
        )

        self._event(
            "AUTHORIZATION_REQUIRED",
            cmd,
            authorization_id=authorization_id,
            risk_level=risk_level,
        )

        self._event(
            "AUTHORIZATION_REQUESTED",
            cmd,
            authorization_id=authorization_id,
        )

        return record

    def approve(
        self,
        command_id,
        actor="human",
    ):
        cmd = self.commands[command_id]

        record = next(
            (
                item
                for item in self.authorizations.values()
                if item.command_id == command_id
            ),
            None,
        )

        if record is None:
            return {
                "classification": "NOT_AUTHORIZED",
                "message": "No approval record exists.",
            }

        record = AuthorizationRecord(
            record.authorization_id,
            record.journey_id,
            record.task_id,
            record.command_id,
            record.requested_by,
            record.requested_action,
            record.target,
            record.scope,
            record.risk_level,
            Auth.AUTHORIZED.value,
            now(),
            record.expires_at,
            actor,
            True,
            record.provenance,
        )

        self.authorizations[
            record.authorization_id
        ] = record

        self.store.artifact(
            ArtifactKind.AUDIT,
            {
                "record_type": "AUTHORIZATION",
                "authorization_id": record.authorization_id,
                **asdict(record),
            },
        )

        cmd = self._replace(
            cmd,
            authorization_state=Auth.AUTHORIZED.value,
            status=Lifecycle.AUTHORIZED.value,
            decision_state=Decision.EXECUTE.value,
        )

        self.commands[cmd.command_id] = cmd

        self._event(
            "AUTHORIZATION_GRANTED",
            cmd,
            actor=actor,
            authorization_id=record.authorization_id,
        )

        try:
            action = self.prepare(
                cmd,
                authorization_reference=record.authorization_id,
            )
        except RuntimeError as exc:
            return (
                self.snapshot(cmd.command_id)
                | {
                    "classification": str(exc).split(":")[0],
                }
            )

        return self.execute(action.action_id)

    def reject(
        self,
        command_id,
        actor="human",
    ):
        cmd = self.commands[command_id]

        record = next(
            (
                item
                for item in self.authorizations.values()
                if item.command_id == command_id
            ),
            None,
        )

        if record:
            self.authorizations[
                record.authorization_id
            ] = AuthorizationRecord(
                **{
                    **asdict(record),
                    "authorization_state": Auth.DENIED.value,
                    "decision_source": actor,
                    "human_confirmation": True,
                }
            )

        cmd = self._replace(
            cmd,
            authorization_state=Auth.DENIED.value,
            status=Lifecycle.DENIED.value,
        )

        self.commands[command_id] = cmd

        self._event(
            "AUTHORIZATION_DENIED",
            cmd,
            actor=actor,
        )

        return cmd

    def prepare(
        self,
        cmd,
        authorization_reference=None,
    ):
        if not cmd.requested_capability:
            raise RuntimeError("NOT_IMPLEMENTED")

        capability = self.registry.get(
            cmd.requested_capability
        )

        if (
            capability is None
            or capability.status != "CURRENT"
        ):
            raise RuntimeError("NOT_IMPLEMENTED")

        if (
            capability.authorization_required
            and cmd.authorization_state
            != Auth.AUTHORIZED.value
        ):
            raise RuntimeError("NOT_AUTHORIZED")

        if (
            not capability.adapter
            or capability.adapter not in self.adapters
        ):
            raise RuntimeError("NOT_IMPLEMENTED")

        action = ActionContract(
            uid("ACT"),
            cmd.command_id,
            cmd.journey_id,
            cmd.task_id,
            capability.capability_id,
            cmd.operation_type,
            capability.owner_character,
            cmd.target_reference,
            dict(cmd.entities),
            (
                "capability_available",
                "target_resolved",
                "inputs_available",
                "authorization_valid",
                "task_active",
                "dependencies_satisfied",
                "adapter_available",
            ),
            authorization_reference,
            "perform " + cmd.operation_type,
            {},
            capability.adapter,
            30,
            {
                "max_retries": 0,
            },
            capability.verification_method,
            ("S8_EVENT_LINEAGE",),
            "ACTION_PREPARED",
            uid("IDEMP"),
        )

        ok, reason = self.adapters[
            capability.adapter
        ].validate(action)

        self.store.artifact(
            ArtifactKind.AUDIT,
            {
                "record_type": "ACTION_CONTRACT",
                "action_id": action.action_id,
                **asdict(action),
            },
        )

        self._event(
            "ACTION_CONTRACT_CREATED",
            cmd,
            action_id=action.action_id,
            adapter=capability.adapter,
        )

        if not ok:
            self._event(
                "ACTION_PRECONDITION_FAILED",
                cmd,
                action_id=action.action_id,
                reason=reason,
            )
            raise RuntimeError(
                "BLOCKED:" + str(reason)
            )

        self.actions[action.action_id] = action

        cmd = self._replace(
            cmd,
            status=Lifecycle.READY.value,
        )

        self.commands[cmd.command_id] = cmd

        self._event(
            "ACTION_PLANNED",
            cmd,
            action_id=action.action_id,
        )

        return action

    def execute(self, action_id):
        action = self.actions[action_id]
        cmd = self.commands[action.command_id]

        self._event(
            "ACTION_SUBMITTED",
            cmd,
            action_id=action_id,
        )

        self._event(
            "ACTION_STARTED",
            cmd,
            action_id=action_id,
        )

        result = self.adapters[
            action.adapter_reference
        ].execute(action)

        self.executions[
            result.execution_id
        ] = result

        self.store.artifact(
            ArtifactKind.AUDIT,
            {
                "record_type": "EXECUTION_RESULT",
                "execution_id": result.execution_id,
                **asdict(result),
            },
        )

        cmd = self._replace(
            cmd,
            status=(
                Lifecycle.RESULT_CAPTURED.value
                if result.status
                == ExecStatus.SUCCEEDED.value
                else Lifecycle.FAILED.value
            ),
            execution_state=result.status,
        )

        self.commands[
            cmd.command_id
        ] = cmd

        self._event(
            (
                "ACTION_COMPLETED"
                if result.status
                == ExecStatus.SUCCEEDED.value
                else "ACTION_FAILED"
            ),
            cmd,
            execution_id=result.execution_id,
            error=result.error,
        )

        verification = self.verify(
            action_id,
            result,
        )

        return (
            self.snapshot(cmd.command_id)
            | {
                "execution": asdict(result),
                "verification": asdict(
                    verification
                ),
            }
        )

    def verify(
        self,
        action_id,
        result,
    ):
        action = self.actions[action_id]
        cmd = self.commands[action.command_id]

        self._event(
            "VERIFICATION_STARTED",
            cmd,
            action_id=action_id,
        )

        if (
            result.status
            == ExecStatus.SUCCEEDED.value
        ):
            verification = self.adapters[
                action.adapter_reference
            ].verify(
                action,
                result,
            )
        else:
            verification = VerificationResult(
                uid("VR"),
                action_id,
                Verification.NOT_VERIFIED.value,
                {
                    "execution_status": result.status,
                },
                now(),
                "Execution did not produce a successful effect.",
            )

        self.verifications[
            verification.verification_id
        ] = verification

        self.store.artifact(
            ArtifactKind.VERIFICATION,
            {
                "record_type": "VERIFICATION",
                "verification_id": verification.verification_id,
                **asdict(verification),
            },
            parent_ids=(action_id,),
        )

        cmd = self._replace(
            cmd,
            verification_state=verification.status,
            status=(
                Lifecycle.VERIFIED.value
                if verification.status
                == Verification.VERIFIED.value
                else Lifecycle.VERIFICATION_FAILED.value
            ),
            decision_state=Decision.VERIFY.value,
        )

        self.commands[
            cmd.command_id
        ] = cmd

        self._event(
            (
                "VERIFICATION_COMPLETED"
                if verification.status
                == Verification.VERIFIED.value
                else "VERIFICATION_FAILED"
            ),
            cmd,
            verification_id=verification.verification_id,
            status=verification.status,
        )

        return verification

    def change(
        self,
        command_id,
        message,
    ):
        cmd = self._replace(
            self.commands[command_id],
            status=Lifecycle.REEVALUATION_REQUIRED.value,
        )

        self.commands[command_id] = cmd

        self._event(
            "CHANGE_REQUESTED",
            cmd,
            change=message,
            reason=(
                "Existing plan may be stale; "
                "re-evaluation is required."
            ),
        )

        return cmd

    def snapshot(self, command_id):
        cmd = self.commands[command_id]

        action = next(
            (
                item
                for item in self.actions.values()
                if item.command_id == command_id
            ),
            None,
        )

        authorization = next(
            (
                item
                for item in self.authorizations.values()
                if item.command_id == command_id
            ),
            None,
        )

        return {
            "message_type": "operation_state",
            "command": asdict(cmd),
            "authorization": (
                asdict(authorization)
                if authorization
                else None
            ),
            "action": (
                asdict(action)
                if action
                else None
            ),
            "events": [
                asdict(event)
                for event in self.store.events_for(
                    command_id
                )
            ],
        }

    def handle(self, payload):
        message = str(
            payload.get("message", "")
        ).strip()

        context = payload.get("context")

        cmd = self.create_command(
            message,
            conversation_id=str(
                payload.get(
                    "conversation_id",
                    "chat",
                )
            ),
            journey_id=payload.get(
                "journey_id"
            ),
            task_id=payload.get(
                "task_id"
            ),
            requested_by=str(
                payload.get(
                    "requested_by",
                    "human",
                )
            ),
            context=(
                context
                if isinstance(
                    context,
                    Mapping,
                )
                else {}
            ),
        )

        if cmd.intent == "CAPABILITY_DISCOVERY":
            return {
                "message_type": "operation_state",
                "classification": "RECORDED_FACT",
                "capabilities": [
                    asdict(capability)
                    for capability
                    in self.registry.all()
                ],
            }

        if cmd.intent == "VERIFY":
            return (
                self.snapshot(cmd.command_id)
                | {
                    "classification": "UNKNOWN",
                    "message": (
                        "No existing action was resolved "
                        "for this verification request; "
                        "execution state is not established."
                    ),
                }
            )

        if cmd.intent == "AUTHORIZATION_QUERY":
            return (
                self.snapshot(cmd.command_id)
                | {
                    "classification": "RECORDED_FACT",
                    "message": (
                        "Consequential operations require "
                        "explicit authorization."
                    ),
                }
            )

        if cmd.intent == "BLOCKED_QUERY":
            return (
                self.snapshot(cmd.command_id)
                | {
                    "classification": "RECORDED_FACT",
                    "message": (
                        "The operation is blocked until "
                        "recorded preconditions are satisfied."
                    ),
                }
            )

        if cmd.intent == "CHANGE_REQUESTED":
            return (
                asdict(
                    self.change(
                        cmd.command_id,
                        message,
                    )
                )
                | {
                    "message_type": "operation_state",
                    "classification": (
                        "REEVALUATION_REQUIRED"
                    ),
                }
            )

        if cmd.intent in {
            "APPROVE",
            "REJECT",
            "CANCEL",
        }:
            return (
                self.snapshot(cmd.command_id)
                | {
                    "classification": (
                        "REQUEST_CLARIFICATION"
                    ),
                    "message": (
                        "An existing command_id is required "
                        "for an approval, rejection, "
                        "or cancellation."
                    ),
                }
            )

        cmd = self.discover(cmd)

        self.commands[
            cmd.command_id
        ] = cmd

        if cmd.status == Lifecycle.BLOCKED.value:
            return (
                self.snapshot(cmd.command_id)
                | {
                    "classification": "NOT_IMPLEMENTED"
                }
            )

        if (
            cmd.authorization_state
            == Auth.AUTH_REQUIRED.value
        ):
            authorization = (
                self.request_authorization(cmd)
            )

            # The policy has been resolved and an actual
            # authorization request now exists. The command
            # therefore moves from AUTH_REQUIRED to AUTH_PENDING.
            cmd = self._replace(
                cmd,
                authorization_state=(
                    Auth.AUTH_PENDING.value
                ),
                status=(
                    Lifecycle.AUTHORIZATION_REQUIRED.value
                ),
                decision_state=(
                    Decision.REQUEST_APPROVAL.value
                ),
            )

            self.commands[
                cmd.command_id
            ] = cmd

            return (
                self.snapshot(cmd.command_id)
                | {
                    "classification": "AUTH_REQUIRED",
                    "approval": {
                        "state": (
                            Approval.APPROVAL_REQUESTED.value
                        ),
                        "authorization_id": (
                            authorization.authorization_id
                        ),
                    },
                }
            )

        try:
            action = self.prepare(cmd)
        except RuntimeError as exc:
            return (
                self.snapshot(cmd.command_id)
                | {
                    "classification": (
                        str(exc).split(":")[0]
                    ),
                }
            )

        return (
            self.snapshot(cmd.command_id)
            | {
                "classification": "ACTION_PREPARED"
            }
        )


__all__ = [
    "Auth",
    "Approval",
    "CapabilityRegistry",
    "CapabilitySpec",
    "Command",
    "Decision",
    "ExecStatus",
    "ExecutionResult",
    "Lifecycle",
    "LocalFilesystemAdapter",
    "Op",
    "OperationEngine",
    "OperationStore",
    "Verification",
    "VerificationResult",
]