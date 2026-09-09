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
    MATERIAL_RECEIVED = "material_received"
    SOURCE_REGISTERED = "source_registered"
    EXTRACTION_STARTED = "extraction_started"
    EXTRACTION_COMPLETED = "extraction_completed"
    EXTRACTION_FAILED = "extraction_failed"
    CANDIDATE_INFORMATION_READY = "candidate_information_ready"
    USER_CONFIRMATION_REQUIRED = "user_confirmation_required"
    USER_INFORMATION_CONFIRMED = "user_information_confirmed"
    USER_INFORMATION_CORRECTED = "user_information_corrected"
    USER_INFORMATION_REJECTED = "user_information_rejected"
    PROFILE_STARTED = "profile_started"
    PROFILE_COMPLETED = "profile_completed"
    VALIDATION_STARTED = "validation_started"
    VALIDATION_COMPLETED = "validation_completed"
    VALIDATION_FAILED = "validation_failed"
    ANOMALY_DETECTED = "anomaly_detected"
    MISSINGNESS_IDENTIFIED = "missingness_identified"
    CLEANING_STARTED = "cleaning_started"
    CLEANING_COMPLETED = "cleaning_completed"
    NORMALIZATION_STARTED = "normalization_started"
    NORMALIZATION_COMPLETED = "normalization_completed"
    CANONICAL_DATA_READY = "canonical_data_ready"
    SANDRE_HANDOFF_READY = "sandre_handoff_ready"
    DHAREN_HANDOFF_READY = "dharen_handoff_ready"


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
        object.__setattr__(self, "payload", MappingProxyType(dict(self.payload)))


def create_event(event_type: EventType, payload: Mapping[str, Any] | None = None) -> DomainEvent:
    return DomainEvent(event_type=event_type, payload={} if payload is None else payload)


__all__ = ["DomainEvent", "EventType", "create_event"]
