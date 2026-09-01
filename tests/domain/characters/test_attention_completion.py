import pytest

from criterivox.domain.characters.attention_completion import (
    AttentionCompletion,
)
from criterivox.domain.characters.attention_state import AttentionState


def test_completing_becomes_quiet() -> None:
    result = AttentionCompletion.release(
        AttentionState.COMPLETING,
    )

    assert result is AttentionState.QUIET


def test_quiet_remains_quiet() -> None:
    result = AttentionCompletion.release(
        AttentionState.QUIET,
    )

    assert result is AttentionState.QUIET


@pytest.mark.parametrize(
    "state",
    (
        AttentionState.ATTENTIVE,
        AttentionState.FOCUSED,
        AttentionState.BUSY,
        AttentionState.WAITING,
        AttentionState.NEEDS_USER,
        AttentionState.RECOVERING,
    ),
)
def test_unrelated_attention_states_are_rejected(
    state: AttentionState,
) -> None:
    with pytest.raises(
        ValueError,
        match="COMPLETING or QUIET",
    ):
        AttentionCompletion.release(state)


def test_invalid_state_type_is_rejected() -> None:
    with pytest.raises(
        TypeError,
        match="AttentionState",
    ):
        AttentionCompletion.release(
            "completing",  # type: ignore[arg-type]
        )