from __future__ import annotations

import re

from .situation import Situation, SituationUnderstanding
from .situation_safety import SituationSafetyRouter


class SituationUnderstandingService:
    """Deterministic baseline for ordinary-language situation understanding."""

    def __init__(self, safety_router: SituationSafetyRouter | None = None) -> None:
        self.safety_router = safety_router or SituationSafetyRouter()

    def understand(self, description: str, *, image_count: int = 0, image_roles: tuple[str, ...] = ()) -> SituationUnderstanding:
        text = description.strip()
        if not text:
            raise ValueError("situation description is required")
        safety = self.safety_router.assess(text)
        lower = text.lower()

        if safety.level.value != "ordinary":
            intent = "interpersonal_guidance"
        elif re.search(r"\b(?:choose|choice|decide|decision|options?)\b", lower):
            intent = "decision_support"
        elif re.search(r"\b(?:plan|planning|organize|schedule)\b", lower):
            intent = "planning"
        elif re.search(r"\b(?:why|wrong|verify|evidence|source)\b", lower):
            intent = "evidence_analysis"
        else:
            intent = "general_support"

        people = ("other people",) if re.search(r"\b(?:classmates?|friends?|group|team|coworkers?|people|kids?)\b", lower) else ()
        kind = "general_decision"
        if safety.level.value != "ordinary":
            kind = "bullying_or_harassment" if re.search(r"\bbully\w*\b", lower) else "interpersonal"
        elif re.search(r"\b(?:school|exam|class|teacher|study)\b", lower):
            kind = "school_or_work"

        questions = list(safety.questions)
        if intent == "decision_support" and not re.search(r"\b(?:three|two|\d+)\b", lower):
            questions.append("What are the main options you are considering?")
        if kind == "bullying_or_harassment":
            questions = list(dict.fromkeys(questions))
        situation = Situation(
            description=text,
            goal=text,
            people=people,
            safety=safety.level,
            image_count=image_count,
            image_roles=image_roles,
            user_reported_behavior=text if safety.level != safety.level.ORDINARY else "",
        )
        notes = (
            "Photographs of people are contextual input only; they do not establish behavior, identity, intent, personality, or safety.",
        ) if image_count else ()
        return SituationUnderstanding(
            situation=situation,
            intent=intent,
            needs_clarification=bool(questions),
            clarifying_questions=tuple(questions[:5]),
            notes=notes,
        )
