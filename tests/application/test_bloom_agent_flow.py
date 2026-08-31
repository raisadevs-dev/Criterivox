from criterivox.application.agent_flow import AgentFlowCoordinator
from criterivox.application.bloom_integration import (
    ApplicationEvent,
    BloomCapability,
    BloomIntegration,
)
from criterivox.domain.characters import CharacterState


def test_bloom_analyze_flows_to_agents() -> None:
    integration = BloomIntegration()
    coordinator = AgentFlowCoordinator()

    action_mapping = integration.map_capability(
        BloomCapability.ANALYZE,
    )

    event = integration.action_to_event(
        action_mapping.action,
    )

    assert event is ApplicationEvent.ANALYSIS_REQUESTED

    agent_mapping = integration.event_to_agents(event)

    assert agent_mapping.character_ids == (
        "Dharen",
        "Vivren",
        "Tarkis",
        "Sandre",
        "Pramon",
    )

    flow = coordinator.create_flow(event)

    assert tuple(
        step.state
        for step in flow.steps
        if step.character_id == "Dharen"
    ) == (
        CharacterState.RECEIVE,
        CharacterState.WORK,
        CharacterState.COMMUNICATE,
        CharacterState.COMPLETE,
    )


def test_bloom_explain_flows_to_explanation_agents() -> None:
    integration = BloomIntegration()
    coordinator = AgentFlowCoordinator()

    action_mapping = integration.map_capability(
        BloomCapability.EXPLAIN,
    )

    event = integration.action_to_event(
        action_mapping.action,
    )

    assert event is ApplicationEvent.EXPLANATION_REQUESTED

    agent_mapping = integration.event_to_agents(event)

    assert agent_mapping.character_ids == (
        "Epistre",
        "Syvax",
    )

    flow = coordinator.create_flow(event)

    assert {
        step.character_id
        for step in flow.steps
    } == {
        "Epistre",
        "Syvax",
    }


def test_irrelevant_agent_does_not_enter_flow() -> None:
    integration = BloomIntegration()
    coordinator = AgentFlowCoordinator()

    action_mapping = integration.map_capability(
        BloomCapability.EXPLAIN,
    )

    event = integration.action_to_event(
        action_mapping.action,
    )

    assert event is ApplicationEvent.EXPLANATION_REQUESTED

    assert coordinator.states_for_agent(
        event,
        "Dharen",
    ) == ()

    assert coordinator.states_for_agent(
        event,
        "Epistre",
    ) == (
        CharacterState.RECEIVE,
        CharacterState.WORK,
        CharacterState.COMMUNICATE,
        CharacterState.COMPLETE,
    )