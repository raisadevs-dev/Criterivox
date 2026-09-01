from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class CharacterBehavior:
    """Behavioral configuration for a Criterivox character."""

    activation_priority: int
    preferred_events: tuple[str, ...]
    contextual_triggers: tuple[str, ...]
    communication_style: str
    work_behavior: str
    completion_behavior: str
    warning_behavior: str
    humor_characteristics: str

    def __post_init__(self) -> None:
        if self.activation_priority < 0:
            raise ValueError("Activation priority cannot be negative.")

        if not self.communication_style.strip():
            raise ValueError("Communication style cannot be empty.")

        if not self.work_behavior.strip():
            raise ValueError("Work behavior cannot be empty.")

        if not self.completion_behavior.strip():
            raise ValueError("Completion behavior cannot be empty.")

        if not self.warning_behavior.strip():
            raise ValueError("Warning behavior cannot be empty.")

        if not self.humor_characteristics.strip():
            raise ValueError("Humor characteristics cannot be empty.")