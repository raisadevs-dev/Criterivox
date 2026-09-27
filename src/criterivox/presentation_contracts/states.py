from __future__ import annotations

from dataclasses import dataclass

from criterivox.domain.characters import (
    AnimationState,
    CharacterState,
)


@dataclass(frozen=True, slots=True)
class VisualPresentation:
    """Visual representation of a character's current system state."""

    character_id: str
    state: CharacterState
    animation: AnimationState


def present_state(
    character_id: str,
    state: CharacterState,
) -> VisualPresentation:
    """Create a presentation that exactly reflects the domain state."""

    if not character_id.strip():
        raise ValueError(
            "Character identifier cannot be empty."
        )

    if not isinstance(state, CharacterState):
        raise TypeError(
            "State must be a CharacterState."
        )

    return VisualPresentation(
        character_id=character_id,
        state=state,
        animation=AnimationState(state.value),
    )


def present_idle(character_id: str) -> VisualPresentation:
    return present_state(
        character_id,
        CharacterState.IDLE,
    )


def present_receive(character_id: str) -> VisualPresentation:
    return present_state(
        character_id,
        CharacterState.RECEIVE,
    )


def present_work(character_id: str) -> VisualPresentation:
    return present_state(
        character_id,
        CharacterState.WORK,
    )


def present_communicate(
    character_id: str,
) -> VisualPresentation:
    return present_state(
        character_id,
        CharacterState.COMMUNICATE,
    )


def present_handoff(
    character_id: str,
) -> VisualPresentation:
    return present_state(
        character_id,
        CharacterState.HANDOFF,
    )


def present_complete(
    character_id: str,
) -> VisualPresentation:
    return present_state(
        character_id,
        CharacterState.COMPLETE,
    )


def present_warning(
    character_id: str,
) -> VisualPresentation:
    return present_state(
        character_id,
        CharacterState.WARNING,
    )