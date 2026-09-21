from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any


@dataclass(frozen=True)
class ResearchSession:
    session_id: str
    participant_id: str
    study_id: str | None
    app_version: str | None
    started_at: str
    metadata: dict[str, Any]

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class ResearchConsent:
    participant_id: str
    consent_version: str
    usage_analytics: bool = False
    interaction_research: bool = False
    feedback_research: bool = False
    follow_up_contact: bool = False
    recorded_interview: bool = False
    recorded_at: str = ""

    def allows(self, purpose: str) -> bool:
        return {
            "usage_analytics": self.usage_analytics,
            "interaction_research": self.interaction_research,
            "feedback_research": self.feedback_research,
            "follow_up_contact": self.follow_up_contact,
            "recorded_interview": self.recorded_interview,
        }.get(purpose, False)

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class ResearchEvent:
    event_id: str
    session_id: str
    participant_id: str
    event_type: str
    purpose: str
    timestamp: str
    workflow_stage: str | None
    payload: dict[str, Any]

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
