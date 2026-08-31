import pytest

from criterivox.domain.characters.state import CharacterState
from criterivox.domain.characters.state_manager import (
    CharacterStateManager,
    InvalidStateTransition,
)


def test_state_manager_starts_idle() -> None:
    manager = CharacterStateManager()

    assert manager.current_state is CharacterState.IDLE


def test_valid_main_lifecycle_transitions() -> None:
    manager = CharacterStateManager()

    manager.transition(CharacterState.RECEIVE)
    assert manager.current_state is CharacterState.RECEIVE

    manager.transition(CharacterState.WORK)
    assert manager.current_state is CharacterState.WORK

    manager.transition(CharacterState.COMMUNICATE)
    assert manager.current_state is CharacterState.COMMUNICATE

    manager.transition(CharacterState.COMPLETE)
    assert manager.current_state is CharacterState.COMPLETE

    manager.transition(CharacterState.IDLE)
    assert manager.current_state is CharacterState.IDLE


def test_work_can_transition_to_handoff() -> None:
    manager = CharacterStateManager()

    manager.transition(CharacterState.RECEIVE)
    manager.transition(CharacterState.WORK)

    assert manager.can_transition(CharacterState.HANDOFF)

    manager.transition(CharacterState.HANDOFF)

    assert manager.current_state is CharacterState.HANDOFF


def test_work_can_transition_to_warning() -> None:
    manager = CharacterStateManager()

    manager.transition(CharacterState.RECEIVE)
    manager.transition(CharacterState.WORK)

    assert manager.can_transition(CharacterState.WARNING)

    manager.transition(CharacterState.WARNING)

    assert manager.current_state is CharacterState.WARNING


def test_handoff_returns_to_receive() -> None:
    manager = CharacterStateManager()

    manager.transition(CharacterState.RECEIVE)
    manager.transition(CharacterState.WORK)
    manager.transition(CharacterState.HANDOFF)
    manager.transition(CharacterState.RECEIVE)

    assert manager.current_state is CharacterState.RECEIVE


def test_warning_returns_to_idle() -> None:
    manager = CharacterStateManager()

    manager.transition(CharacterState.RECEIVE)
    manager.transition(CharacterState.WORK)
    manager.transition(CharacterState.WARNING)
    manager.transition(CharacterState.IDLE)

    assert manager.current_state is CharacterState.IDLE


def test_invalid_transition_is_rejected() -> None:
    manager = CharacterStateManager()

    with pytest.raises(
        InvalidStateTransition,
        match="Invalid character state transition",
    ):
        manager.transition(CharacterState.WORK)


def test_invalid_transition_does_not_change_state() -> None:
    manager = CharacterStateManager()

    with pytest.raises(InvalidStateTransition):
        manager.transition(CharacterState.WORK)

    assert manager.current_state is CharacterState.IDLE


def test_can_transition_returns_false_for_invalid_transition() -> None:
    manager = CharacterStateManager()

    assert not manager.can_transition(CharacterState.WORK)
    assert manager.can_transition(CharacterState.RECEIVE)


def test_available_transitions_from_idle() -> None:
    manager = CharacterStateManager()

    assert manager.available_transitions() == frozenset(
        {
            CharacterState.RECEIVE,
        }
    )


def test_available_transitions_from_work() -> None:
    manager = CharacterStateManager()

    manager.transition(CharacterState.RECEIVE)
    manager.transition(CharacterState.WORK)

    assert manager.available_transitions() == frozenset(
        {
            CharacterState.COMMUNICATE,
            CharacterState.HANDOFF,
            CharacterState.WARNING,
        }
    )


def test_reset_returns_character_to_idle() -> None:
    manager = CharacterStateManager()

    manager.transition(CharacterState.RECEIVE)
    manager.transition(CharacterState.WORK)

    manager.reset()

    assert manager.current_state is CharacterState.IDLE