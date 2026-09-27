"""Human-facing XAI evaluation records for S8 research.

This module records study observations without collapsing them into a universal
"explainability score". It is deliberately measurement-oriented: the human
participant supplies responses, while analysis of those responses remains a
separate research activity.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Mapping


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


DIMENSIONS = (
    "understandability",
    "traceability",
    "uncertainty_comprehension",
    "evidence_linkage",
    "intervention_clarity",
    "limitation_awareness",
)


@dataclass(frozen=True)
class HumanXAIResponse:
    participant_id: str
    artifact_id: str
    dimension: str
    response: Any
    task_id: str | None = None
    notes: str = ""
    recorded_at: datetime = field(default_factory=utc_now)


class HumanXAIEvaluation:
    """Append-only protocol recorder; it does not compute a universal score."""

    def __init__(self) -> None:
        self.responses: list[HumanXAIResponse] = []

    def record(
        self,
        participant_id: str,
        artifact_id: str,
        dimension: str,
        response: Any,
        *,
        task_id: str | None = None,
        notes: str = "",
    ) -> HumanXAIResponse:
        if not participant_id.strip() or not artifact_id.strip():
            raise ValueError("participant_id and artifact_id are required")
        if dimension not in DIMENSIONS:
            raise ValueError(f"Unsupported XAI evaluation dimension: {dimension}")
        item = HumanXAIResponse(
            participant_id=participant_id,
            artifact_id=artifact_id,
            dimension=dimension,
            response=response,
            task_id=task_id,
            notes=notes,
        )
        self.responses.append(item)
        return item

    def export(self) -> list[Mapping[str, Any]]:
        return [
            {
                "participant_id": item.participant_id,
                "artifact_id": item.artifact_id,
                "dimension": item.dimension,
                "response": item.response,
                "task_id": item.task_id,
                "notes": item.notes,
                "recorded_at": item.recorded_at.isoformat(),
            }
            for item in self.responses
        ]
