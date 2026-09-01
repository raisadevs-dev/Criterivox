from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class PresentationState(str, Enum):
    """Visual state exposed by the behavioral system."""

    IDLE = "idle"
    RECEIVE = "receive"
    WORK = "work"
    COMMUNICATE = "communicate"
    HANDOFF = "handoff"
    COMPLETE = "complete"
    WARNING = "warning"


@dataclass(frozen=True, slots=True)
class CharacterPresentationState:
    """Presentation-safe representation of a character's state."""

    character_id: str
    state: PresentationState
    active: bool = False
    prominent: bool = False
    reduced_motion: bool = False

    def __post_init__(self) -> None:
        if not self.character_id.strip():
            raise ValueError("Character id cannot be empty.")