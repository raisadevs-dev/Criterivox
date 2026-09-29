from __future__ import annotations

from .communication_message import ContextualMessage


def suppress_repeated_messages(
    messages: tuple[ContextualMessage, ...],
) -> tuple[ContextualMessage, ...]:
    """Remove duplicate messages while preserving their original order.

    Messages are considered repeated when their character, event, and
    content are identical. Priority differences do not create a second
    message because the underlying communication is the same.
    """

    seen: set[tuple[str, str, str]] = set()
    result: list[ContextualMessage] = []

    for message in messages:
        key = (
            message.character_id,
            message.event,
            message.content,
        )

        if key in seen:
            continue

        seen.add(key)
        result.append(message)

    return tuple(result)


def is_repeated_message(
    message: ContextualMessage,
    previous_messages: tuple[ContextualMessage, ...],
) -> bool:
    """Return whether the message repeats an earlier communication."""

    return any(
        message.character_id == previous.character_id
        and message.event == previous.event
        and message.content == previous.content
        for previous in previous_messages
    )