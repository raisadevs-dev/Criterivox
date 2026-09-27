from __future__ import annotations

from .communication_message import CommunicationPriority


def is_higher_priority(
    first: CommunicationPriority,
    second: CommunicationPriority,
) -> bool:
    """Return whether the first priority outranks the second."""

    return first > second


def highest_priority(
    *priorities: CommunicationPriority,
) -> CommunicationPriority:
    """Return the highest priority from the supplied priorities."""

    if not priorities:
        raise ValueError("At least one communication priority is required.")

    return max(priorities)


def priority_value(
    priority: CommunicationPriority,
) -> int:
    """Return the numeric value of a communication priority."""

    return int(priority)