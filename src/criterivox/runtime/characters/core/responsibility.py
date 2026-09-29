from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class CharacterResponsibility:
    """A responsibility assigned to a Criterivox character."""

    identifier: str
    description: str

    def __post_init__(self) -> None:
        if not self.identifier.strip():
            raise ValueError("Responsibility identifier cannot be empty.")

        if not self.description.strip():
            raise ValueError("Responsibility description cannot be empty.")