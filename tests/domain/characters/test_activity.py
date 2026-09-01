import pytest

from criterivox.domain.characters import (
    CharacterActivityManager,
    CharacterState,
    get_all_characters,
)
from criterivox.domain.characters.activity import (
    InvalidCharacterStateTransition,
)


def make_manager() -> CharacterActivityManager:
    return CharacterActivityManager(
        get_all_characters(),
    )


def test_all_characters_start_idle() -> None:
    manager = make_manager()

    assert manager.get_state("Dharen") is CharacterState.IDLE
    assert manager.get_state("Anukor") is CharacterState.IDLE


def test_valid_main_lifecycle() -> None:
    manager = make_manager()

    manager.set_state("Dharen", CharacterState.RECEIVE)
    manager.set_state("Dharen", CharacterState.WORK)
    manager.set_state("Dharen", CharacterState.COMMUNICATE)
    manager.set_state("Dharen", CharacterState.COMPLETE)
    manager.set_state("Dharen", CharacterState.IDLE)

    assert manager.get_state("Dharen") is CharacterState.IDLE


def test_valid_handoff_branch() -> None:
    manager = make_manager()

    manager.set_state("Dharen", CharacterState.RECEIVE)
    manager.set_state("Dharen", CharacterState.WORK)
    manager.set_state("Dharen", CharacterState.HANDOFF)
    manager.set_state("Dharen", CharacterState.RECEIVE)

    assert manager.get_state("Dharen") is CharacterState.RECEIVE


def test_valid_warning_branch() -> None:
    manager = make_manager()

    manager.set_state("Dharen", CharacterState.RECEIVE)
    manager.set_state("Dharen", CharacterState.WARNING)
    manager.set_state("Dharen", CharacterState.WORK)

    assert manager.get_state("Dharen") is CharacterState.WORK


def test_invalid_idle_to_work_transition() -> None:
    manager = make_manager()

    with pytest.raises(InvalidCharacterStateTransition):
        manager.set_state(
            "Dharen",
            CharacterState.WORK,
        )


def test_invalid_work_to_idle_transition() -> None:
    manager = make_manager()

    manager.set_state("Dharen", CharacterState.RECEIVE)
    manager.set_state("Dharen", CharacterState.WORK)

    with pytest.raises(InvalidCharacterStateTransition):
        manager.set_state(
            "Dharen",
            CharacterState.IDLE,
        )


def test_invalid_complete_to_work_transition() -> None:
    manager = make_manager()

    manager.set_state("Dharen", CharacterState.RECEIVE)
    manager.set_state("Dharen", CharacterState.WORK)
    manager.set_state("Dharen", CharacterState.COMPLETE)
    manager.set_state("Dharen", CharacterState.IDLE)

    with pytest.raises(InvalidCharacterStateTransition):
        manager.set_state(
            "Dharen",
            CharacterState.WORK,
        )


def test_same_state_is_allowed() -> None:
    manager = make_manager()

    activity = manager.set_state(
        "Dharen",
        CharacterState.IDLE,
    )

    assert activity.state is CharacterState.IDLE


def test_can_transition_reports_valid_transition() -> None:
    manager = make_manager()

    assert manager.can_transition(
        CharacterState.IDLE,
        CharacterState.RECEIVE,
    )

    assert manager.can_transition(
        CharacterState.WORK,
        CharacterState.HANDOFF,
    )

    assert manager.can_transition(
        CharacterState.WORK,
        CharacterState.WARNING,
    )


def test_can_transition_reports_invalid_transition() -> None:
    manager = make_manager()

    assert not manager.can_transition(
        CharacterState.IDLE,
        CharacterState.WORK,
    )

    assert not manager.can_transition(
        CharacterState.COMPLETE,
        CharacterState.WORK,
    )


def test_valid_next_states_match_current_state() -> None:
    manager = make_manager()

    valid_states = manager.get_valid_next_states("Dharen")

    assert valid_states == frozenset(
        {
            CharacterState.RECEIVE,
        }
    )


def test_reset_returns_completed_character_to_idle() -> None:
    manager = make_manager()

    manager.set_state("Dharen", CharacterState.RECEIVE)
    manager.set_state("Dharen", CharacterState.WORK)
    manager.set_state("Dharen", CharacterState.COMPLETE)

    activity = manager.reset("Dharen")

    assert activity.state is CharacterState.IDLE


def test_unknown_character_raises_key_error() -> None:
    manager = make_manager()

    with pytest.raises(KeyError):
        manager.get_state("UnknownCharacter")


def test_empty_character_collection_is_rejected() -> None:
    with pytest.raises(ValueError, match="Characters cannot be empty"):
        CharacterActivityManager(())