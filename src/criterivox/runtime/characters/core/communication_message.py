from __future__ import annotations

from dataclasses import dataclass
from enum import IntEnum


class CommunicationPriority(IntEnum):
    """Priority assigned to character communication."""

    LOW = 1
    NORMAL = 2
    HIGH = 3
    CRITICAL = 4


@dataclass(frozen=True, slots=True)
class ContextualMessage:
    """A contextual message produced by a Criterivox character."""

    character_id: str
    event: str
    content: str
    priority: CommunicationPriority

    def __post_init__(self) -> None:
        if not self.character_id.strip():
            raise ValueError("Character identifier cannot be empty.")

        if not self.event.strip():
            raise ValueError("Message event cannot be empty.")

        if not self.content.strip():
            raise ValueError("Message content cannot be empty.")

    @property
    def is_critical(self) -> bool:
        """Return whether the message requires critical attention."""
        return self.priority is CommunicationPriority.CRITICAL