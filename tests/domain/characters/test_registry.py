import pytest

from criterivox.domain.characters.registry import (
    CHARACTER_REGISTRY,
    CharacterRegistry,
    get_all_characters,
    get_character,
)


EXPECTED_CHARACTERS = (
    "Dharen",
    "Vivren",
    "Tarkis",
    "Sandre",
    "Pramon",
    "Syvax",
    "Bodhex",
    "Medrus",
    "Epistre",
    "Manis",
    "Anuka",
    "Veridat",
    "Viveda",
    "Kaelen",
    "Anukor",
)


def test_registry_contains_complete_character_roster() -> None:
    characters = get_all_characters()

    assert len(characters) == 15
    assert {character.identity.identifier for character in characters} == set(
        EXPECTED_CHARACTERS
    )


def test_registry_contains_unique_character_identities() -> None:
    characters = get_all_characters()

    identities = [
        character.identity.identifier
        for character in characters
    ]

    assert len(identities) == len(set(identities))


@pytest.mark.parametrize("identity", EXPECTED_CHARACTERS)
def test_character_can_be_retrieved_by_identity(identity: str) -> None:
    character = get_character(identity)

    assert character.identity.identifier == identity


@pytest.mark.parametrize("identity", EXPECTED_CHARACTERS)
def test_registered_character_has_required_definition(
    identity: str,
) -> None:
    character = get_character(identity)

    assert character.identity
    assert character.role
    assert character.responsibilities
    assert character.personality
    assert character.behavior
    assert character.communication
    assert character.attention
    assert character.handoffs
    assert character.contextual_triggers


def test_unknown_character_raises_key_error() -> None:
    with pytest.raises(KeyError):
        get_character("UnknownCharacter")


def test_registry_length_matches_complete_roster() -> None:
    assert len(CHARACTER_REGISTRY) == 15


def test_get_all_characters_returns_all_registered_characters() -> None:
    characters = get_all_characters()

    assert len(characters) == len(CHARACTER_REGISTRY)


def test_registry_order_matches_defined_roster() -> None:
    characters = get_all_characters()

    assert (
        tuple(
            character.identity.identifier
            for character in characters
        )
        == EXPECTED_CHARACTERS
    )


def test_registry_contains_characters_by_identifier() -> None:
    assert CHARACTER_REGISTRY.contains("Dharen")
    assert CHARACTER_REGISTRY.contains("Anukor")


def test_registry_rejects_empty_character_collection() -> None:
    with pytest.raises(
        ValueError,
        match="Character registry cannot be empty",
    ):
        CharacterRegistry(())


def test_registry_rejects_duplicate_character_identities() -> None:
    characters = get_all_characters()

    with pytest.raises(
        ValueError,
        match="Character identities must be unique",
    ):
        CharacterRegistry(
            (
                characters[0],
                characters[0],
            )
        )