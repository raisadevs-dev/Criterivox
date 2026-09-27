from __future__ import annotations

from dataclasses import dataclass

from criterivox.domain.characters import (
    AnimationState,
    CharacterState,
    get_character,
)


@dataclass(frozen=True, slots=True)
class CharacterPresentation:
    """Presentation identity for a Criterivox character."""

    character_id: str
    presentation_id: str


def character_presentation(
    character_id: str,
) -> CharacterPresentation:
    """Map a domain character identity to its presentation identity."""

    character = get_character(character_id)

    return CharacterPresentation(
        character_id=character.identity.identifier,
        presentation_id=character.identity.identifier,
    )


def visual_state_for(
    state: CharacterState,
) -> AnimationState:
    """Map a domain state to its presentation state."""

    if not isinstance(state, CharacterState):
        raise TypeError(
            "State must be a CharacterState."
        )

    return AnimationState(state.value)