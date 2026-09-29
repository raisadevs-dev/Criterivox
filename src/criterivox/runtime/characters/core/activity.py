from __future__ import annotations

from dataclasses import dataclass

from .character import Character
from .state import CharacterState


@dataclass(frozen=True, slots=True)
class CharacterActivity:
    """Current runtime activity of a character."""

    character_id: str
    state: CharacterState


class InvalidCharacterStateTransition(ValueError):
    """Raised when a character attempts an invalid state transition."""


class CharacterActivityManager:
    """Tracks character activity and enforces valid state transitions."""

    _VALID_TRANSITIONS: dict[
        CharacterState,
        frozenset[CharacterState],
    ] = {
        CharacterState.IDLE: frozenset(
            {
                CharacterState.RECEIVE,
            }
        ),
        CharacterState.RECEIVE: frozenset(
            {
                CharacterState.WORK,
                CharacterState.WARNING,
            }
        ),
        CharacterState.WORK: frozenset(
            {
                CharacterState.COMMUNICATE,
                CharacterState.HANDOFF,
                CharacterState.WARNING,
                CharacterState.COMPLETE,
            }
        ),
        CharacterState.COMMUNICATE: frozenset(
            {
                CharacterState.COMPLETE,
                CharacterState.HANDOFF,
                CharacterState.WARNING,
            }
        ),
        CharacterState.HANDOFF: frozenset(
            {
                CharacterState.IDLE,
                CharacterState.RECEIVE,
                CharacterState.WARNING,
            }
        ),
        CharacterState.COMPLETE: frozenset(
            {
                CharacterState.IDLE,
            }
        ),
        CharacterState.WARNING: frozenset(
            {
                CharacterState.IDLE,
                CharacterState.RECEIVE,
                CharacterState.WORK,
            }
        ),
    }

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

        self._states = {
            character.identity.identifier: CharacterState.IDLE
            for character in characters
        }

    def get_state(self, character_id: str) -> CharacterState:
        """Return the current state of a character."""

        self._ensure_character_exists(character_id)

        return self._states[character_id]

    def set_state(
        self,
        character_id: str,
        state: CharacterState,
    ) -> CharacterActivity:
        """Transition a character to a valid next state."""

        self._ensure_character_exists(character_id)

        current_state = self._states[character_id]

        if state is current_state:
            return CharacterActivity(
                character_id=character_id,
                state=current_state,
            )

        if not self.can_transition(current_state, state):
            raise InvalidCharacterStateTransition(
                f"Invalid character state transition: "
                f"{current_state.value} -> {state.value}"
            )

        self._states[character_id] = state

        return CharacterActivity(
            character_id=character_id,
            state=state,
        )

    def can_transition(
        self,
        current_state: CharacterState,
        next_state: CharacterState,
    ) -> bool:
        """Return whether a state transition is valid."""

        return next_state in self._VALID_TRANSITIONS[current_state]

    def get_valid_next_states(
        self,
        character_id: str,
    ) -> frozenset[CharacterState]:
        """Return valid next states for a character."""

        current_state = self.get_state(character_id)

        return self._VALID_TRANSITIONS[current_state]

    def get_activity(
        self,
        character_id: str,
    ) -> CharacterActivity:
        """Return the current activity of a character."""

        return CharacterActivity(
            character_id=character_id,
            state=self.get_state(character_id),
        )

    def reset(
        self,
        character_id: str,
    ) -> CharacterActivity:
        """Return a character to IDLE through a valid transition."""

        current_state = self.get_state(character_id)

        if current_state is CharacterState.IDLE:
            return self.get_activity(character_id)

        return self.set_state(
            character_id,
            CharacterState.IDLE,
        )

    def _ensure_character_exists(self, character_id: str) -> None:
        if character_id not in self._characters:
            raise KeyError(character_id)