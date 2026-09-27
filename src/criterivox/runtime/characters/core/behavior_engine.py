from __future__ import annotations

from dataclasses import dataclass

from .character import Character
from .state import CharacterState
from .state_manager import CharacterStateManager


class UnsupportedBehavior(ValueError):
    """Raised when a requested behavior is not supported."""


@dataclass(frozen=True, slots=True)
class BehaviorDecision:
    """Result of a character behavior evaluation."""

    character_id: str
    current_state: CharacterState
    next_state: CharacterState
    behavior: str


class BehaviorEngine:
    """Executes shared behavioral primitives for a character."""

    def __init__(
        self,
        character: Character,
        state_manager: CharacterStateManager | None = None,
    ) -> None:
        self.character = character
        self.state_manager = state_manager or CharacterStateManager()

    def receive(self) -> BehaviorDecision:
        """Move the character into the receive state."""
        return self._transition(
            CharacterState.RECEIVE,
            "receive",
        )

    def work(self) -> BehaviorDecision:
        """Move the character into the work state."""
        return self._transition(
            CharacterState.WORK,
            self.character.behavior.work_behavior,
        )

    def communicate(self) -> BehaviorDecision:
        """Move the character into the communicate state."""
        return self._transition(
            CharacterState.COMMUNICATE,
            self.character.behavior.communication_style,
        )

    def handoff(self) -> BehaviorDecision:
        """Move the character into the handoff state."""
        return self._transition(
            CharacterState.HANDOFF,
            "Hands the task to another relevant character.",
        )

    def warning(self) -> BehaviorDecision:
        """Move the character into the warning state."""
        return self._transition(
            CharacterState.WARNING,
            self.character.behavior.warning_behavior,
        )

    def complete(self) -> BehaviorDecision:
        """Move the character into the complete state."""
        return self._transition(
            CharacterState.COMPLETE,
            self.character.behavior.completion_behavior,
        )

    def reset(self) -> BehaviorDecision:
        """Return the character to the idle state."""
        previous_state = self.state_manager.current_state
        next_state = self.state_manager.reset()

        return BehaviorDecision(
            character_id=self.character.identity.identifier,
            current_state=previous_state,
            next_state=next_state,
            behavior=self.character.behavior.completion_behavior,
        )

    def _transition(
        self,
        target: CharacterState,
        behavior: str,
    ) -> BehaviorDecision:
        current_state = self.state_manager.current_state

        if not behavior.strip():
            raise UnsupportedBehavior(
                f"Character '{self.character.identity.identifier}' "
                f"has no behavior defined for '{target.value}'."
            )

        next_state = self.state_manager.transition(target)

        return BehaviorDecision(
            character_id=self.character.identity.identifier,
            current_state=current_state,
            next_state=next_state,
            behavior=behavior,
        )