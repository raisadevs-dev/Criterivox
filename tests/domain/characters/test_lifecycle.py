import pytest

from criterivox.domain.characters.lifecycle import CharacterLifecycle
from criterivox.domain.characters.state import CharacterState


def test_lifecycle_starts_idle() -> None:
    lifecycle = CharacterLifecycle()

    assert lifecycle.state is CharacterState.IDLE
    assert lifecycle.is_idle()
    assert not lifecycle.is_active()


def test_normal_lifecycle_can_progress_to_work() -> None:
    lifecycle = CharacterLifecycle()

    lifecycle = lifecycle.transition(CharacterState.RECEIVE)
    lifecycle = lifecycle.transition(CharacterState.WORK)

    assert lifecycle.state is CharacterState.WORK


def test_normal_lifecycle_can_complete() -> None:
    lifecycle = CharacterLifecycle()

    lifecycle = lifecycle.transition(CharacterState.RECEIVE)
    lifecycle = lifecycle.transition(CharacterState.WORK)
    lifecycle = lifecycle.transition(CharacterState.COMMUNICATE)
    lifecycle = lifecycle.transition(CharacterState.COMPLETE)

    assert lifecycle.state is CharacterState.COMPLETE


def test_complete_returns_to_idle() -> None:
    lifecycle = CharacterLifecycle(
        state=CharacterState.COMPLETE,
    )

    lifecycle = lifecycle.transition(CharacterState.IDLE)

    assert lifecycle.state is CharacterState.IDLE


def test_handoff_is_supported_as_branch() -> None:
    lifecycle = CharacterLifecycle(
        state=CharacterState.WORK,
    )

    lifecycle = lifecycle.transition(CharacterState.HANDOFF)

    assert lifecycle.state is CharacterState.HANDOFF


def test_warning_is_supported_as_branch() -> None:
    lifecycle = CharacterLifecycle(
        state=CharacterState.WORK,
    )

    lifecycle = lifecycle.transition(CharacterState.WARNING)

    assert lifecycle.state is CharacterState.WARNING


def test_handoff_can_return_to_workflow() -> None:
    lifecycle = CharacterLifecycle(
        state=CharacterState.WORK,
    )

    lifecycle = lifecycle.transition(CharacterState.HANDOFF)
    lifecycle = lifecycle.transition(CharacterState.RECEIVE)
    lifecycle = lifecycle.transition(CharacterState.WORK)

    assert lifecycle.state is CharacterState.WORK


def test_warning_can_return_to_workflow() -> None:
    lifecycle = CharacterLifecycle(
        state=CharacterState.WORK,
    )

    lifecycle = lifecycle.transition(CharacterState.WARNING)
    lifecycle = lifecycle.transition(CharacterState.WORK)

    assert lifecycle.state is CharacterState.WORK


def test_invalid_transition_is_rejected() -> None:
    lifecycle = CharacterLifecycle()

    with pytest.raises(ValueError, match="Invalid lifecycle transition"):
        lifecycle.transition(CharacterState.WORK)


def test_can_transition_to_reports_valid_transition() -> None:
    lifecycle = CharacterLifecycle(
        state=CharacterState.RECEIVE,
    )

    assert lifecycle.can_transition_to(CharacterState.WORK)
    assert lifecycle.can_transition_to(CharacterState.WARNING)
    assert not lifecycle.can_transition_to(CharacterState.COMPLETE)


def test_invalid_target_type_is_rejected() -> None:
    lifecycle = CharacterLifecycle()

    with pytest.raises(TypeError, match="CharacterState"):
        lifecycle.transition("work")  # type: ignore[arg-type]


def test_lifecycle_is_immutable() -> None:
    lifecycle = CharacterLifecycle()

    next_lifecycle = lifecycle.transition(
        CharacterState.RECEIVE,
    )

    assert lifecycle.state is CharacterState.IDLE
    assert next_lifecycle.state is CharacterState.RECEIVE
    assert lifecycle is not next_lifecycle