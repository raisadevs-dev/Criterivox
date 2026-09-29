from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class CharacterIdentity:
    """Stable identity of a Criterivox character."""

    identifier: str
    name: str

    def __post_init__(self) -> None:
        if not self.identifier.strip():
            raise ValueError("Character identifier cannot be empty.")

        if not self.name.strip():
            raise ValueError("Character name cannot be empty.")