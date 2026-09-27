from enum import Enum


class CharacterState(str, Enum):
    """Runtime activity state of a Criterivox character."""

    IDLE = "idle"
    RECEIVE = "receive"
    WORK = "work"
    COMMUNICATE = "communicate"
    HANDOFF = "handoff"
    COMPLETE = "complete"
    WARNING = "warning"