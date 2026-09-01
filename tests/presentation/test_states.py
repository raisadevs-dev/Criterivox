import pytest

from criterivox.domain.characters import (
    AnimationState,
    CharacterState,
)
from criterivox.presentation.states import (
    VisualPresentation,
    present_communicate,
    present_complete,
    present_handoff,
    present_idle,
    present_receive,
    present_state,
    present_warning,
    present_work,
)


def test_idle_presentation() -> None:
    presentation = present_idle("Dharen")

    assert isinstance(presentation, VisualPresentation)
    assert presentation.character_id == "Dharen"
    assert presentation.state is CharacterState.IDLE
    assert presentation.animation is AnimationState.IDLE


def test_receive_presentation() -> None:
    presentation = present_receive("Dharen")

    assert presentation.state is CharacterState.RECEIVE
    assert presentation.animation is AnimationState.RECEIVE


def test_work_presentation() -> None:
    presentation = present_work("Dharen")

    assert presentation.state is CharacterState.WORK
    assert presentation.animation is AnimationState.WORK


def test_communicate_presentation() -> None:
    presentation = present_communicate("Dharen")

    assert presentation.state is CharacterState.COMMUNICATE
    assert presentation.animation is AnimationState.COMMUNICATE


def test_handoff_presentation() -> None:
    presentation = present_handoff("Dharen")

    assert presentation.state is CharacterState.HANDOFF
    assert presentation.animation is AnimationState.HANDOFF


def test_complete_presentation() -> None:
    presentation = present_complete("Dharen")

    assert presentation.state is CharacterState.COMPLETE
    assert presentation.animation is AnimationState.COMPLETE


def test_warning_presentation() -> None:
    presentation = present_warning("Dharen")

    assert presentation.state is CharacterState.WARNING
    assert presentation.animation is AnimationState.WARNING


@pytest.mark.parametrize(
    "state",
    (
        CharacterState.IDLE,
        CharacterState.RECEIVE,
        CharacterState.WORK,
        CharacterState.COMMUNICATE,
        CharacterState.HANDOFF,
        CharacterState.COMPLETE,
        CharacterState.WARNING,
    ),
)
def test_visual_animation_matches_system_state(
    state: CharacterState,
) -> None:
    presentation = present_state(
        "Dharen",
        state,
    )

    assert presentation.state is state
    assert presentation.animation.value == state.value


def test_empty_character_id_is_rejected() -> None:
    with pytest.raises(
        ValueError,
        match="Character identifier cannot be empty",
    ):
        present_idle("   ")


def test_invalid_state_is_rejected() -> None:
    with pytest.raises(
        TypeError,
        match="State must be a CharacterState",
    ):
        present_state(
            "Dharen",
            "work",  # type: ignore[arg-type]
        )