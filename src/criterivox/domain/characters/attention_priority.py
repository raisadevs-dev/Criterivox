from __future__ import annotations

from .attention_state import AttentionState


class AttentionPriority:
    """Provides deterministic priority values for attention states."""

    _PRIORITIES: dict[AttentionState, int] = {
        AttentionState.QUIET: 0,
        AttentionState.WAITING: 1,
        AttentionState.ATTENTIVE: 2,
        AttentionState.RECOVERING: 2,
        AttentionState.FOCUSED: 3,
        AttentionState.COMPLETING: 3,
        AttentionState.BUSY: 4,
        AttentionState.NEEDS_USER: 5,
    }

    @classmethod
    def for_state(cls, state: AttentionState) -> int:
        """Return the attention priority for a state."""

        if not isinstance(state, AttentionState):
            raise TypeError(
                "Attention priority requires an AttentionState."
            )

        return cls._PRIORITIES[state]

    @classmethod
    def is_higher(
        cls,
        first: AttentionState,
        second: AttentionState,
    ) -> bool:
        """Return whether the first state has higher priority."""

        return cls.for_state(first) > cls.for_state(second)

    @classmethod
    def is_equal(
        cls,
        first: AttentionState,
        second: AttentionState,
    ) -> bool:
        """Return whether two states have equal priority."""

        return cls.for_state(first) == cls.for_state(second)