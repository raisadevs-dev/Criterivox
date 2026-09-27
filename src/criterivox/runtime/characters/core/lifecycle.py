from __future__ import annotations

from dataclasses import dataclass

from .state import CharacterState


@dataclass(frozen=True, slots=True)
class CharacterLifecycle:
    """Manages the activity lifecycle of a Criterivox character.

    The normal lifecycle is:

        IDLE
          ↓
        RECEIVE
          ↓
        WORK
          ↓
        COMMUNICATE
          ↓
        COMPLETE
          ↓
        IDLE

    HANDOFF and WARNING are meaningful branches that may return
    to the normal lifecycle.
    """

    state: CharacterState = CharacterState.IDLE

    def transition(self, target: CharacterState) -> CharacterState:
        """Return a new lifecycle with a valid state transition.

        The lifecycle object is immutable. A transition therefore
        creates and returns a new CharacterLifecycle instance.
        """

        if not isinstance(target, CharacterState):
            raise TypeError(
                "Lifecycle target must be a CharacterState."
            )

        if target not in self.valid_next_states():
            raise ValueError(
                f"Invalid lifecycle transition: "
                f"{self.state.value} -> {target.value}"
            )

        return CharacterLifecycle(state=target)

    def valid_next_states(self) -> frozenset[CharacterState]:
        """Return the states reachable from the current state."""

        transitions: dict[
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
                    CharacterState.HANDOFF,
                    CharacterState.WARNING,
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
                    CharacterState.HANDOFF,
                    CharacterState.WARNING,
                }
            ),
            CharacterState.HANDOFF: frozenset(
                {
                    CharacterState.IDLE,
                    CharacterState.RECEIVE,
                    CharacterState.WORK,
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

        return transitions[self.state]

    def can_transition_to(
        self,
        target: CharacterState,
    ) -> bool:
        """Return whether the requested transition is valid."""

        if not isinstance(target, CharacterState):
            return False

        return target in self.valid_next_states()

    def is_idle(self) -> bool:
        """Return whether the character is currently idle."""

        return self.state is CharacterState.IDLE

    def is_active(self) -> bool:
        """Return whether the character is performing activity."""

        return self.state is not CharacterState.IDLE

    def reset(self) -> CharacterLifecycle:
        """Return the character to IDLE."""

        if self.state is CharacterState.IDLE:
            return self

        if not self.can_transition_to(CharacterState.IDLE):
            raise ValueError(
                f"Cannot reset lifecycle from {self.state.value} to idle."
            )

        return CharacterLifecycle(state=CharacterState.IDLE)