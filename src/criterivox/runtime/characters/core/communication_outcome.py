from __future__ import annotations

from .communication_message import (
    CommunicationPriority,
    ContextualMessage,
)


def create_uncertainty_message(
    *,
    character_id: str,
    event: str,
    content: str,
) -> ContextualMessage:
    """Create a communication message that explicitly represents uncertainty."""

    return ContextualMessage(
        character_id=character_id,
        event=event,
        content=content,
        priority=CommunicationPriority.HIGH,
    )


def create_completion_message(
    *,
    character_id: str,
    event: str,
    content: str,
) -> ContextualMessage:
    """Create a communication message representing completed work."""

    return ContextualMessage(
        character_id=character_id,
        event=event,
        content=content,
        priority=CommunicationPriority.NORMAL,
    )