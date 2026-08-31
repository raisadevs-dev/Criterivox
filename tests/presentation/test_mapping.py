import pytest

from criterivox.domain.characters import (
    AnimationState,
    CharacterState,
)
from criterivox.presentation.mapping import (
    character_presentation,
    visual_state_for,
)


def test_character_identity_maps_to_presentation() -> None:
    presentation = character_presentation("Dharen")

    assert presentation.character_id == "Dharen"
    assert presentation.presentation_id == "Dharen"


@pytest.mark.parametrize(
    ("state", "expected"),
    (
        (CharacterState.IDLE, AnimationState.IDLE),
        (CharacterState.RECEIVE, AnimationState.RECEIVE),
        (CharacterState.WORK, AnimationState.WORK),
        (CharacterState.COMMUNICATE, AnimationState.COMMUNICATE),
        (CharacterState.HANDOFF, AnimationState.HANDOFF),
        (CharacterState.COMPLETE, AnimationState.COMPLETE),
        (CharacterState.WARNING, AnimationState.WARNING),
    ),
)
def test_character_state_maps_to_visual_state(
    state: CharacterState,
    expected: AnimationState,
) -> None:
    assert visual_state_for(state) is expected


def test_unknown_character_is_rejected() -> None:
    with pytest.raises(KeyError):
        character_presentation("UnknownCharacter")


def test_invalid_state_is_rejected() -> None:
    with pytest.raises(
        TypeError,
        match="State must be a CharacterState",
    ):
        visual_state_for("work")  # type: ignore[arg-type]