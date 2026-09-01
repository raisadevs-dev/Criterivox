import pytest

from criterivox.domain.characters import (
    AnimationState,
    CharacterState,
)
from criterivox.presentation.states import present_state
from criterivox.presentation.transition import (
    PresentationTransition,
    create_transition,
    transition_is_consistent,
)


def test_transition_from_idle_to_work() -> None:
    current = present_state(
        "Dharen",
        CharacterState.IDLE,
    )

    transition = create_transition(
        current,
        CharacterState.WORK,
    )

    assert isinstance(
        transition,
        PresentationTransition,
    )
    assert transition.character_id == "Dharen"
    assert transition.from_state is CharacterState.IDLE
    assert transition.to_state is CharacterState.WORK
    assert transition.from_animation is AnimationState.IDLE
    assert transition.to_animation is AnimationState.WORK
    assert transition.animated


def test_transition_from_work_to_communicate() -> None:
    current = present_state(
        "Dharen",
        CharacterState.WORK,
    )

    transition = create_transition(
        current,
        CharacterState.COMMUNICATE,
    )

    assert transition.from_state is CharacterState.WORK
    assert transition.to_state is CharacterState.COMMUNICATE
    assert transition.animated


def test_same_state_does_not_create_meaningful_animation() -> None:
    current = present_state(
        "Dharen",
        CharacterState.WORK,
    )

    transition = create_transition(
        current,
        CharacterState.WORK,
    )

    assert transition.from_state is CharacterState.WORK
    assert transition.to_state is CharacterState.WORK
    assert not transition.animated


def test_reduced_motion_disables_animation() -> None:
    current = present_state(
        "Dharen",
        CharacterState.IDLE,
    )

    transition = create_transition(
        current,
        CharacterState.WORK,
        reduced_motion=True,
    )

    assert transition.from_state is CharacterState.IDLE
    assert transition.to_state is CharacterState.WORK
    assert not transition.animated


@pytest.mark.parametrize(
    "target_state",
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
def test_transition_visual_state_matches_target_system_state(
    target_state: CharacterState,
) -> None:
    current = present_state(
        "Dharen",
        CharacterState.IDLE,
    )

    transition = create_transition(
        current,
        target_state,
    )

    assert transition.to_animation.value == target_state.value
    assert transition_is_consistent(transition)


def test_transition_preserves_character_identity() -> None:
    current = present_state(
        "Veridat",
        CharacterState.WORK,
    )

    transition = create_transition(
        current,
        CharacterState.WARNING,
    )

    assert transition.character_id == "Veridat"


def test_invalid_target_state_is_rejected() -> None:
    current = present_state(
        "Dharen",
        CharacterState.IDLE,
    )

    with pytest.raises(
        TypeError,
        match="Target state must be a CharacterState",
    ):
        create_transition(
            current,
            "work",  # type: ignore[arg-type]
        )


def test_invalid_reduced_motion_value_is_rejected() -> None:
    current = present_state(
        "Dharen",
        CharacterState.IDLE,
    )

    with pytest.raises(
        TypeError,
        match="Reduced motion must be a boolean",
    ):
        create_transition(
            current,
            CharacterState.WORK,
            reduced_motion="yes",  # type: ignore[arg-type]
        )


def test_transition_consistency_detects_correct_mapping() -> None:
    current = present_state(
        "Dharen",
        CharacterState.RECEIVE,
    )

    transition = create_transition(
        current,
        CharacterState.HANDOFF,
    )

    assert transition_is_consistent(transition)