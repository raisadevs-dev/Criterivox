from __future__ import annotations

from dataclasses import dataclass

from criterivox.domain.characters import CharacterState
from criterivox.application.bloom_integration import (
    ApplicationEvent,
    BloomIntegration,
)


@dataclass(frozen=True, slots=True)
class AgentFlowStep:
    """One observable step in an agent activity flow."""

    character_id: str
    state: CharacterState


@dataclass(frozen=True, slots=True)
class AgentFlow:
    """Behavior flow triggered for one application event."""

    event: ApplicationEvent
    steps: tuple[AgentFlowStep, ...]


class AgentFlowCoordinator:
    """Connects application events to the character lifecycle."""

    _LIFECYCLE = (
        CharacterState.RECEIVE,
        CharacterState.WORK,
        CharacterState.COMMUNICATE,
        CharacterState.COMPLETE,
    )

    def __init__(self) -> None:
        self._integration = BloomIntegration()

    def create_flow(
        self,
        event: ApplicationEvent,
    ) -> AgentFlow:
        """Create the lifecycle flow for all agents relevant to an event."""

        if not isinstance(event, ApplicationEvent):
            raise TypeError(
                "Event must be an ApplicationEvent."
            )

        mapping = self._integration.event_to_agents(event)

        steps = tuple(
            AgentFlowStep(
                character_id=character_id,
                state=state,
            )
            for character_id in mapping.character_ids
            for state in self._LIFECYCLE
        )

        return AgentFlow(
            event=event,
            steps=steps,
        )

    def states_for_agent(
        self,
        event: ApplicationEvent,
        character_id: str,
    ) -> tuple[CharacterState, ...]:
        """Return the lifecycle states for one relevant agent."""

        if not isinstance(event, ApplicationEvent):
            raise TypeError(
                "Event must be an ApplicationEvent."
            )

        if not character_id.strip():
            raise ValueError(
                "Character identifier cannot be empty."
            )

        mapping = self._integration.event_to_agents(event)

        if character_id not in mapping.character_ids:
            return ()

        return self._LIFECYCLE