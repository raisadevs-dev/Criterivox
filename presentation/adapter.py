from __future__ import annotations

from abc import ABC, abstractmethod

from criterivox.presentation.state import CharacterPresentationState


class PresentationAdapter(ABC):
    """Boundary between behavioral state and visual presentation."""

    @abstractmethod
    def present(
        self,
        state: CharacterPresentationState,
    ) -> None:
        """Present a character state."""
        raise NotImplementedError

class RecordingPresentationAdapter(PresentationAdapter):
    """Simple adapter useful for integration and testing."""

    def __init__(self) -> None:
        self._states: list[CharacterPresentationState] = []

    def present(
        self,
        state: CharacterPresentationState,
    ) -> None:
        self._states.append(state)

    @property
    def states(self) -> tuple[CharacterPresentationState, ...]:
        return tuple(self._states)