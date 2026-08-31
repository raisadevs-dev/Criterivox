import pytest

from criterivox.domain.characters import get_character
from criterivox.domain.characters.handoff_communication import (
    HandoffCommunication,
    HandoffCommunicationManager,
)
from criterivox.domain.characters.handoff_payload import HandoffPayload


def test_handoff_communication_can_be_created() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")
    payload = HandoffPayload(
        context={"task": "analysis"},
        result={"finding": "pattern"},
    )

    communication = HandoffCommunicationManager().create(
        sender=sender,
        receiver=receiver,
        payload=payload,
    )

    assert isinstance(communication, HandoffCommunication)
    assert communication.sender_id == "Dharen"
    assert communication.receiver_id == "Sandre"


def test_handoff_communication_preserves_payload() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")
    payload = HandoffPayload(
        context={
            "task": "analysis",
            "source": "context_engine",
        },
        result={"finding": "pattern"},
    )

    communication = HandoffCommunicationManager().create(
        sender=sender,
        receiver=receiver,
        payload=payload,
    )

    assert communication.payload is payload
    assert communication.payload.context == {
        "task": "analysis",
        "source": "context_engine",
    }
    assert communication.payload.result == {
        "finding": "pattern",
    }


def test_handoff_communication_identifies_sender_and_receiver() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")

    communication = HandoffCommunicationManager().create(
        sender=sender,
        receiver=receiver,
        payload=HandoffPayload(),
    )

    assert communication.sender_id == sender.identity.identifier
    assert communication.receiver_id == receiver.identity.identifier


def test_handoff_message_is_truthful() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")

    communication = HandoffCommunicationManager().create(
        sender=sender,
        receiver=receiver,
        payload=HandoffPayload(),
    )

    assert communication.message == (
        "Dharen handed context to Sandre."
    )


def test_empty_payload_is_supported() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")

    communication = HandoffCommunicationManager().create(
        sender=sender,
        receiver=receiver,
        payload=HandoffPayload(),
    )

    assert communication.payload.context == {}
    assert communication.payload.result is None


def test_invalid_sender_is_rejected() -> None:
    receiver = get_character("Sandre")

    with pytest.raises(
        TypeError,
        match="Sender must be a Character",
    ):
        HandoffCommunicationManager().create(
            sender="invalid",  # type: ignore[arg-type]
            receiver=receiver,
            payload=HandoffPayload(),
        )


def test_invalid_receiver_is_rejected() -> None:
    sender = get_character("Dharen")

    with pytest.raises(
        TypeError,
        match="Receiver must be a Character",
    ):
        HandoffCommunicationManager().create(
            sender=sender,
            receiver="invalid",  # type: ignore[arg-type]
            payload=HandoffPayload(),
        )


def test_invalid_payload_is_rejected() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")

    with pytest.raises(
        TypeError,
        match="Payload must be a HandoffPayload",
    ):
        HandoffCommunicationManager().create(
            sender=sender,
            receiver=receiver,
            payload="invalid",  # type: ignore[arg-type]
        )