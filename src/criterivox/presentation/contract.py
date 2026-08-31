from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any

from criterivox.domain.characters import CharacterState
from criterivox.presentation.states import VisualPresentation


@dataclass(frozen=True, slots=True)
class PresentationContract:
    """Versioned, renderer-independent state sent to a presentation client."""

    contract_version: int
    character_id: str
    character_state: str
    animation: str
    active: bool
    prominence: float
    reduced_motion: bool
    message: str | None = None
    event: str | None = None

    @classmethod
    def from_visual_presentation(
        cls,
        presentation: VisualPresentation,
        *,
        active: bool = True,
        prominence: float = 0.75,
        reduced_motion: bool = False,
        message: str | None = None,
        event: str | None = None,
    ) -> "PresentationContract":
        return cls(
            contract_version=1,
            character_id=presentation.character_id,
            character_state=presentation.state.value,
            animation=presentation.animation.value,
            active=active,
            prominence=max(0.0, min(1.0, prominence)),
            reduced_motion=reduced_motion,
            message=message,
            event=event,
        )

    @classmethod
    def from_state(
        cls,
        character_id: str,
        state: CharacterState,
        *,
        active: bool = True,
        prominence: float = 0.75,
        reduced_motion: bool = False,
        message: str | None = None,
        event: str | None = None,
    ) -> "PresentationContract":
        from criterivox.presentation.states import present_state

        return cls.from_visual_presentation(
            present_state(character_id, state),
            active=active,
            prominence=prominence,
            reduced_motion=reduced_motion,
            message=message,
            event=event,
        )

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
