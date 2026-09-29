from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class CharacterPersonality:
    """Interaction personality configuration for a character."""

    communication_style: str
    interaction_style: str
    tone: str

    def __post_init__(self) -> None:
        if not self.communication_style.strip():
            raise ValueError("Communication style cannot be empty.")

        if not self.interaction_style.strip():
            raise ValueError("Interaction style cannot be empty.")

        if not self.tone.strip():
            raise ValueError("Tone cannot be empty.")