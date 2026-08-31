from __future__ import annotations

from dataclasses import dataclass

from .character import Character
from .handoff_payload import HandoffPayload
from .state import CharacterState


@dataclass(frozen=True, slots=True)
class HandoffResult:
    """Result produced by a successful character handoff."""

    sender_id: str
    receiver_id: str
    payload: HandoffPayload
    sender_state: CharacterState
    receiver_state: CharacterState


class HandoffRouter:
    """Routes contextual information between permitted characters."""

    def route(
        self,
        sender: Character,
        receiver: Character,
        payload: HandoffPayload,
    ) -> HandoffResult:
        """Validate and perform a handoff between two characters."""

        if not isinstance(sender, Character):
            raise TypeError("Sender must be a Character.")

        if not isinstance(receiver, Character):
            raise TypeError("Receiver must be a Character.")

        if not isinstance(payload, HandoffPayload):
            raise TypeError("Payload must be a HandoffPayload.")

        sender_id = sender.identity.identifier
        receiver_id = receiver.identity.identifier

        if sender_id == receiver_id:
            raise ValueError(
                "Sender and receiver must be different characters."
            )

        allowed = any(
            handoff.target_character_id == receiver_id
            for handoff in sender.handoffs
        )

        if not allowed:
            raise ValueError(
                f"Character '{sender_id}' cannot handoff to "
                f"character '{receiver_id}'."
            )

        return HandoffResult(
            sender_id=sender_id,
            receiver_id=receiver_id,
            payload=payload,
            sender_state=CharacterState.HANDOFF,
            receiver_state=CharacterState.RECEIVE,
        )