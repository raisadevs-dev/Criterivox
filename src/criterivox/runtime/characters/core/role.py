from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class CharacterRole:
    """Functional role performed by a Criterivox character."""

    identifier: str
    name: str
    description: str

    def __post_init__(self) -> None:
        if not self.identifier.strip():
            raise ValueError("Character role identifier cannot be empty.")

        if not self.name.strip():
            raise ValueError("Character role name cannot be empty.")

        if not self.description.strip():
            raise ValueError("Character role description cannot be empty.")