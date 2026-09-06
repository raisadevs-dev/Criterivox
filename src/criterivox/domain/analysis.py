from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from uuid import uuid4


class AnalysisTaskState(str, Enum):
    CREATED = "CREATED"
    RECEIVED = "RECEIVED"
    VALIDATING = "VALIDATING"
    PROCESSING = "PROCESSING"
    ANALYZING = "ANALYZING"
    RESULT_READY = "RESULT_READY"
    COMPLETED = "COMPLETED"
    WAITING = "WAITING"
    FAILED = "FAILED"
    CANCELLED = "CANCELLED"


class AnalysisTaskSource(str, Enum):
    WORKSPACE = "workspace"
    CHAT = "chat"
    BLOOM = "bloom"


@dataclass(frozen=True, slots=True)
class Evidence:
    identifier: str
    label: str
    source: str
    detail: str = ""


@dataclass(frozen=True, slots=True)
class Observation:
    identifier: str
    text: str
    significance: str = "observed"


@dataclass(frozen=True, slots=True)
class Finding:
    identifier: str
    statement: str
    confidence: str = "deterministic"


@dataclass(frozen=True, slots=True)
class AnalysisResult:
    summary: str
    observations: tuple[Observation, ...] = ()
    findings: tuple[Finding, ...] = ()
    evidence: tuple[Evidence, ...] = ()


_ALLOWED_TRANSITIONS: dict[AnalysisTaskState, frozenset[AnalysisTaskState]] = {
    AnalysisTaskState.CREATED: frozenset({AnalysisTaskState.RECEIVED, AnalysisTaskState.CANCELLED}),
    AnalysisTaskState.RECEIVED: frozenset({AnalysisTaskState.VALIDATING, AnalysisTaskState.FAILED}),
    AnalysisTaskState.VALIDATING: frozenset({AnalysisTaskState.PROCESSING, AnalysisTaskState.WAITING, AnalysisTaskState.FAILED}),
    AnalysisTaskState.PROCESSING: frozenset({AnalysisTaskState.ANALYZING, AnalysisTaskState.FAILED}),
    AnalysisTaskState.ANALYZING: frozenset({AnalysisTaskState.RESULT_READY, AnalysisTaskState.FAILED}),
    AnalysisTaskState.RESULT_READY: frozenset({AnalysisTaskState.COMPLETED}),
    AnalysisTaskState.COMPLETED: frozenset({AnalysisTaskState.CANCELLED}),
    AnalysisTaskState.WAITING: frozenset({AnalysisTaskState.RECEIVED, AnalysisTaskState.CANCELLED, AnalysisTaskState.FAILED}),
    AnalysisTaskState.FAILED: frozenset({AnalysisTaskState.RECEIVED, AnalysisTaskState.CANCELLED}),
    AnalysisTaskState.CANCELLED: frozenset(),
}


class InvalidAnalysisTransition(ValueError):
    pass


@dataclass
class AnalysisTask:
    """Aggregate representing one analysis regardless of its presentation surface."""

    task_id: str
    task: str
    data: dict[str, object]
    context: dict[str, object]
    source: AnalysisTaskSource
    references: tuple[str, ...] = ()
    state: AnalysisTaskState = AnalysisTaskState.CREATED
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    result: AnalysisResult | None = None
    error: str | None = None
    activity: list[str] = field(default_factory=list)

    @classmethod
    def create(
        cls,
        *,
        task: str,
        data: dict[str, object],
        context: dict[str, object],
        source: AnalysisTaskSource,
        references: tuple[str, ...] = (),
    ) -> "AnalysisTask":
        if not task.strip():
            raise ValueError("Analysis task must not be empty.")
        if len(task) > 500:
            raise ValueError("Analysis task is too long.")
        if len(data) > 1000 or len(context) > 1000:
            raise ValueError("Analysis data or context contains too many fields.")
        if len(references) > 50:
            raise ValueError("Too many references.")
        return cls(
            task_id=f"AN-{uuid4().hex[:8].upper()}",
            task=task.strip(),
            data=dict(data),
            context=dict(context),
            source=source,
            references=tuple(ref.strip() for ref in references if ref.strip()),
        )

    def transition(self, target: AnalysisTaskState) -> None:
        if target not in _ALLOWED_TRANSITIONS[self.state]:
            raise InvalidAnalysisTransition(f"Cannot transition analysis task from {self.state.value} to {target.value}.")
        self.state = target
        self.updated_at = datetime.now(timezone.utc)

    def add_activity(self, message: str) -> None:
        if not message.strip():
            return
        self.activity.append(message.strip())
        self.updated_at = datetime.now(timezone.utc)

    def complete(self, result: AnalysisResult) -> None:
        if self.state is not AnalysisTaskState.RESULT_READY:
            raise InvalidAnalysisTransition("Only a result-ready task can be completed.")
        self.result = result
        self.transition(AnalysisTaskState.COMPLETED)

    def fail(self, message: str) -> None:
        if self.state not in {AnalysisTaskState.RECEIVED, AnalysisTaskState.VALIDATING, AnalysisTaskState.PROCESSING, AnalysisTaskState.ANALYZING}:
            raise InvalidAnalysisTransition("Task cannot be failed from its current state.")
        self.error = message.strip()[:500]
        self.transition(AnalysisTaskState.FAILED)

    @property
    def is_terminal(self) -> bool:
        return self.state in {AnalysisTaskState.COMPLETED, AnalysisTaskState.FAILED, AnalysisTaskState.CANCELLED}


__all__ = [
    "AnalysisResult",
    "AnalysisTask",
    "AnalysisTaskSource",
    "AnalysisTaskState",
    "Evidence",
    "Finding",
    "InvalidAnalysisTransition",
    "Observation",
]
