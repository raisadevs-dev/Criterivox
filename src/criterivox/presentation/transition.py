from __future__ import annotations

from dataclasses import dataclass

from criterivox.domain.characters import (
    AnimationState,
    CharacterState,
)
from criterivox.presentation.states import VisualPresentation


@dataclass(frozen=True, slots=True)
class PresentationTransition:
    """A meaningful transition between two character presentation states."""

    character_id: str
    from_state: CharacterState
    to_state: CharacterState
    from_animation: AnimationState
    to_animation: AnimationState
    animated: bool


def create_transition(
    current: VisualPresentation,
    target_state: CharacterState,
    *,
    reduced_motion: bool = False,
) -> PresentationTransition:
    """Create a presentation transition that follows the system state."""

    if not isinstance(target_state, CharacterState):
        raise TypeError(
            "Target state must be a CharacterState."
        )

    if not isinstance(reduced_motion, bool):
        raise TypeError(
            "Reduced motion must be a boolean."
        )

    target_animation = AnimationState(target_state.value)

    return PresentationTransition(
        character_id=current.character_id,
        from_state=current.state,
        to_state=target_state,
        from_animation=current.animation,
        to_animation=target_animation,
        animated=not reduced_motion and current.state is not target_state,
    )


def transition_is_consistent(
    transition: PresentationTransition,
) -> bool:
    """Verify that visual states exactly represent system states."""

    return (
        transition.from_animation.value
        == transition.from_state.value
        and transition.to_animation.value
        == transition.to_state.value
    )