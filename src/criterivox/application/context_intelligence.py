from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from enum import StrEnum
from typing import Any, Mapping, Protocol


class EvidenceDebtLevel(StrEnum):
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"
    UNKNOWN = "UNKNOWN"


@dataclass(frozen=True, slots=True)
class EvidenceDebt:
    completeness_percent: int
    level: EvidenceDebtLevel
    tags: tuple[str, ...]
    method: str = "heuristic-v1"
    validation_status: str = "HYPOTHESIS"

    @classmethod
    def assess(cls, evidence: tuple[Mapping[str, Any], ...], *, missing_dimensions: tuple[str, ...] = (), uncertainty: tuple[str, ...] = ()) -> "EvidenceDebt":
        if not evidence:
            return cls(0, EvidenceDebtLevel.UNKNOWN, ("NO_EVIDENCE",))
        supported_statuses = {"OBSERVED", "VERIFIED", "CONFIRMED", "SUPPORTED"}
        neutral_statuses = {"ASSUMED", "HYPOTHETICAL", "SIMULATED"}
        supported = sum(str(item.get("status", "UNKNOWN")).upper() in supported_statuses for item in evidence)
        unknown = sum(str(item.get("status", "UNKNOWN")).upper() not in supported_statuses | neutral_statuses for item in evidence)
        score = round((supported / len(evidence)) * 100)
        score -= min(30, len(missing_dimensions) * 5)
        score -= min(20, len(uncertainty) * 4)
        score = max(0, min(100, score))
        tags: set[str] = set()
        if missing_dimensions:
            tags.add("MISSING_CONTEXT")
        if uncertainty:
            tags.add("UNCERTAINTY")
        if unknown:
            tags.add("UNVERIFIED_EVIDENCE")
        if any(str(item.get("status", "")).upper() == "ASSUMED" for item in evidence):
            tags.add("ASSUMPTION")
        if any(str(item.get("status", "")).upper() == "HYPOTHETICAL" for item in evidence):
            tags.add("HYPOTHESIS")
        if any(str(item.get("status", "")).upper() == "SIMULATED" for item in evidence):
            tags.add("SIMULATED")
        level = EvidenceDebtLevel.LOW if score >= 80 else EvidenceDebtLevel.MEDIUM if score >= 50 else EvidenceDebtLevel.HIGH
        return cls(score, level, tuple(sorted(tags)))


@dataclass(frozen=True, slots=True)
class ProvenanceNode:
    node_id: str
    node_type: str
    label: str
    source_ids: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class ProvenanceEdge:
    from_node: str
    to_node: str
    relation: str


@dataclass(frozen=True, slots=True)
class ProvenanceGraph:
    nodes: tuple[ProvenanceNode, ...]
    edges: tuple[ProvenanceEdge, ...]
    traceability_status: str = "IMPLEMENTED"
    immutability_status: str = "UNKNOWN"

    def to_dict(self) -> dict[str, Any]:
        return {"nodes": [{"id": n.node_id, "type": n.node_type, "label": n.label, "source_ids": list(n.source_ids)} for n in self.nodes], "edges": [{"from": e.from_node, "to": e.to_node, "relation": e.relation} for e in self.edges], "traceability_status": self.traceability_status, "immutability_status": self.immutability_status}


@dataclass(frozen=True, slots=True)
class ContextDiff:
    added: tuple[str, ...] = ()
    removed: tuple[str, ...] = ()
    changed: tuple[str, ...] = ()
    unchanged: tuple[str, ...] = ()
    semantic_equivalence_claimed: bool = False

    @classmethod
    def structural(cls, previous: Mapping[str, Any] | None, current: Mapping[str, Any]) -> "ContextDiff":
        if previous is None:
            return cls(added=tuple(sorted(current)))
        previous_keys, current_keys = set(previous), set(current)
        added, removed = current_keys - previous_keys, previous_keys - current_keys
        changed = {key for key in previous_keys & current_keys if previous[key] != current[key]}
        unchanged = {key for key in previous_keys & current_keys if previous[key] == current[key]}
        return cls(tuple(sorted(added)), tuple(sorted(removed)), tuple(sorted(changed)), tuple(sorted(unchanged)))


@dataclass(frozen=True, slots=True)
class ContextMemoryRecord:
    memory_id: str
    context_id: str
    created_at: str
    recheck_at: str
    recheck_reason: str
    status: str = "ACTIVE"
    validation_status: str = "HYPOTHESIS"

    @classmethod
    def create(cls, context_id: str, *, ttl: timedelta, reason: str, now: datetime | None = None) -> "ContextMemoryRecord":
        if ttl.total_seconds() <= 0:
            raise ValueError("Context memory TTL must be positive.")
        current = now or datetime.now(timezone.utc)
        return cls(f"MEM-{context_id}", context_id, current.isoformat(), (current + ttl).isoformat(), reason)

    def refresh_status(self, *, now: datetime | None = None) -> "ContextMemoryRecord":
        current = now or datetime.now(timezone.utc)
        if current >= datetime.fromisoformat(self.recheck_at):
            return ContextMemoryRecord(self.memory_id, self.context_id, self.created_at, self.recheck_at, self.recheck_reason, "RECHECK_REQUIRED", self.validation_status)
        return self


@dataclass(frozen=True, slots=True)
class AgentActivityEvent:
    event_id: str
    task_id: str
    character_id: str
    action: str
    reason: str
    occurred_at: str
    context_id: str | None = None
    evidence_ids: tuple[str, ...] = ()
    output: str | None = None
    failure_id: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return {"event_id": self.event_id, "task_id": self.task_id, "character_id": self.character_id, "action": self.action, "reason": self.reason, "occurred_at": self.occurred_at, "context_id": self.context_id, "evidence_ids": list(self.evidence_ids), "output": self.output, "failure_id": self.failure_id}


class ObservabilityTimeline:
    def __init__(self) -> None:
        self._events: list[AgentActivityEvent] = []

    def record(self, *, task_id: str, character_id: str, action: str, reason: str, context_id: str | None = None, evidence_ids: tuple[str, ...] = (), output: str | None = None, failure_id: str | None = None, now: datetime | None = None) -> AgentActivityEvent:
        current = now or datetime.now(timezone.utc)
        event = AgentActivityEvent(f"TRACE-{len(self._events) + 1:05d}", task_id, character_id, action, reason, current.isoformat(), context_id, evidence_ids, output, failure_id)
        self._events.append(event)
        return event

    def for_task(self, task_id: str) -> tuple[AgentActivityEvent, ...]:
        return tuple(event for event in self._events if event.task_id == task_id)


class HandoffStatus(StrEnum):
    PROPOSED = "PROPOSED"
    APPROVED = "APPROVED"
    DELIVERED = "DELIVERED"
    REJECTED = "REJECTED"
    FAILED = "FAILED"


@dataclass(frozen=True, slots=True)
class HandoffRecord:
    delivery_id: str
    from_character: str
    to_character: str
    reason: str
    task_id: str
    context_id: str | None
    evidence_ids: tuple[str, ...]
    request: str
    constraints: tuple[str, ...]
    expected_output: str
    status: HandoffStatus
    approval_required: bool = True
    approved_by: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return {"delivery_id": self.delivery_id, "from": self.from_character, "to": self.to_character, "reason": self.reason, "task_id": self.task_id, "context_id": self.context_id, "evidence_ids": list(self.evidence_ids), "request": self.request, "constraints": list(self.constraints), "expected_output": self.expected_output, "status": self.status.value, "approval_required": self.approval_required, "approved_by": self.approved_by}


@dataclass(frozen=True, slots=True)
class CapabilityRequest:
    capability: str
    request_id: str
    input: Mapping[str, Any]
    authorization: str = "local-user-runtime"


@dataclass(frozen=True, slots=True)
class CapabilityResponse:
    request_id: str
    status: str
    output: Mapping[str, Any]
    provenance: tuple[str, ...] = ()


class CapabilityAdapter(Protocol):
    def execute(self, request: CapabilityRequest) -> CapabilityResponse: ...


class InternalCapabilityBoundary:
    """Protocol-neutral boundary. An MCP adapter can target this later."""

    def __init__(self) -> None:
        self._handlers: dict[str, Any] = {}

    def register(self, name: str, handler: Any) -> None:
        if not name.strip():
            raise ValueError("Capability name must not be empty.")
        self._handlers[name] = handler

    def request(self, request: CapabilityRequest) -> CapabilityResponse:
        handler = self._handlers.get(request.capability)
        if handler is None:
            return CapabilityResponse(request.request_id, "UNSUPPORTED", {"error": "Capability is not registered."})
        output = handler(request.input)
        return CapabilityResponse(request.request_id, "OK", output if isinstance(output, Mapping) else {"value": output})


__all__ = ["AgentActivityEvent", "CapabilityAdapter", "CapabilityRequest", "CapabilityResponse", "ContextDiff", "ContextMemoryRecord", "EvidenceDebt", "EvidenceDebtLevel", "HandoffRecord", "HandoffStatus", "InternalCapabilityBoundary", "ObservabilityTimeline", "ProvenanceEdge", "ProvenanceGraph", "ProvenanceNode"]
