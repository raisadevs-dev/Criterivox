from __future__ import annotations

from dataclasses import dataclass

from .attention_priority import AttentionPriority
from .attention_state import AttentionState
from .character import Character


@dataclass(frozen=True, slots=True)
class AttentionCandidate:
    """A character considered for attentional prioritization."""

    character: Character
    priority: int


class AttentionSelection:
    """Prioritizes characters that are already relevant to the task."""

    @staticmethod
    def prioritize(
        characters: tuple[Character, ...],
    ) -> tuple[AttentionCandidate, ...]:
        """Return relevant characters ordered by attention priority.

        Higher attention priority appears first.

        Characters with the same priority preserve their original
        registration/input order.
        """

        candidates = tuple(
            AttentionCandidate(
                character=character,
                priority=AttentionPriority.for_state(
                    character.attention.default_state
                ),
            )
            for character in characters
        )

        return tuple(
            sorted(
                candidates,
                key=lambda candidate: candidate.priority,
                reverse=True,
            )
        )

    @staticmethod
    def prioritize_by_state(
        characters: tuple[Character, ...],
        state: AttentionState,
    ) -> tuple[AttentionCandidate, ...]:
        """Prioritize characters currently represented by a given state."""

        if not isinstance(state, AttentionState):
            raise TypeError(
                "Attention state must be an AttentionState."
            )

        matching = tuple(
            character
            for character in characters
            if character.attention.default_state is state
        )

        return AttentionSelection.prioritize(matching)