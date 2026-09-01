import pytest

from criterivox.application.bloom_integration import (
    ApplicationAction,
    ApplicationEvent,
    BloomCapability,
    BloomIntegration,
)


@pytest.fixture
def integration() -> BloomIntegration:
    return BloomIntegration()


@pytest.mark.parametrize(
    ("capability", "action"),
    (
        (
            BloomCapability.ANALYZE,
            ApplicationAction.REQUEST_ANALYSIS,
        ),
        (
            BloomCapability.COMPARE,
            ApplicationAction.REQUEST_COMPARISON,
        ),
        (
            BloomCapability.EXPLORE,
            ApplicationAction.REQUEST_EXPLORATION,
        ),
        (
            BloomCapability.PLAN,
            ApplicationAction.REQUEST_PLAN,
        ),
        (
            BloomCapability.INSIGHTS,
            ApplicationAction.REQUEST_INSIGHTS,
        ),
        (
            BloomCapability.EXPLAIN,
            ApplicationAction.REQUEST_EXPLANATION,
        ),
    ),
)
def test_bloom_capability_maps_to_action(
    integration: BloomIntegration,
    capability: BloomCapability,
    action: ApplicationAction,
) -> None:
    mapping = integration.map_capability(capability)

    assert mapping.capability is capability
    assert mapping.action is action


def test_analysis_action_maps_to_analysis_event(
    integration: BloomIntegration,
) -> None:
    event = integration.action_to_event(
        ApplicationAction.REQUEST_ANALYSIS,
    )

    assert event is ApplicationEvent.ANALYSIS_REQUESTED


def test_explanation_action_maps_to_explanation_event(
    integration: BloomIntegration,
) -> None:
    event = integration.action_to_event(
        ApplicationAction.REQUEST_EXPLANATION,
    )

    assert event is ApplicationEvent.EXPLANATION_REQUESTED


def test_unsupported_action_has_no_event(
    integration: BloomIntegration,
) -> None:
    event = integration.action_to_event(
        ApplicationAction.REQUEST_COMPARISON,
    )

    assert event is None


def test_analysis_event_maps_to_relevant_agents(
    integration: BloomIntegration,
) -> None:
    mapping = integration.event_to_agents(
        ApplicationEvent.ANALYSIS_REQUESTED,
    )

    assert mapping.character_ids == (
        "Dharen",
        "Vivren",
        "Tarkis",
        "Sandre",
        "Pramon",
    )


def test_explanation_event_maps_to_relevant_agents(
    integration: BloomIntegration,
) -> None:
    mapping = integration.event_to_agents(
        ApplicationEvent.EXPLANATION_REQUESTED,
    )

    assert mapping.character_ids == (
        "Epistre",
        "Syvax",
    )


def test_analysis_event_agents_exist_in_registry(
    integration: BloomIntegration,
) -> None:
    mapping = integration.event_to_agents(
        ApplicationEvent.ANALYSIS_REQUESTED,
    )

    registered = {
        character.identity.identifier
        for character in __import__(
            "criterivox.domain.characters",
            fromlist=["get_all_characters"],
        ).get_all_characters()
    }

    assert set(mapping.character_ids).issubset(registered)


def test_invalid_capability_is_rejected(
    integration: BloomIntegration,
) -> None:
    with pytest.raises(
        TypeError,
        match="Capability must be a BloomCapability",
    ):
        integration.map_capability(
            "analyze",  # type: ignore[arg-type]
        )


def test_invalid_action_is_rejected(
    integration: BloomIntegration,
) -> None:
    with pytest.raises(
        TypeError,
        match="Action must be an ApplicationAction",
    ):
        integration.action_to_event(
            "request_analysis",  # type: ignore[arg-type]
        )


def test_invalid_event_is_rejected(
    integration: BloomIntegration,
) -> None:
    with pytest.raises(
        TypeError,
        match="Event must be an ApplicationEvent",
    ):
        integration.event_to_agents(
            "analysis_requested",  # type: ignore[arg-type]
        )