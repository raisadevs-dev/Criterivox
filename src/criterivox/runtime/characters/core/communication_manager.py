from __future__ import annotations

from dataclasses import dataclass

from .communication_message import (
    CommunicationPriority,
    ContextualMessage,
)
from .communication_priority import highest_priority


@dataclass(frozen=True, slots=True)
class CommunicationManager:
    """Selects meaningful character communication for the current context."""

    def select_message(
        self,
        messages: tuple[ContextualMessage, ...],
    ) -> ContextualMessage | None:
        """Select the most important applicable message.

        Selection order:
        1. Highest communication priority.
        2. Original message order when priorities are equal.
        """

        if not messages:
            return None

        highest = highest_priority(
            *(message.priority for message in messages)
        )

        for message in messages:
            if message.priority is highest:
                return message

        return None

    def select_messages(
        self,
        messages: tuple[ContextualMessage, ...],
        limit: int = 1,
    ) -> tuple[ContextualMessage, ...]:
        """Select up to ``limit`` messages by priority.

        Equal-priority messages retain their original order.
        """

        if limit < 1:
            raise ValueError("Message selection limit must be positive.")

        ordered = tuple(
            sorted(
                messages,
                key=lambda message: message.priority,
                reverse=True,
            )
        )

        return ordered[:limit]