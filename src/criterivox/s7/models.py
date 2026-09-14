from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from datetime import datetime, timezone
from typing import Any, Mapping
from uuid import uuid4


class SessionStatus(str, Enum):
    RECEIVED = "received"
    WAITING_FOR_INFORMATION = "waiting_for_information"
    RUNNING = "running"
    AWAITING_HUMAN = "awaiting_human"
    COMPLETED = "completed"
    UNRESOLVED = "unresolved"
    CANCELLED = "cancelled"
    FAILED = "failed"


class ArtifactKind(str, Enum):
    INPUT = "input"
    CAPABILITY_PLAN = "capability_plan"
    REASONING = "reasoning"
    HYPOTHESIS = "hypothesis"
    EVALUATION = "evaluation"
    COMPARISON = "comparison"
    OBJECTION = "objection"
    LIMITATION = "limitation"
    RESULT = "result"
    HUMAN_INTERVENTION = "human_intervention"


@dataclass(frozen=True, slots=True)
class Artifact:
    artifact_id: str
    kind: ArtifactKind
    title: str
    content: Mapping[str, Any]
    parent_ids: tuple[str, ...] = ()
    version: int = 1
    branch_id: str = "main"
    created_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())


@dataclass(frozen=True, slots=True)
class S7Event:
    event_id: str
    event_type: str
    payload: Mapping[str, Any]
    created_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())


@dataclass(slots=True)
class AnalysisSession:
    session_id: str
    task: str
    context: Mapping[str, Any]
    status: SessionStatus = SessionStatus.RECEIVED
    branch_id: str = "main"
    artifacts: list[Artifact] = field(default_factory=list)
    events: list[S7Event] = field(default_factory=list)
    missing_information: tuple[str, ...] = ()

    @classmethod
    def create(cls, task: str, context: Mapping[str, Any] | None = None) -> "AnalysisSession":
        return cls(session_id=f"S7-{uuid4()}", task=task.strip(), context=dict(context or {}))

    def event(self, event_type: str, **payload: Any) -> S7Event:
        item = S7Event(event_id=str(uuid4()), event_type=event_type, payload=dict(payload))
        self.events.append(item)
        return item

    def artifact(self, kind: ArtifactKind, title: str, content: Mapping[str, Any], *, parents: tuple[str, ...] = ()) -> Artifact:
        previous = [a for a in self.artifacts if a.branch_id == self.branch_id and a.kind == kind]
        item = Artifact(artifact_id=f"A-{uuid4()}", kind=kind, title=title, content=dict(content), parent_ids=parents, version=len(previous) + 1, branch_id=self.branch_id)
        self.artifacts.append(item)
        return item
