from __future__ import annotations

from types import MappingProxyType
from typing import Mapping

from .character import Character
from .definitions import create_character_definitions


class CharacterRegistry:
    """Central registry for Criterivox character definitions.

    The registry is responsible only for registration and retrieval.
    Character construction belongs to the definitions module.
    """

    def __init__(self, characters: tuple[Character, ...]) -> None:
        if not characters:
            raise ValueError("Character registry cannot be empty.")

        identifiers = [
            character.identity.identifier
            for character in characters
        ]

        if len(identifiers) != len(set(identifiers)):
            raise ValueError(
                "Character identities must be unique."
            )

        self._characters: Mapping[str, Character] = MappingProxyType(
            {
                character.identity.identifier: character
                for character in characters
            }
        )

    def get(self, identity: str) -> Character:
        """Return a character by stable identity identifier."""
        return self._characters[identity]

    def get_all(self) -> tuple[Character, ...]:
        """Return all registered characters in registration order."""
        return tuple(self._characters.values())

    def contains(self, identity: str) -> bool:
        """Return whether a character is registered."""
        return identity in self._characters

    def __len__(self) -> int:
        return len(self._characters)


def create_character_registry() -> CharacterRegistry:
    """Create the registry from the canonical character definitions."""
    return CharacterRegistry(
        characters=create_character_definitions(),
    )


CHARACTER_REGISTRY = create_character_registry()


def get_character(identity: str) -> Character:
    """Return a registered Criterivox character."""
    return CHARACTER_REGISTRY.get(identity)


def get_all_characters() -> tuple[Character, ...]:
    """Return the complete Criterivox character roster."""
    return CHARACTER_REGISTRY.get_all()


__all__ = [
    "CHARACTER_REGISTRY",
    "CharacterRegistry",
    "create_character_registry",
    "get_all_characters",
    "get_character",
]