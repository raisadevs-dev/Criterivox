from __future__ import annotations

from .attention_state import AttentionState


class AttentionCompletion:
    """Handles the attentional consequence of character completion."""

    @staticmethod
    def release(state: AttentionState) -> AttentionState:
        """Return the attention state after completion.

        A character that is COMPLETING becomes QUIET.
        A character that is already QUIET remains QUIET.

        Other states are rejected because completion should not
        silently alter an unrelated attentional state.
        """

        if not isinstance(state, AttentionState):
            raise TypeError(
                "Attention state must be an AttentionState."
            )

        if state is AttentionState.COMPLETING:
            return AttentionState.QUIET

        if state is AttentionState.QUIET:
            return AttentionState.QUIET

        raise ValueError(
            "Completion release requires COMPLETING or QUIET state."
        )