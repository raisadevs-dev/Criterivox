from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass(frozen=True, slots=True)
class HandoffPayload:
    """Context and result information transferred between characters."""

    context: dict[str, Any] = field(default_factory=dict)
    result: Any = None

    def __post_init__(self) -> None:
        if not isinstance(self.context, dict):
            raise TypeError("Handoff context must be a dictionary.")

    @property
    def has_context(self) -> bool:
        """Return whether the payload contains contextual information."""
        return bool(self.context)

    @property
    def has_result(self) -> bool:
        """Return whether the payload contains a result."""
        return self.result is not None