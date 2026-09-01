import pytest

from criterivox.domain.characters.communication_message import (
    CommunicationPriority,
)
from criterivox.domain.characters.communication_priority import (
    highest_priority,
    is_higher_priority,
    priority_value,
)


def test_higher_priority_is_detected() -> None:
    assert is_higher_priority(
        CommunicationPriority.HIGH,
        CommunicationPriority.NORMAL,
    )


def test_lower_priority_is_not_higher() -> None:
    assert not is_higher_priority(
        CommunicationPriority.NORMAL,
        CommunicationPriority.HIGH,
    )


def test_equal_priority_is_not_higher() -> None:
    assert not is_higher_priority(
        CommunicationPriority.NORMAL,
        CommunicationPriority.NORMAL,
    )


def test_highest_priority_returns_highest_value() -> None:
    result = highest_priority(
        CommunicationPriority.LOW,
        CommunicationPriority.CRITICAL,
        CommunicationPriority.NORMAL,
    )

    assert result is CommunicationPriority.CRITICAL


def test_highest_priority_works_with_single_value() -> None:
    result = highest_priority(
        CommunicationPriority.HIGH,
    )

    assert result is CommunicationPriority.HIGH


def test_highest_priority_requires_at_least_one_value() -> None:
    with pytest.raises(
        ValueError,
        match="At least one communication priority",
    ):
        highest_priority()


def test_priority_value_returns_integer() -> None:
    assert priority_value(CommunicationPriority.LOW) == 1
    assert priority_value(CommunicationPriority.NORMAL) == 2
    assert priority_value(CommunicationPriority.HIGH) == 3
    assert priority_value(CommunicationPriority.CRITICAL) == 4