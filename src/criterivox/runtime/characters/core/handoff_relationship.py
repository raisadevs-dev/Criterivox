from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class HandoffRelationship:
    """Defines an allowed information-flow relationship."""

    sender_character_id: str
    receiver_character_id: str
    reason: str

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

        if not self.reason.strip():
            raise ValueError(
                "Handoff relationship reason cannot be empty."
            )

    def matches(
        self,
        sender_character_id: str,
        receiver_character_id: str,
    ) -> bool:
        """Return whether the supplied pair matches this relationship."""

        return (
            self.sender_character_id == sender_character_id
            and self.receiver_character_id == receiver_character_id
        )