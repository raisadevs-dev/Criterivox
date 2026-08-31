from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class CharacterHandoff:
    """A permitted information-flow relationship between characters."""

    target_character_id: str
    reason: str

    def __post_init__(self) -> None:
        if not self.target_character_id.strip():
            raise ValueError("Target character identifier cannot be empty.")

        if not self.reason.strip():
            raise ValueError("Handoff reason cannot be empty.")