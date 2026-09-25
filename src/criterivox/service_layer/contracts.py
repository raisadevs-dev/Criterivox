from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Mapping

def utc_now() -> datetime:
    return datetime.now(timezone.utc)

@dataclass(frozen=True)
class ServiceRequest:
    request_id: str
    goal: str
    supplied_data: str = ""
    context: str = ""
    session_id: str | None = None
    actor_id: str = "human"
    authorization: str = "human-review"
    metadata: Mapping[str, Any] = field(default_factory=dict)

@dataclass(frozen=True)
class ServiceResult:
    service_type: str
    request_id: str
    status: str
    purpose: str
    content: Mapping[str, Any] = field(default_factory=dict)
    structured_data: Mapping[str, Any] = field(default_factory=dict)
    evidence_refs: tuple[str, ...] = ()
    provenance_refs: tuple[str, ...] = ()
    assumptions: tuple[str, ...] = ()
    uncertainty: tuple[str, ...] = ()
    limitations: tuple[str, ...] = ()
    alternatives: tuple[Mapping[str, Any], ...] = ()
    challengeable: tuple[str, ...] = ()
    editable: tuple[str, ...] = ()
    downstream_dependencies: tuple[str, ...] = ()
    artifact_refs: tuple[str, ...] = ()
    execution_ref: str | None = None
    authorization_state: str = "human-review"
    failure_reason: str | None = None
    timestamp: datetime = field(default_factory=utc_now)
    version: str = "1.0"

    @property
    def sufficient(self) -> bool:
        return self.status not in {"INSUFFICIENT", "FAILED", "UNSUPPORTED"}

@dataclass(frozen=True)
class ServicePlan:
    request_id: str
    services: tuple[str, ...]
    rationale: tuple[str, ...] = ()

@dataclass(frozen=True)
class OutcomeRecord:
    outcome_id: str
    request_id: str
    expected: Mapping[str, Any]
    actual: Mapping[str, Any]
    deviations: tuple[str, ...]
    validated: bool = False
