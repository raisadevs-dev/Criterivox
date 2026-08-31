from __future__ import annotations

from dataclasses import dataclass

from .character import Character
from .handoff_payload import HandoffPayload


@dataclass(frozen=True, slots=True)
class HandoffCommunication:
    """Communication describing information transferred between characters."""

    sender_id: str
    receiver_id: str
    message: str
    payload: HandoffPayload


class HandoffCommunicationManager:
    """Creates truthful communication for character handoffs."""

    def create(
        self,
        sender: Character,
        receiver: Character,
        payload: HandoffPayload,
    ) -> HandoffCommunication:
        """Create a communication record for a handoff."""

        if not isinstance(sender, Character):
            raise TypeError("Sender must be a Character.")

        if not isinstance(receiver, Character):
            raise TypeError("Receiver must be a Character.")

        if not isinstance(payload, HandoffPayload):
            raise TypeError("Payload must be a HandoffPayload.")

        message = (
            f"{sender.identity.name} handed context to "
            f"{receiver.identity.name}."
        )

        return HandoffCommunication(
            sender_id=sender.identity.identifier,
            receiver_id=receiver.identity.identifier,
            message=message,
            payload=payload,
        )