import pytest

from criterivox.domain.characters.communication_message import (
    CommunicationPriority,
    ContextualMessage,
)


def make_message(
    priority: CommunicationPriority = CommunicationPriority.NORMAL,
) -> ContextualMessage:
    return ContextualMessage(
        character_id="Dharen",
        event="context_updated",
        content="Context has been updated.",
        priority=priority,
    )


def test_contextual_message_can_be_created() -> None:
    message = make_message()

    assert message.character_id == "Dharen"
    assert message.event == "context_updated"
    assert message.content == "Context has been updated."
    assert message.priority is CommunicationPriority.NORMAL


def test_critical_message_is_identified() -> None:
    message = make_message(CommunicationPriority.CRITICAL)

    assert message.is_critical


def test_non_critical_message_is_not_critical() -> None:
    message = make_message(CommunicationPriority.NORMAL)

    assert not message.is_critical


def test_message_requires_character_id() -> None:
    with pytest.raises(
        ValueError,
        match="Character identifier",
    ):
        ContextualMessage(
            character_id=" ",
            event="context_updated",
            content="Context updated.",
            priority=CommunicationPriority.NORMAL,
        )


def test_message_requires_event() -> None:
    with pytest.raises(
        ValueError,
        match="Message event",
    ):
        ContextualMessage(
            character_id="Dharen",
            event=" ",
            content="Context updated.",
            priority=CommunicationPriority.NORMAL,
        )


def test_message_requires_content() -> None:
    with pytest.raises(
        ValueError,
        match="Message content",
    ):
        ContextualMessage(
            character_id="Dharen",
            event="context_updated",
            content=" ",
            priority=CommunicationPriority.NORMAL,
        )


def test_communication_priority_order_is_defined() -> None:
    assert CommunicationPriority.LOW < CommunicationPriority.NORMAL
    assert CommunicationPriority.NORMAL < CommunicationPriority.HIGH
    assert CommunicationPriority.HIGH < CommunicationPriority.CRITICAL