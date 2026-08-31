from criterivox.domain.characters.communication_message import (
    CommunicationPriority,
    ContextualMessage,
)
from criterivox.domain.characters.communication_suppression import (
    is_repeated_message,
    suppress_repeated_messages,
)


def make_message(
    character_id: str,
    event: str,
    content: str,
    priority: CommunicationPriority = CommunicationPriority.NORMAL,
) -> ContextualMessage:
    return ContextualMessage(
        character_id=character_id,
        event=event,
        content=content,
        priority=priority,
    )


def test_repeated_messages_are_suppressed() -> None:
    message = make_message(
        "Dharen",
        "context_updated",
        "Context has been updated.",
    )

    result = suppress_repeated_messages(
        (message, message),
    )

    assert result == (message,)


def test_different_messages_are_preserved() -> None:
    first = make_message(
        "Dharen",
        "context_updated",
        "Context has been updated.",
    )
    second = make_message(
        "Vivren",
        "analysis_requested",
        "Reasoning requires review.",
    )

    result = suppress_repeated_messages(
        (first, second),
    )

    assert result == (first, second)


def test_repetition_suppression_preserves_first_occurrence() -> None:
    first = make_message(
        "Dharen",
        "context_updated",
        "Context has been updated.",
    )
    duplicate = make_message(
        "Dharen",
        "context_updated",
        "Context has been updated.",
        CommunicationPriority.HIGH,
    )

    result = suppress_repeated_messages(
        (first, duplicate),
    )

    assert result == (first,)


def test_empty_message_collection_is_supported() -> None:
    assert suppress_repeated_messages(()) == ()


def test_message_is_detected_as_repeated() -> None:
    previous = make_message(
        "Dharen",
        "context_updated",
        "Context has been updated.",
    )
    current = make_message(
        "Dharen",
        "context_updated",
        "Context has been updated.",
    )

    assert is_repeated_message(
        current,
        (previous,),
    )


def test_new_message_is_not_detected_as_repeated() -> None:
    previous = make_message(
        "Dharen",
        "context_updated",
        "Context has been updated.",
    )
    current = make_message(
        "Dharen",
        "context_updated",
        "A different context is available.",
    )

    assert not is_repeated_message(
        current,
        (previous,),
    )


def test_same_content_from_different_character_is_not_repeated() -> None:
    previous = make_message(
        "Dharen",
        "context_updated",
        "Context has been updated.",
    )
    current = make_message(
        "Vivren",
        "context_updated",
        "Context has been updated.",
    )

    assert not is_repeated_message(
        current,
        (previous,),
    )


def test_same_content_for_different_event_is_not_repeated() -> None:
    previous = make_message(
        "Dharen",
        "context_updated",
        "Context has been updated.",
    )
    current = make_message(
        "Dharen",
        "analysis_completed",
        "Context has been updated.",
    )

    assert not is_repeated_message(
        current,
        (previous,),
    )