import pytest

from criterivox.domain.characters.communication_manager import (
    CommunicationManager,
)
from criterivox.domain.characters.communication_message import (
    CommunicationPriority,
    ContextualMessage,
)


def make_message(
    character_id: str,
    content: str,
    priority: CommunicationPriority,
) -> ContextualMessage:
    return ContextualMessage(
        character_id=character_id,
        event="analysis_completed",
        content=content,
        priority=priority,
    )


def test_manager_returns_none_for_empty_messages() -> None:
    manager = CommunicationManager()

    assert manager.select_message(()) is None


def test_manager_selects_highest_priority_message() -> None:
    manager = CommunicationManager()

    low = make_message(
        "Dharen",
        "Low priority update.",
        CommunicationPriority.LOW,
    )
    high = make_message(
        "Veridat",
        "Verification requires attention.",
        CommunicationPriority.HIGH,
    )

    result = manager.select_message((low, high))

    assert result is high


def test_manager_preserves_order_for_equal_priority() -> None:
    manager = CommunicationManager()

    first = make_message(
        "Dharen",
        "First update.",
        CommunicationPriority.NORMAL,
    )
    second = make_message(
        "Vivren",
        "Second update.",
        CommunicationPriority.NORMAL,
    )

    result = manager.select_message((first, second))

    assert result is first


def test_manager_selects_critical_over_all_lower_priorities() -> None:
    manager = CommunicationManager()

    messages = (
        make_message(
            "Dharen",
            "Normal update.",
            CommunicationPriority.NORMAL,
        ),
        make_message(
            "Pramon",
            "Evidence concern.",
            CommunicationPriority.HIGH,
        ),
        make_message(
            "Veridat",
            "Critical verification warning.",
            CommunicationPriority.CRITICAL,
        ),
    )

    result = manager.select_message(messages)

    assert result is messages[2]


def test_select_messages_returns_requested_number() -> None:
    manager = CommunicationManager()

    messages = (
        make_message(
            "Dharen",
            "Normal.",
            CommunicationPriority.NORMAL,
        ),
        make_message(
            "Vivren",
            "High.",
            CommunicationPriority.HIGH,
        ),
        make_message(
            "Veridat",
            "Critical.",
            CommunicationPriority.CRITICAL,
        ),
    )

    result = manager.select_messages(messages, limit=2)

    assert len(result) == 2
    assert result[0] is messages[2]
    assert result[1] is messages[1]


def test_select_messages_returns_all_when_limit_exceeds_count() -> None:
    manager = CommunicationManager()

    messages = (
        make_message(
            "Dharen",
            "First.",
            CommunicationPriority.NORMAL,
        ),
        make_message(
            "Vivren",
            "Second.",
            CommunicationPriority.LOW,
        ),
    )

    result = manager.select_messages(messages, limit=10)

    assert result == messages


def test_select_messages_preserves_equal_priority_order() -> None:
    manager = CommunicationManager()

    first = make_message(
        "Dharen",
        "First.",
        CommunicationPriority.HIGH,
    )
    second = make_message(
        "Vivren",
        "Second.",
        CommunicationPriority.HIGH,
    )

    result = manager.select_messages(
        (first, second),
        limit=2,
    )

    assert result == (first, second)


def test_select_messages_rejects_zero_limit() -> None:
    manager = CommunicationManager()

    with pytest.raises(
        ValueError,
        match="Message selection limit must be positive",
    ):
        manager.select_messages((), limit=0)


def test_select_messages_rejects_negative_limit() -> None:
    manager = CommunicationManager()

    with pytest.raises(
        ValueError,
        match="Message selection limit must be positive",
    ):
        manager.select_messages((), limit=-1)