from dataclasses import dataclass
from enum import Enum


class CommunicationCapability(str, Enum):
    """Types of communication a character can provide."""

    ACKNOWLEDGE = "acknowledge"
    STATUS = "status"
    RESULT = "result"
    WARNING = "warning"
    HANDOFF = "handoff"


@dataclass(frozen=True, slots=True)
class CharacterCommunication:
    """Communication capabilities available to a character."""

    capabilities: frozenset[CommunicationCapability]

    def supports(self, capability: CommunicationCapability) -> bool:
        return capability in self.capabilities