import pytest

from criterivox.domain.characters import get_character
from criterivox.domain.characters.handoff_payload import HandoffPayload
from criterivox.domain.characters.handoff_router import (
    HandoffRouter,
    HandoffResult,
)
from criterivox.domain.characters.state import CharacterState


def test_handoff_routes_from_sender_to_receiver() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")

    payload = HandoffPayload(
        context={"task": "context analysis"},
        result={"finding": "related context identified"},
    )

    result = HandoffRouter().route(
        sender=sender,
        receiver=receiver,
        payload=payload,
    )

    assert isinstance(result, HandoffResult)
    assert result.sender_id == "Dharen"
    assert result.receiver_id == "Sandre"


def test_sender_enters_handoff_state() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")

    result = HandoffRouter().route(
        sender=sender,
        receiver=receiver,
        payload=HandoffPayload(
            context={"task": "analysis"},
        ),
    )

    assert result.sender_state is CharacterState.HANDOFF


def test_receiver_enters_receive_state() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")

    result = HandoffRouter().route(
        sender=sender,
        receiver=receiver,
        payload=HandoffPayload(
            context={"task": "analysis"},
        ),
    )

    assert result.receiver_state is CharacterState.RECEIVE


def test_handoff_preserves_payload() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")

    payload = HandoffPayload(
        context={
            "task": "analysis",
            "source": "context_engine",
        },
        result={"finding": "pattern"},
    )

    result = HandoffRouter().route(
        sender=sender,
        receiver=receiver,
        payload=payload,
    )

    assert result.payload is payload
    assert result.payload.context == {
        "task": "analysis",
        "source": "context_engine",
    }
    assert result.payload.result == {
        "finding": "pattern",
    }


def test_invalid_handoff_is_rejected() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Pramon")

    payload = HandoffPayload(
        context={"task": "analysis"},
    )

    with pytest.raises(
        ValueError,
        match="cannot handoff",
    ):
        HandoffRouter().route(
            sender=sender,
            receiver=receiver,
            payload=payload,
        )


def test_handoff_rejects_invalid_payload_type() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")

    with pytest.raises(
        TypeError,
        match="Payload must be a HandoffPayload",
    ):
        HandoffRouter().route(
            sender=sender,
            receiver=receiver,
            payload="invalid",  # type: ignore[arg-type]
        )