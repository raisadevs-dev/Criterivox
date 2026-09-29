from enum import Enum


class AnimationState(str, Enum):
    """Presentation-independent animation state."""

    IDLE = "idle"
    RECEIVE = "receive"
    WORK = "work"
    COMMUNICATE = "communicate"
    HANDOFF = "handoff"
    COMPLETE = "complete"
    WARNING = "warning"