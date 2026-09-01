import pytest

from criterivox.domain.characters import (
    Character,
    get_all_characters,
)
from criterivox.domain.characters.attention import CharacterAttention
from criterivox.domain.characters.attention_priority import (
    AttentionPriority,
)
from criterivox.domain.characters.attention_selection import (
    AttentionCandidate,
    AttentionSelection,
)
from criterivox.domain.characters.attention_state import AttentionState


def make_character(
    character: Character,
    attention_state: AttentionState,
) -> Character:
    """Return a copy of a character with a different attention state."""

    return Character(
        identity=character.identity,
        role=character.role,
        responsibilities=character.responsibilities,
        personality=character.personality,
        communication=character.communication,
        attention=CharacterAttention(
            default_state=attention_state,
            attention_description=(
                character.attention.attention_description
            ),
        ),
        handoffs=character.handoffs,
        contextual_triggers=character.contextual_triggers,
        behavior=character.behavior,
    )


def test_prioritize_returns_attention_candidates() -> None:
    characters = get_all_characters()[:2]

    result = AttentionSelection.prioritize(characters)

    assert result
    assert all(
        isinstance(candidate, AttentionCandidate)
        for candidate in result
    )


def test_prioritize_orders_highest_priority_first() -> None:
    characters = get_all_characters()

    first = make_character(
        characters[0],
        AttentionState.ATTENTIVE,
    )
    second = make_character(
        characters[1],
        AttentionState.BUSY,
    )
    third = make_character(
        characters[2],
        AttentionState.NEEDS_USER,
    )

    result = AttentionSelection.prioritize(
        (first, second, third)
    )

    assert [
        candidate.character.identity.identifier
        for candidate in result
    ] == [
        third.identity.identifier,
        second.identity.identifier,
        first.identity.identifier,
    ]


def test_prioritize_uses_attention_priority() -> None:
    characters = get_all_characters()

    focused = make_character(
        characters[0],
        AttentionState.FOCUSED,
    )
    recovering = make_character(
        characters[1],
        AttentionState.RECOVERING,
    )

    result = AttentionSelection.prioritize(
        (recovering, focused)
    )

    assert result[0].priority == AttentionPriority.for_state(
        AttentionState.FOCUSED
    )
    assert result[1].priority == AttentionPriority.for_state(
        AttentionState.RECOVERING
    )


def test_equal_priority_preserves_input_order() -> None:
    characters = get_all_characters()

    first = make_character(
        characters[0],
        AttentionState.ATTENTIVE,
    )
    second = make_character(
        characters[1],
        AttentionState.RECOVERING,
    )

    result = AttentionSelection.prioritize(
        (first, second)
    )

    assert [
        candidate.character.identity.identifier
        for candidate in result
    ] == [
        first.identity.identifier,
        second.identity.identifier,
    ]


def test_prioritize_preserves_all_characters() -> None:
    characters = get_all_characters()

    result = AttentionSelection.prioritize(characters)

    assert len(result) == len(characters)

    result_ids = {
        candidate.character.identity.identifier
        for candidate in result
    }

    original_ids = {
        character.identity.identifier
        for character in characters
    }

    assert result_ids == original_ids


def test_prioritize_empty_collection() -> None:
    result = AttentionSelection.prioritize(())

    assert result == ()


def test_prioritize_by_state_returns_matching_characters() -> None:
    characters = get_all_characters()

    focused = make_character(
        characters[0],
        AttentionState.FOCUSED,
    )
    quiet = make_character(
        characters[1],
        AttentionState.QUIET,
    )

    result = AttentionSelection.prioritize_by_state(
        (focused, quiet),
        AttentionState.FOCUSED,
    )

    assert len(result) == 1
    assert (
        result[0].character.identity.identifier
        == focused.identity.identifier
    )


def test_prioritize_by_state_returns_empty_when_no_match() -> None:
    characters = get_all_characters()[:2]

    quiet_characters = tuple(
        make_character(character, AttentionState.QUIET)
        for character in characters
    )

    result = AttentionSelection.prioritize_by_state(
        quiet_characters,
        AttentionState.NEEDS_USER,
    )

    assert result == ()


def test_prioritize_by_state_rejects_invalid_state() -> None:
    characters = get_all_characters()[:1]

    with pytest.raises(
        TypeError,
        match="Attention state must be an AttentionState",
    ):
        AttentionSelection.prioritize_by_state(
            characters,
            "focused",  # type: ignore[arg-type]
        )