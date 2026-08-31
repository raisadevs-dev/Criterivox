import pytest

from criterivox.domain.characters.attention_state import AttentionState
from criterivox.domain.characters.attention_transition import (
    AttentionTransitionError,
    can_transition,
    transition_attention,
    valid_attention_transitions,
)


def test_quiet_can_become_attentive() -> None:
    assert can_transition(
        AttentionState.QUIET,
        AttentionState.ATTENTIVE,
    )


def test_attentive_can_become_focused() -> None:
    assert can_transition(
        AttentionState.ATTENTIVE,
        AttentionState.FOCUSED,
    )


def test_focused_can_become_busy() -> None:
    assert can_transition(
        AttentionState.FOCUSED,
        AttentionState.BUSY,
    )


def test_busy_can_become_completing() -> None:
    assert can_transition(
        AttentionState.BUSY,
        AttentionState.COMPLETING,
    )


def test_completing_can_return_to_quiet() -> None:
    assert can_transition(
        AttentionState.COMPLETING,
        AttentionState.QUIET,
    )


def test_invalid_direct_quiet_to_busy_transition() -> None:
    assert not can_transition(
        AttentionState.QUIET,
        AttentionState.BUSY,
    )


def test_invalid_transition_raises_error() -> None:
    with pytest.raises(
        AttentionTransitionError,
        match="Invalid attention transition",
    ):
        transition_attention(
            AttentionState.QUIET,
            AttentionState.BUSY,
        )


def test_valid_transition_returns_target_state() -> None:
    result = transition_attention(
        AttentionState.ATTENTIVE,
        AttentionState.FOCUSED,
    )

    assert result is AttentionState.FOCUSED


def test_valid_attention_transitions_are_exposed() -> None:
    transitions = valid_attention_transitions(
        AttentionState.COMPLETING,
    )

    assert AttentionState.QUIET in transitions
    assert AttentionState.RECOVERING in transitions