import pytest

from criterivox.domain.characters.handoff_event import HandoffEvent
from criterivox.domain.characters.handoff_payload import HandoffPayload


def make_payload() -> HandoffPayload:
    return HandoffPayload(
        context={"task": "analysis"},
        result={"finding": "pattern"},
    )


def test_handoff_event_can_be_created() -> None:
    event = HandoffEvent(
        sender_character_id="Dharen",
        receiver_character_id="Tarkis",
        payload=make_payload(),
    )

    assert event.sender_character_id == "Dharen"
    assert event.receiver_character_id == "Tarkis"
    assert event.payload.has_context


def test_handoff_event_type_is_handoff() -> None:
    event = HandoffEvent(
        sender_character_id="Dharen",
        receiver_character_id="Tarkis",
        payload=make_payload(),
    )

    assert event.event_type == "handoff"


def test_handoff_event_preserves_payload() -> None:
    payload = make_payload()

    event = HandoffEvent(
        sender_character_id="Dharen",
        receiver_character_id="Tarkis",
        payload=payload,
    )

    assert event.payload is payload


def test_handoff_event_rejects_empty_sender() -> None:
    with pytest.raises(
        ValueError,
        match="Sender character identifier cannot be empty",
    ):
        HandoffEvent(
            sender_character_id="",
            receiver_character_id="Tarkis",
            payload=make_payload(),
        )


def test_handoff_event_rejects_empty_receiver() -> None:
    with pytest.raises(
        ValueError,
        match="Receiver character identifier cannot be empty",
    ):
        HandoffEvent(
            sender_character_id="Dharen",
            receiver_character_id="",
            payload=make_payload(),
        )


def test_handoff_event_rejects_self_handoff() -> None:
    with pytest.raises(
        ValueError,
        match="Sender and receiver must be different characters",
    ):
        HandoffEvent(
            sender_character_id="Dharen",
            receiver_character_id="Dharen",
            payload=make_payload(),
        )