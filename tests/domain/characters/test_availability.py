import pytest

from criterivox.domain.characters import (
    CharacterAvailabilityManager,
    get_all_characters,
)


def test_all_characters_start_available() -> None:
    manager = CharacterAvailabilityManager(
        get_all_characters(),
    )

    assert manager.is_available("Dharen")
    assert manager.is_available("Anukor")


def test_character_can_become_unavailable() -> None:
    manager = CharacterAvailabilityManager(
        get_all_characters(),
    )

    manager.set_available("Dharen", False)

    assert not manager.is_available("Dharen")


def test_character_can_become_available_again() -> None:
    manager = CharacterAvailabilityManager(
        get_all_characters(),
    )

    manager.set_available("Dharen", False)
    manager.set_available("Dharen", True)

    assert manager.is_available("Dharen")


def test_unavailable_characters_are_filtered() -> None:
    manager = CharacterAvailabilityManager(
        get_all_characters(),
    )

    manager.set_available("Dharen", False)
    manager.set_available("Vivren", False)

    available = manager.available_characters(
        get_all_characters(),
    )

    identifiers = {
        character.identity.identifier
        for character in available
    }

    assert "Dharen" not in identifiers
    assert "Vivren" not in identifiers
    assert "Tarkis" in identifiers


def test_status_reports_unavailable_character() -> None:
    manager = CharacterAvailabilityManager(
        get_all_characters(),
    )

    manager.set_available("Dharen", False)

    status = manager.get_status("Dharen")

    assert status.character_id == "Dharen"
    assert status.available is False
    assert status.reason == "Character is unavailable."


def test_unknown_character_raises_key_error() -> None:
    manager = CharacterAvailabilityManager(
        get_all_characters(),
    )

    with pytest.raises(KeyError):
        manager.is_available("UnknownCharacter")


def test_empty_character_collection_is_rejected() -> None:
    with pytest.raises(ValueError, match="Characters cannot be empty"):
        CharacterAvailabilityManager(())