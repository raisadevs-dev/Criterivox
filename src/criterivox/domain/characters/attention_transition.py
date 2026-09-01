from __future__ import annotations

from .attention_state import AttentionState


class AttentionTransitionError(ValueError):
    """Raised when an attention-state transition is not permitted."""


_VALID_TRANSITIONS: dict[AttentionState, frozenset[AttentionState]] = {
    AttentionState.QUIET: frozenset(
        {
            AttentionState.ATTENTIVE,
        }
    ),
    AttentionState.ATTENTIVE: frozenset(
        {
            AttentionState.QUIET,
            AttentionState.FOCUSED,
            AttentionState.WAITING,
            AttentionState.NEEDS_USER,
        }
    ),
    AttentionState.FOCUSED: frozenset(
        {
            AttentionState.BUSY,
            AttentionState.COMPLETING,
            AttentionState.RECOVERING
            if hasattr(AttentionState, "WARNING")
            else AttentionState.RECOVERING,
        }
    ),
    AttentionState.BUSY: frozenset(
        {
            AttentionState.FOCUSED,
            AttentionState.COMPLETING,
            AttentionState.WAITING,
            AttentionState.RECOVERING,
        }
    ),
    AttentionState.WAITING: frozenset(
        {
            AttentionState.ATTENTIVE,
            AttentionState.FOCUSED,
            AttentionState.NEEDS_USER,
            AttentionState.RECOVERING,
        }
    ),
    AttentionState.NEEDS_USER: frozenset(
        {
            AttentionState.ATTENTIVE,
            AttentionState.FOCUSED,
            AttentionState.WAITING,
        }
    ),
    AttentionState.COMPLETING: frozenset(
        {
            AttentionState.QUIET,
            AttentionState.RECOVERING,
        }
    ),
    AttentionState.RECOVERING: frozenset(
        {
            AttentionState.QUIET,
            AttentionState.ATTENTIVE,
            AttentionState.FOCUSED,
        }
    ),
}


def can_transition(
    current: AttentionState,
    target: AttentionState,
) -> bool:
    """Return whether an attention-state transition is permitted."""

    return target in _VALID_TRANSITIONS.get(current, frozenset())


def transition_attention(
    current: AttentionState,
    target: AttentionState,
) -> AttentionState:
    """Transition to a valid attention state.

    Raises:
        AttentionTransitionError:
            If the requested transition is not permitted.
    """

    if not can_transition(current, target):
        raise AttentionTransitionError(
            f"Invalid attention transition: "
            f"{current.value} -> {target.value}"
        )

    return target


def valid_attention_transitions(
    current: AttentionState,
) -> frozenset[AttentionState]:
    """Return all states directly reachable from the current state."""

    return _VALID_TRANSITIONS.get(
        current,
        frozenset(),
    )