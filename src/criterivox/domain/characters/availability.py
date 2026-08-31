from __future__ import annotations

from dataclasses import dataclass

from .character import Character


@dataclass(frozen=True, slots=True)
class CharacterAvailability:
    """Runtime availability of a character."""

    character_id: str
    available: bool
    reason: str = ""

    def __post_init__(self) -> None:
        if not self.character_id.strip():
            raise ValueError("Character identifier cannot be empty.")


class CharacterAvailabilityManager:
    """Tracks whether characters are available for activity."""

    def __init__(
        self,
        characters: tuple[Character, ...],
    ) -> None:
        if not characters:
            raise ValueError("Characters cannot be empty.")

        self._characters = {
            character.identity.identifier: character
            for character in characters
        }

        self._availability = {
            character.identity.identifier: True
            for character in characters
        }

    def is_available(self, character_id: str) -> bool:
        """Return whether a character is currently available."""

        if character_id not in self._characters:
            raise KeyError(character_id)

        return self._availability[character_id]

    def set_available(
        self,
        character_id: str,
        available: bool,
    ) -> None:
        """Set the availability of a character."""

        if character_id not in self._characters:
            raise KeyError(character_id)

        self._availability[character_id] = available

    def get_status(
        self,
        character_id: str,
    ) -> CharacterAvailability:
        """Return the current availability status."""

        if character_id not in self._characters:
            raise KeyError(character_id)

        available = self._availability[character_id]

        return CharacterAvailability(
            character_id=character_id,
            available=available,
            reason="" if available else "Character is unavailable.",
        )

    def available_characters(
        self,
        characters: tuple[Character, ...],
    ) -> tuple[Character, ...]:
        """Return only currently available characters."""

        return tuple(
            character
            for character in characters
            if self.is_available(character.identity.identifier)
        )