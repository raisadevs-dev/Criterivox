from __future__ import annotations

from dataclasses import dataclass

from .state import CharacterState


class InvalidStateTransition(ValueError):
    """Raised when a character attempts an invalid state transition."""


_VALID_TRANSITIONS: dict[CharacterState, frozenset[CharacterState]] = {
    CharacterState.IDLE: frozenset(
        {
            CharacterState.RECEIVE,
        }
    ),
    CharacterState.RECEIVE: frozenset(
        {
            CharacterState.WORK,
        }
    ),
    CharacterState.WORK: frozenset(
        {
            CharacterState.COMMUNICATE,
            CharacterState.HANDOFF,
            CharacterState.WARNING,
        }
    ),
    CharacterState.COMMUNICATE: frozenset(
        {
            CharacterState.COMPLETE,
        }
    ),
    CharacterState.COMPLETE: frozenset(
        {
            CharacterState.IDLE,
        }
    ),
    CharacterState.HANDOFF: frozenset(
        {
            CharacterState.RECEIVE,
        }
    ),
    CharacterState.WARNING: frozenset(
        {
            CharacterState.IDLE,
        }
    ),
}


@dataclass
class CharacterStateManager:
    """Manages the runtime state of one Criterivox character."""

    current_state: CharacterState = CharacterState.IDLE

    def can_transition(self, target: CharacterState) -> bool:
        """Return whether the requested state transition is valid."""
        return target in _VALID_TRANSITIONS[self.current_state]

    def transition(self, target: CharacterState) -> CharacterState:
        """Transition to a valid state and return the new state."""
        if not self.can_transition(target):
            raise InvalidStateTransition(
                f"Invalid character state transition: "
                f"{self.current_state.value} -> {target.value}"
            )

        self.current_state = target
        return self.current_state

    def reset(self) -> CharacterState:
        """Return the character to the idle state."""
        self.current_state = CharacterState.IDLE
        return self.current_state

    def available_transitions(
        self,
    ) -> frozenset[CharacterState]:
        """Return all states reachable from the current state."""
        return _VALID_TRANSITIONS[self.current_state]