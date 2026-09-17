from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Any, Callable, Mapping, Protocol, Sequence
from uuid import uuid4

from criterivox.s8.models import Artifact, ArtifactKind, BureauEvent


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def stable_id(prefix: str, *parts: object) -> str:
    raw = json.dumps(parts, sort_keys=True, default=str, separators=(",", ":")).encode()
    return f"{prefix}-{hashlib.sha256(raw).hexdigest()[:24]}"


class Capability(Protocol):
    descriptor: "CapabilityDescriptor"
    def execute(self, request: "CapabilityRequest", context: "PipelineContext") -> "CapabilityResult": ...


@dataclass(frozen=True, slots=True)
class CapabilityDescriptor:
    capability_id: str
    name: str
    version: str = "1.0"
    description: str = ""
    input_types: tuple[str, ...] = ()
    output_types: tuple[str, ...] = ()
    tags: tuple[str, ...] = ()
    required_permissions: tuple[str, ...] = ()
    estimated_cost: float = 0.0
    character_ids: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        if not self.capability_id.strip() or not self.name.strip():
            raise ValueError("Capability identity is required.")
        if self.estimated_cost < 0:
            raise ValueError("Capability cost cannot be negative.")
        if self.character_ids:
            raise ValueError("Capabilities cannot depend on presentation characters.")


@dataclass(frozen=True, slots=True)
class CapabilityRequest:
    request_id: str
    capability_id: str
    payload: Mapping[str, Any] = field(default_factory=dict)
    actor_id: str = "system"
    correlation_id: str | None = None


@dataclass(frozen=True, slots=True)
class CapabilityResult:
    request_id: str
    capability_id: str
    status: str
    output: Mapping[str, Any] = field(default_factory=dict)
    artifact_ids: tuple[str, ...] = ()
    event_ids: tuple[str, ...] = ()
    error: str | None = None


class CapabilityRegistry:
    def __init__(self) -> None:
        self._capabilities: dict[str, Capability] = {}

    def register(self, capability: Capability) -> None:
        cid = capability.descriptor.capability_id
        if cid in self._capabilities:
            raise ValueError(f"Capability already registered: {cid}")
        self._capabilities[cid] = capability

    def replace(self, capability: Capability) -> None:
        self._capabilities[capability.descriptor.capability_id] = capability

    def get(self, capability_id: str) -> Capability:
        try:
            return self._capabilities[capability_id]
        except KeyError as exc:
            raise KeyError(f"Unknown capability: {capability_id}") from exc

    def discover(self, *, tags: Sequence[str] = ()) -> tuple[CapabilityDescriptor, ...]:
        wanted = set(tags)
        values = self._capabilities.values()
        if wanted:
            values = (c for c in values if wanted.intersection(c.descriptor.tags))
        return tuple(c.descriptor for c in values)


@dataclass(frozen=True, slots=True)
class PipelineStep:
    step_id: str
    capability_id: str
    depends_on: tuple[str, ...] = ()
    optional: bool = False


@dataclass(frozen=True, slots=True)
class PipelineDefinition:
    pipeline_id: str
    version: str
    steps: tuple[PipelineStep, ...]

    def validate(self) -> None:
        ids = {s.step_id for s in self.steps}
        if len(ids) != len(self.steps):
            raise ValueError("Pipeline step IDs must be unique.")
        for step in self.steps:
            unknown = set(step.depends_on) - ids
            if unknown:
                raise ValueError(f"Pipeline step {step.step_id} has unknown dependencies: {sorted(unknown)}")
        self.topological_order()

    def topological_order(self) -> tuple[PipelineStep, ...]:
        remaining = {s.step_id: s for s in self.steps}
        result: list[PipelineStep] = []
        while remaining:
            ready = [s for s in remaining.values() if all(d not in remaining for d in s.depends_on)]
            if not ready:
                raise ValueError("Pipeline contains a dependency cycle.")
            for step in sorted(ready, key=lambda s: s.step_id):
                result.append(step)
                remaining.pop(step.step_id)
        return tuple(result)


@dataclass(slots=True)
class PipelineContext:
    execution_id: str
    correlation_id: str
    values: dict[str, Any] = field(default_factory=dict)
    artifact_ids: list[str] = field(default_factory=list)
    event_ids: list[str] = field(default_factory=list)
    metadata: dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True, slots=True)
class PipelineResult:
    execution_id: str
    status: str
    outputs: Mapping[str, Mapping[str, Any]]
    artifact_ids: tuple[str, ...]
    event_ids: tuple[str, ...]
    error: str | None = None


@dataclass(frozen=True, slots=True)
class DomainEvent:
    event_id: str
    event_type: str
    payload: Mapping[str, Any] = field(default_factory=dict)
    correlation_id: str | None = None
    causation_id: str | None = None
    occurred_at: datetime = field(default_factory=utc_now)


class EventBus:
    def __init__(self) -> None:
        self._handlers: dict[str, list[Callable[[DomainEvent], None]]] = {}
        self.history: list[DomainEvent] = []

    def subscribe(self, event_type: str, handler: Callable[[DomainEvent], None]) -> None:
        self._handlers.setdefault(event_type, []).append(handler)

    def publish(self, event: DomainEvent) -> None:
        self.history.append(event)
        for handler in tuple(self._handlers.get(event.event_type, ())):
            handler(event)


class ArtifactRepository(Protocol):
    def save_artifact(self, artifact: Artifact) -> None: ...
    def get_artifact(self, artifact_id: str) -> Artifact | None: ...
    def save_event(self, event: BureauEvent) -> None: ...


@dataclass(frozen=True, slots=True)
class ExecutionAudit:
    execution_id: str
    correlation_id: str
    capability_id: str | None
    status: str
    started_at: datetime
    finished_at: datetime | None = None
    error: str | None = None


class PipelineExecutor:
    def __init__(self, registry: CapabilityRegistry, *, event_bus: EventBus | None = None, artifact_repository: ArtifactRepository | None = None) -> None:
        self.registry = registry
        self.event_bus = event_bus or EventBus()
        self.artifact_repository = artifact_repository
        self.audits: list[ExecutionAudit] = []

    def execute(self, definition: PipelineDefinition, payload: Mapping[str, Any], *, actor_id: str = "system", correlation_id: str | None = None, execution_id: str | None = None) -> PipelineResult:
        definition.validate()
        execution_id = execution_id or f"EX-{uuid4()}"
        correlation_id = correlation_id or execution_id
        context = PipelineContext(execution_id, correlation_id, values={"input": dict(payload)})
        outputs: dict[str, Mapping[str, Any]] = {}
        self.event_bus.publish(DomainEvent(f"EV-{uuid4()}", "pipeline.started", {"pipeline_id": definition.pipeline_id}, correlation_id))
        for step in definition.topological_order():
            capability = self.registry.get(step.capability_id)
            inputs = {"input": context.values.get("input", {}), "dependencies": {d: outputs[d] for d in step.depends_on}}
            request = CapabilityRequest(f"REQ-{uuid4()}", step.capability_id, inputs, actor_id, correlation_id)
            started = utc_now()
            try:
                result = capability.execute(request, context)
                if result.status not in {"OK", "SKIPPED"}:
                    if step.optional:
                        continue
                    raise RuntimeError(result.error or f"Capability {step.capability_id} failed")
                outputs[step.step_id] = dict(result.output)
                context.artifact_ids.extend(result.artifact_ids)
                context.event_ids.extend(result.event_ids)
                self.audits.append(ExecutionAudit(execution_id, correlation_id, step.capability_id, result.status, started, utc_now()))
                self.event_bus.publish(DomainEvent(f"EV-{uuid4()}", "capability.completed", {"step_id": step.step_id, "capability_id": step.capability_id, "status": result.status, "artifact_ids": result.artifact_ids}, correlation_id, result.event_ids[-1] if result.event_ids else None))
            except Exception as exc:
                self.audits.append(ExecutionAudit(execution_id, correlation_id, step.capability_id, "FAILED", started, utc_now(), str(exc)))
                self.event_bus.publish(DomainEvent(f"EV-{uuid4()}", "capability.failed", {"step_id": step.step_id, "capability_id": step.capability_id, "error": str(exc)}, correlation_id))
                if not step.optional:
                    self.event_bus.publish(DomainEvent(f"EV-{uuid4()}", "pipeline.failed", {"pipeline_id": definition.pipeline_id, "step_id": step.step_id, "error": str(exc)}, correlation_id))
                    return PipelineResult(execution_id, "FAILED", outputs, tuple(context.artifact_ids), tuple(context.event_ids), str(exc))
        self.event_bus.publish(DomainEvent(f"EV-{uuid4()}", "pipeline.completed", {"pipeline_id": definition.pipeline_id}, correlation_id))
        return PipelineResult(execution_id, "COMPLETED", outputs, tuple(context.artifact_ids), tuple(context.event_ids))


__all__ = ["ArtifactRepository", "Capability", "CapabilityDescriptor", "CapabilityRegistry", "CapabilityRequest", "CapabilityResult", "DomainEvent", "EventBus", "ExecutionAudit", "PipelineContext", "PipelineDefinition", "PipelineExecutor", "PipelineResult", "PipelineStep", "stable_id", "utc_now"]
