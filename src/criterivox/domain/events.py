from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from types import MappingProxyType
from typing import Any, Mapping
from uuid import uuid4


class EventType(str, Enum):
    """Common system events understood by Criterivox."""

    DATA_RECEIVED = "data_received"
    CONTEXT_UPDATED = "context_updated"
    TASK_IDENTIFIED = "task_identified"
    ANALYSIS_REQUESTED = "analysis_requested"
    ANALYSIS_STARTED = "analysis_started"
    ANALYSIS_COMPLETED = "analysis_completed"
    INSIGHT_GENERATED = "insight_generated"
    EXPLANATION_REQUESTED = "explanation_requested"
    EXPLANATION_READY = "explanation_ready"
    WARNING_RAISED = "warning_raised"
    TASK_COMPLETED = "task_completed"


@dataclass(frozen=True, slots=True)
class DomainEvent:
    """Immutable event representing meaningful system activity."""

    event_type: EventType
    payload: Mapping[str, Any] = field(default_factory=dict)
    event_id: str = field(default_factory=lambda: str(uuid4()))

    def __post_init__(self) -> None:
        if not self.event_id.strip():
            raise ValueError("Event identifier cannot be empty.")

        if not isinstance(self.event_type, EventType):
            raise TypeError("event_type must be an EventType.")

        if not isinstance(self.payload, Mapping):
            raise TypeError("Event payload must be a mapping.")

        object.__setattr__(
            self,
            "payload",
            MappingProxyType(dict(self.payload)),
        )


def create_event(
    event_type: EventType,
    payload: Mapping[str, Any] | None = None,
) -> DomainEvent:
    """Create a new immutable domain event."""

    return DomainEvent(
        event_type=event_type,
        payload={} if payload is None else payload,
    )


__all__ = [
    "DomainEvent",
    "EventType",
    "create_event",
]