import pytest

from criterivox.domain.characters import get_character
from criterivox.domain.characters.handoff_payload import HandoffPayload
from criterivox.domain.characters.handoff_router import HandoffRouter
from criterivox.domain.characters.state import CharacterState


def test_successful_handoff_preserves_sender_receiver_and_payload() -> None:
    sender = get_character("Dharen")
    receiver = get_character("Sandre")

    payload = HandoffPayload(
        context={"task": "context analysis"},
        result={"finding": "context connected"},
    )

    result = HandoffRouter().route(
        sender=sender,
        receiver=receiver,
        payload=payload,
    )

    assert result.sender_id == "Dharen"
    assert result.receiver_id == "Sandre"
    assert result.payload is payload


def test_successful_handoff_sets_sender_to_handoff() -> None:
    result = HandoffRouter().route(
        sender=get_character("Dharen"),
        receiver=get_character("Sandre"),
        payload=HandoffPayload(
            context={"task": "analysis"},
        ),
    )

    assert result.sender_state is CharacterState.HANDOFF


def test_successful_handoff_sets_receiver_to_receive() -> None:
    result = HandoffRouter().route(
        sender=get_character("Dharen"),
        receiver=get_character("Sandre"),
        payload=HandoffPayload(
            context={"task": "analysis"},
        ),
    )

    assert result.receiver_state is CharacterState.RECEIVE


def test_invalid_handoff_relationship_is_rejected() -> None:
    with pytest.raises(
        ValueError,
        match="cannot handoff",
    ):
        HandoffRouter().route(
            sender=get_character("Dharen"),
            receiver=get_character("Pramon"),
            payload=HandoffPayload(
                context={"task": "analysis"},
            ),
        )


def test_self_handoff_is_rejected() -> None:
    character = get_character("Dharen")

    with pytest.raises(
        ValueError,
        match="must be different",
    ):
        HandoffRouter().route(
            sender=character,
            receiver=character,
            payload=HandoffPayload(),
        )