from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Mapping
from uuid import uuid4

from criterivox.s8.models import Artifact, ArtifactKind, BureauEvent
from .adapters import S8ArtifactRepository, artifact_hash, make_audit_artifact
from .core import DomainEvent, EventBus, stable_id


@dataclass(frozen=True, slots=True)
class Trace:
    trace_id: str
    correlation_id: str
    started_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))


@dataclass(frozen=True, slots=True)
class Span:
    span_id: str
    trace_id: str
    name: str
    started_at: datetime
    finished_at: datetime | None = None
    attributes: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True, slots=True)
class Checkpoint:
    checkpoint_id: str
    execution_id: str
    sequence: int
    state: Mapping[str, Any]
    parent_checkpoint_id: str | None = None


class ExecutionJournal:
    """Durable checkpoint/audit journal backed by the existing S8 store."""
    def __init__(self, repository: S8ArtifactRepository, event_bus: EventBus | None = None):
        self.repository = repository
        self.event_bus = event_bus or EventBus()

    def checkpoint(self, execution_id: str, sequence: int, state: Mapping[str, Any], *, parent_checkpoint_id: str | None = None, context_id: str | None = None, tenant_id: str | None = None) -> Checkpoint:
        checkpoint = Checkpoint(f"CP-{uuid4()}", execution_id, sequence, dict(state), parent_checkpoint_id)
        artifact = make_audit_artifact(artifact_id=checkpoint.checkpoint_id, payload={"type": "checkpoint", "execution_id": execution_id, "sequence": sequence, "state": dict(state), "parent_checkpoint_id": parent_checkpoint_id}, context_id=context_id, tenant_id=tenant_id)
        self.repository.save_artifact(artifact)
        event = BureauEvent(f"S9E-{uuid4()}", "CHECKPOINT_CREATED", (artifact.artifact_id,), actor="system", tenant_id=tenant_id, context_id=context_id, payload={"execution_id": execution_id, "sequence": sequence})
        self.repository.save_event(event)
        self.event_bus.publish(DomainEvent(event.event_id, "checkpoint.created", event.payload, correlation_id=execution_id))
        return checkpoint

    def replay(self, execution_id: str, *, context_id: str | None = None, tenant_id: str | None = None) -> tuple[Checkpoint, ...]:
        artifacts = self.repository.list_artifacts(tenant_id=tenant_id, context_id=context_id)
        result: list[Checkpoint] = []
        for artifact in artifacts:
            p = artifact.payload
            if p.get("type") == "checkpoint" and p.get("execution_id") == execution_id:
                result.append(Checkpoint(artifact.artifact_id, execution_id, int(p["sequence"]), dict(p.get("state", {})), p.get("parent_checkpoint_id")))
        return tuple(sorted(result, key=lambda item: item.sequence))


class CapabilityRouter:
    """Small topology-aware router. It returns routing decisions; it does not own capabilities."""
    def __init__(self, event_bus: EventBus | None = None):
        self.event_bus = event_bus or EventBus()
        self._routes: dict[str, tuple[str, ...]] = {}

    def advertise(self, capability_id: str, node_ids: tuple[str, ...]) -> None:
        if not node_ids:
            raise ValueError("At least one node is required for a capability route.")
        self._routes[capability_id] = tuple(dict.fromkeys(node_ids))

    def route(self, capability_id: str, *, preferred_node: str | None = None, visited: tuple[str, ...] = ()) -> str:
        nodes = self._routes.get(capability_id, ())
        if not nodes:
            raise LookupError(f"No route for capability: {capability_id}")
        if preferred_node and preferred_node in nodes:
            selected = preferred_node
        else:
            selected = next((node for node in nodes if node not in visited), nodes[0])
        if selected in visited and all(node in visited for node in nodes):
            raise RuntimeError("ROUTING_LOOP_DETECTED")
        self.event_bus.publish(DomainEvent(f"EV-{uuid4()}", "routing.selected", {"capability_id": capability_id, "node_id": selected}))
        return selected


class ArtifactIntegrity:
    def __init__(self, repository: S8ArtifactRepository):
        self.repository = repository

    def verify(self, artifact_id: str) -> bool:
        artifact = self.repository.get_artifact(artifact_id)
        if artifact is None:
            raise KeyError(artifact_id)
        return artifact.content_hash == artifact_hash(artifact.payload)


__all__ = ["ArtifactIntegrity", "CapabilityRouter", "Checkpoint", "ExecutionJournal", "Span", "Trace"]
