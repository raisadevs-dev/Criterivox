from __future__ import annotations

from dataclasses import dataclass

from .handoff_payload import HandoffPayload


@dataclass(frozen=True, slots=True)
class HandoffEvent:
    """Event representing information transfer between two characters."""

    sender_character_id: str
    receiver_character_id: str
    payload: HandoffPayload

    def __post_init__(self) -> None:
        if not self.sender_character_id.strip():
            raise ValueError(
                "Sender character identifier cannot be empty."
            )

        if not self.receiver_character_id.strip():
            raise ValueError(
                "Receiver character identifier cannot be empty."
            )

        if self.sender_character_id == self.receiver_character_id:
            raise ValueError(
                "Sender and receiver must be different characters."
            )

    @property
    def event_type(self) -> str:
        return "handoff"