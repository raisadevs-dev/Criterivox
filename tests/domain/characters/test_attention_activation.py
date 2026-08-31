from criterivox.domain.characters import get_all_characters
from criterivox.domain.characters.attention import CharacterAttention
from criterivox.domain.characters.attention_activation import (
    AttentionActivation,
)
from criterivox.domain.characters.attention_selection import (
    AttentionCandidate,
)
from criterivox.domain.characters.attention_state import AttentionState


def make_candidate(
    index: int,
    state: AttentionState,
) -> AttentionCandidate:
    """Create an attention candidate from an existing character."""

    character = get_all_characters()[index]

    character = type(character)(
        identity=character.identity,
        role=character.role,
        responsibilities=character.responsibilities,
        personality=character.personality,
        communication=character.communication,
        attention=CharacterAttention(
            default_state=state,
            attention_description=(
                character.attention.attention_description
            ),
        ),
        handoffs=character.handoffs,
        contextual_triggers=character.contextual_triggers,
        behavior=character.behavior,
    )

    priorities = {
        AttentionState.QUIET: 0,
        AttentionState.WAITING: 1,
        AttentionState.ATTENTIVE: 2,
        AttentionState.RECOVERING: 2,
        AttentionState.FOCUSED: 3,
        AttentionState.COMPLETING: 3,
        AttentionState.BUSY: 4,
        AttentionState.NEEDS_USER: 5,
    }

    return AttentionCandidate(
        character=character,
        priority=priorities[state],
    )


def test_empty_candidates_produce_no_activation() -> None:
    result = AttentionActivation.select(())

    assert result == ()


def test_only_one_candidate_is_activated() -> None:
    candidates = (
        make_candidate(0, AttentionState.ATTENTIVE),
        make_candidate(1, AttentionState.FOCUSED),
        make_candidate(2, AttentionState.BUSY),
    )

    result = AttentionActivation.select(candidates)

    assert len(result) == 1


def test_highest_priority_candidate_is_selected() -> None:
    low = make_candidate(0, AttentionState.ATTENTIVE)
    high = make_candidate(1, AttentionState.BUSY)

    result = AttentionActivation.select(
        (low, high)
    )

    assert result[0].character.identity.identifier == (
        high.character.identity.identifier
    )


def test_needs_user_has_activation_priority() -> None:
    focused = make_candidate(0, AttentionState.FOCUSED)
    needs_user = make_candidate(1, AttentionState.NEEDS_USER)

    result = AttentionActivation.select(
        (focused, needs_user)
    )

    assert result[0].character.identity.identifier == (
        needs_user.character.identity.identifier
    )


def test_equal_priority_does_not_activate_multiple_characters() -> None:
    first = make_candidate(0, AttentionState.FOCUSED)
    second = make_candidate(1, AttentionState.COMPLETING)

    result = AttentionActivation.select(
        (first, second)
    )

    assert len(result) == 1


def test_equal_priority_preserves_first_candidate() -> None:
    first = make_candidate(0, AttentionState.FOCUSED)
    second = make_candidate(1, AttentionState.COMPLETING)

    result = AttentionActivation.select(
        (first, second)
    )

    assert result[0].character.identity.identifier == (
        first.character.identity.identifier
    )


def test_selected_candidate_is_original_candidate() -> None:
    candidate = make_candidate(
        0,
        AttentionState.BUSY,
    )

    result = AttentionActivation.select(
        (candidate,)
    )

    assert result[0] is candidate


def test_selection_does_not_modify_candidates() -> None:
    candidates = (
        make_candidate(0, AttentionState.ATTENTIVE),
        make_candidate(1, AttentionState.BUSY),
    )

    result = AttentionActivation.select(candidates)

    assert len(candidates) == 2
    assert len(result) == 1


def test_quiet_candidate_can_be_selected_when_alone() -> None:
    candidate = make_candidate(
        0,
        AttentionState.QUIET,
    )

    result = AttentionActivation.select(
        (candidate,)
    )

    assert result == (candidate,)