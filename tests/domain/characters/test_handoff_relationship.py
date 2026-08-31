import pytest

from criterivox.domain.characters.handoff_relationship import (
    HandoffRelationship,
)


def make_relationship() -> HandoffRelationship:
    return HandoffRelationship(
        sender_character_id="Dharen",
        receiver_character_id="Tarkis",
        reason="Structured context is ready for hypothesis work.",
    )


def test_handoff_relationship_can_be_created() -> None:
    relationship = make_relationship()

    assert relationship.sender_character_id == "Dharen"
    assert relationship.receiver_character_id == "Tarkis"


def test_relationship_preserves_reason() -> None:
    relationship = make_relationship()

    assert (
        relationship.reason
        == "Structured context is ready for hypothesis work."
    )


def test_relationship_matches_sender_and_receiver() -> None:
    relationship = make_relationship()

    assert relationship.matches(
        "Dharen",
        "Tarkis",
    )


def test_relationship_rejects_wrong_sender() -> None:
    relationship = make_relationship()

    assert not relationship.matches(
        "Vivren",
        "Tarkis",
    )


def test_relationship_rejects_wrong_receiver() -> None:
    relationship = make_relationship()

    assert not relationship.matches(
        "Dharen",
        "Veridat",
    )


def test_relationship_rejects_empty_sender() -> None:
    with pytest.raises(
        ValueError,
        match="Sender character identifier cannot be empty",
    ):
        HandoffRelationship(
            sender_character_id="",
            receiver_character_id="Tarkis",
            reason="Valid reason.",
        )


def test_relationship_rejects_empty_receiver() -> None:
    with pytest.raises(
        ValueError,
        match="Receiver character identifier cannot be empty",
    ):
        HandoffRelationship(
            sender_character_id="Dharen",
            receiver_character_id="",
            reason="Valid reason.",
        )


def test_relationship_rejects_self_relationship() -> None:
    with pytest.raises(
        ValueError,
        match="Sender and receiver must be different characters",
    ):
        HandoffRelationship(
            sender_character_id="Dharen",
            receiver_character_id="Dharen",
            reason="Invalid relationship.",
        )


def test_relationship_requires_reason() -> None:
    with pytest.raises(
        ValueError,
        match="Handoff relationship reason cannot be empty",
    ):
        HandoffRelationship(
            sender_character_id="Dharen",
            receiver_character_id="Tarkis",
            reason="   ",
        )