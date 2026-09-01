import pytest

from criterivox.domain.characters.attention_priority import (
    AttentionPriority,
)
from criterivox.domain.characters.attention_state import AttentionState


def test_quiet_has_lowest_priority() -> None:
    assert (
        AttentionPriority.for_state(AttentionState.QUIET)
        == 0
    )


@pytest.mark.parametrize(
    ("state", "expected_priority"),
    (
        (AttentionState.WAITING, 1),
        (AttentionState.ATTENTIVE, 2),
        (AttentionState.RECOVERING, 2),
        (AttentionState.FOCUSED, 3),
        (AttentionState.COMPLETING, 3),
        (AttentionState.BUSY, 4),
        (AttentionState.NEEDS_USER, 5),
    ),
)
def test_attention_state_priority(
    state: AttentionState,
    expected_priority: int,
) -> None:
    assert AttentionPriority.for_state(state) == expected_priority


def test_needs_user_has_highest_priority() -> None:
    assert (
        AttentionPriority.for_state(AttentionState.NEEDS_USER)
        > AttentionPriority.for_state(AttentionState.BUSY)
    )


def test_higher_priority_is_detected() -> None:
    assert AttentionPriority.is_higher(
        AttentionState.BUSY,
        AttentionState.ATTENTIVE,
    )


def test_lower_priority_is_not_higher() -> None:
    assert not AttentionPriority.is_higher(
        AttentionState.ATTENTIVE,
        AttentionState.BUSY,
    )


def test_equal_priority_is_detected() -> None:
    assert AttentionPriority.is_equal(
        AttentionState.ATTENTIVE,
        AttentionState.RECOVERING,
    )


def test_different_priority_is_not_equal() -> None:
    assert not AttentionPriority.is_equal(
        AttentionState.FOCUSED,
        AttentionState.BUSY,
    )


def test_invalid_state_is_rejected() -> None:
    with pytest.raises(
        TypeError,
        match="AttentionState",
    ):
        AttentionPriority.for_state("focused")  # type: ignore[arg-type]