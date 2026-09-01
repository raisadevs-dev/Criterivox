from enum import Enum


class AttentionState(str, Enum):
    """Interaction-attention state of a Criterivox character."""

    QUIET = "quiet"
    ATTENTIVE = "attentive"
    FOCUSED = "focused"
    BUSY = "busy"
    WAITING = "waiting"
    NEEDS_USER = "needs_user"
    COMPLETING = "completing"
    RECOVERING = "recovering"