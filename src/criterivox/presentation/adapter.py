from __future__ import annotations

from abc import ABC, abstractmethod

from criterivox.domain.characters import CharacterState


class PresentationAdapter(ABC):
    """Interface between character behavior and visual presentation."""

    @abstractmethod
    def present(
        self,
        character_id: str,
        state: CharacterState,
    ) -> None:
        """Present a character in the supplied system state."""
        raise NotImplementedError