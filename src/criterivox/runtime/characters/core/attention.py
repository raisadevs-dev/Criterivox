from dataclasses import dataclass

from .attention_state import AttentionState


@dataclass(frozen=True, slots=True)
class CharacterAttention:
    """Defines how a Criterivox character responds to interaction context."""

    default_state: AttentionState
    attention_description: str

    def __post_init__(self) -> None:
        if not self.attention_description.strip():
            raise ValueError(
                "Attention description must not be empty."
            )