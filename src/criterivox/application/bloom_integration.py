from __future__ import annotations

from dataclasses import dataclass
from enum import Enum

from criterivox.domain.characters import get_all_characters


class BloomCapability(str, Enum):
    """Capabilities exposed by the Bloom interaction."""

    ANALYZE = "analyze"
    COMPARE = "compare"
    EXPLORE = "explore"
    PLAN = "plan"
    INSIGHTS = "insights"
    EXPLAIN = "explain"


class ApplicationAction(str, Enum):
    """Application-level actions produced by Bloom."""

    REQUEST_ANALYSIS = "request_analysis"
    REQUEST_COMPARISON = "request_comparison"
    REQUEST_EXPLORATION = "request_exploration"
    REQUEST_PLAN = "request_plan"
    REQUEST_INSIGHTS = "request_insights"
    REQUEST_EXPLANATION = "request_explanation"


class ApplicationEvent(str, Enum):
    """Events emitted by application actions."""

    ANALYSIS_REQUESTED = "analysis_requested"
    EXPLANATION_REQUESTED = "explanation_requested"


@dataclass(frozen=True, slots=True)
class BloomActionMapping:
    """Mapping between a Bloom capability and an application action."""

    capability: BloomCapability
    action: ApplicationAction


@dataclass(frozen=True, slots=True)
class EventAgentMapping:
    """Mapping between an application event and relevant characters."""

    event: ApplicationEvent
    character_ids: tuple[str, ...]


class BloomIntegration:
    """Maps Bloom interaction into application actions and agent targets."""

    _CAPABILITY_ACTIONS = {
        BloomCapability.ANALYZE: ApplicationAction.REQUEST_ANALYSIS,
        BloomCapability.COMPARE: ApplicationAction.REQUEST_COMPARISON,
        BloomCapability.EXPLORE: ApplicationAction.REQUEST_EXPLORATION,
        BloomCapability.PLAN: ApplicationAction.REQUEST_PLAN,
        BloomCapability.INSIGHTS: ApplicationAction.REQUEST_INSIGHTS,
        BloomCapability.EXPLAIN: ApplicationAction.REQUEST_EXPLANATION,
    }

    _ACTION_EVENTS = {
        ApplicationAction.REQUEST_ANALYSIS:
            ApplicationEvent.ANALYSIS_REQUESTED,
        ApplicationAction.REQUEST_EXPLANATION:
            ApplicationEvent.EXPLANATION_REQUESTED,
    }

    _EVENT_AGENTS = {
        ApplicationEvent.ANALYSIS_REQUESTED: (
            "Dharen",
            "Vivren",
            "Tarkis",
            "Sandre",
            "Pramon",
        ),
        ApplicationEvent.EXPLANATION_REQUESTED: (
            "Epistre",
            "Syvax",
        ),
    }

    def map_capability(
        self,
        capability: BloomCapability,
    ) -> BloomActionMapping:
        """Map one Bloom capability to an application action."""

        if not isinstance(capability, BloomCapability):
            raise TypeError(
                "Capability must be a BloomCapability."
            )

        return BloomActionMapping(
            capability=capability,
            action=self._CAPABILITY_ACTIONS[capability],
        )

    def action_to_event(
        self,
        action: ApplicationAction,
    ) -> ApplicationEvent | None:
        """Convert an application action into an event when defined."""

        if not isinstance(action, ApplicationAction):
            raise TypeError(
                "Action must be an ApplicationAction."
            )

        return self._ACTION_EVENTS.get(action)

    def event_to_agents(
        self,
        event: ApplicationEvent,
    ) -> EventAgentMapping:
        """Return characters relevant to an application event."""

        if not isinstance(event, ApplicationEvent):
            raise TypeError(
                "Event must be an ApplicationEvent."
            )

        character_ids = self._EVENT_AGENTS.get(event, ())

        registered_ids = {
            character.identity.identifier
            for character in get_all_characters()
        }

        if not set(character_ids).issubset(registered_ids):
            raise ValueError(
                "Event mapping contains an unknown character."
            )

        return EventAgentMapping(
            event=event,
            character_ids=character_ids,
        )