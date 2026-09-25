from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Any


class SituationKind(str, Enum):
    GENERAL_DECISION = "general_decision"
    INTERPERSONAL = "interpersonal"
    BULLYING_OR_HARASSMENT = "bullying_or_harassment"
    SCHOOL_OR_WORK = "school_or_work"
    PLANNING = "planning"
    UNCERTAIN_INFORMATION = "uncertain_information"


class SafetyLevel(str, Enum):
    ORDINARY = "ordinary"
    SENSITIVE = "sensitive"
    IMMEDIATE = "immediate"


@dataclass(frozen=True)
class Situation:
    description: str
    goal: str = ""
    context: str = ""
    people: tuple[str, ...] = ()
    constraints: tuple[str, ...] = ()
    options: tuple[str, ...] = ()
    evidence: tuple[str, ...] = ()
    uncertainties: tuple[str, ...] = ()
    time_sensitivity: str = "unknown"
    safety: SafetyLevel = SafetyLevel.ORDINARY
    desired_outcome: str = ""
    user_reported_behavior: str = ""
    image_count: int = 0
    image_roles: tuple[str, ...] = ()


@dataclass(frozen=True)
class SituationUnderstanding:
    situation: Situation
    intent: str
    needs_clarification: bool
    clarifying_questions: tuple[str, ...] = ()
    notes: tuple[str, ...] = ()


@dataclass(frozen=True)
class DecisionSupportResult:
    situation_summary: str
    what_matters: tuple[str, ...]
    options: tuple[dict[str, Any], ...]
    relevant_evidence: tuple[str, ...]
    uncertainties: tuple[str, ...]
    suggested_next_steps: tuple[str, ...]
    safety_guidance: tuple[str, ...]
    reasoning_summary: str
    deeper_inspection: dict[str, Any] = field(default_factory=dict)
