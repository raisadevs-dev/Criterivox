from dataclasses import dataclass
from .attention import CharacterAttention
from .behavior import CharacterBehavior
from .identity import CharacterIdentity
from .personality import CharacterPersonality
from .responsibility import CharacterResponsibility
from .role import CharacterRole
from .communication import CharacterCommunication
from .handoff import CharacterHandoff
from .trigger import ContextualTrigger

@dataclass(frozen=True, slots=True)
class Character:
    """Technology-independent definition of a Criterivox character."""

    identity: CharacterIdentity
    role: CharacterRole
    responsibilities: tuple[CharacterResponsibility, ...]
    personality: CharacterPersonality
    communication: CharacterCommunication
    attention: CharacterAttention
    handoffs: tuple[CharacterHandoff, ...]
    contextual_triggers: tuple[ContextualTrigger, ...]
    behavior: CharacterBehavior

    def __post_init__(self) -> None:
        if not self.responsibilities:
            raise ValueError(
                "A character must have at least one responsibility."
            )