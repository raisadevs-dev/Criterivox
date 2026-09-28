from __future__ import annotations

from dataclasses import dataclass

from criterivox.runtime.characters.core import (
    AnimationState,
    CharacterState,
    get_all_characters,
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

    supplied_id = character_id.strip()
    if not supplied_id:
        raise ValueError(
            "Character identifier cannot be empty."
        )

    canonical_ids = {
        item.identity.identifier.lower()
        for item in get_all_characters()
    }
    if supplied_id.lower() not in canonical_ids:
        raise ValueError(f"Unknown character identifier: {character_id}")

    if not isinstance(state, CharacterState):
        raise TypeError(
            "State must be a CharacterState."
        )

    return VisualPresentation(
        character_id=supplied_id,
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