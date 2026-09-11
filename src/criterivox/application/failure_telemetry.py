from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from enum import StrEnum


class FailureType(StrEnum):
    REQUIREMENT_CHANGED = "REQUIREMENT_CHANGED"
    HYPOTHESIS_FAILED = "HYPOTHESIS_FAILED"
    CONTEXT_MISMATCH = "CONTEXT_MISMATCH"
    BUILD_FAILED = "BUILD_FAILED"
    EXECUTION_FAILED = "EXECUTION_FAILED"


@dataclass(frozen=True, slots=True)
class FailureEvent:
    event_id: str
    task_id: str
    failure_type: FailureType
    character_id: str
    summary: str
    evidence: tuple[str, ...]
    recorded_at: str


class FailureTelemetry:
    """Structured failure telemetry kept separate from research knowledge."""

    def __init__(self) -> None:
        self._events: list[FailureEvent] = []

    def record(
        self,
        *,
        task_id: str,
        failure_type: FailureType,
        character_id: str,
        summary: str,
        evidence: tuple[str, ...] = (),
    ) -> FailureEvent:
        event = FailureEvent(
            event_id=f"FAIL-{len(self._events) + 1:05d}",
            task_id=task_id,
            failure_type=failure_type,
            character_id=character_id,
            summary=summary,
            evidence=evidence,
            recorded_at=datetime.now(timezone.utc).isoformat(),
        )
        self._events.append(event)
        return event

    def for_task(self, task_id: str) -> tuple[FailureEvent, ...]:
        return tuple(event for event in self._events if event.task_id == task_id)

    def latest(self, task_id: str) -> FailureEvent | None:
        events = self.for_task(task_id)
        return events[-1] if events else None


TELEMETRY = FailureTelemetry()


__all__ = ["FailureEvent", "FailureTelemetry", "FailureType", "TELEMETRY"]
