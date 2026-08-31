import pytest

from criterivox.application.agent_flow import (
    AgentFlowCoordinator,
)
from criterivox.application.bloom_integration import ApplicationEvent
from criterivox.domain.characters import CharacterState


@pytest.fixture
def coordinator() -> AgentFlowCoordinator:
    return AgentFlowCoordinator()


def test_analysis_event_triggers_receive_work_communicate_complete(
    coordinator: AgentFlowCoordinator,
) -> None:
    states = coordinator.states_for_agent(
        ApplicationEvent.ANALYSIS_REQUESTED,
        "Dharen",
    )

    assert states == (
        CharacterState.RECEIVE,
        CharacterState.WORK,
        CharacterState.COMMUNICATE,
        CharacterState.COMPLETE,
    )


def test_explanation_event_triggers_lifecycle(
    coordinator: AgentFlowCoordinator,
) -> None:
    states = coordinator.states_for_agent(
        ApplicationEvent.EXPLANATION_REQUESTED,
        "Epistre",
    )

    assert states == (
        CharacterState.RECEIVE,
        CharacterState.WORK,
        CharacterState.COMMUNICATE,
        CharacterState.COMPLETE,
    )


def test_irrelevant_agent_does_not_activate(
    coordinator: AgentFlowCoordinator,
) -> None:
    states = coordinator.states_for_agent(
        ApplicationEvent.EXPLANATION_REQUESTED,
        "Dharen",
    )

    assert states == ()


def test_analysis_flow_contains_relevant_agents(
    coordinator: AgentFlowCoordinator,
) -> None:
    flow = coordinator.create_flow(
        ApplicationEvent.ANALYSIS_REQUESTED,
    )

    agent_ids = {
        step.character_id
        for step in flow.steps
    }

    assert agent_ids == {
        "Dharen",
        "Vivren",
        "Tarkis",
        "Sandre",
        "Pramon",
    }


def test_flow_preserves_lifecycle_order(
    coordinator: AgentFlowCoordinator,
) -> None:
    flow = coordinator.create_flow(
        ApplicationEvent.ANALYSIS_REQUESTED,
    )

    dharen_states = tuple(
        step.state
        for step in flow.steps
        if step.character_id == "Dharen"
    )

    assert dharen_states == (
        CharacterState.RECEIVE,
        CharacterState.WORK,
        CharacterState.COMMUNICATE,
        CharacterState.COMPLETE,
    )


def test_flow_contains_receive(
    coordinator: AgentFlowCoordinator,
) -> None:
    flow = coordinator.create_flow(
        ApplicationEvent.ANALYSIS_REQUESTED,
    )

    assert any(
        step.state is CharacterState.RECEIVE
        for step in flow.steps
    )


def test_flow_contains_work(
    coordinator: AgentFlowCoordinator,
) -> None:
    flow = coordinator.create_flow(
        ApplicationEvent.ANALYSIS_REQUESTED,
    )

    assert any(
        step.state is CharacterState.WORK
        for step in flow.steps
    )


def test_flow_contains_communicate(
    coordinator: AgentFlowCoordinator,
) -> None:
    flow = coordinator.create_flow(
        ApplicationEvent.ANALYSIS_REQUESTED,
    )

    assert any(
        step.state is CharacterState.COMMUNICATE
        for step in flow.steps
    )


def test_flow_contains_complete(
    coordinator: AgentFlowCoordinator,
) -> None:
    flow = coordinator.create_flow(
        ApplicationEvent.ANALYSIS_REQUESTED,
    )

    assert any(
        step.state is CharacterState.COMPLETE
        for step in flow.steps
    )


def test_invalid_event_is_rejected(
    coordinator: AgentFlowCoordinator,
) -> None:
    with pytest.raises(
        TypeError,
        match="Event must be an ApplicationEvent",
    ):
        coordinator.create_flow(
            "analysis_requested",  # type: ignore[arg-type]
        )


def test_empty_character_id_is_rejected(
    coordinator: AgentFlowCoordinator,
) -> None:
    with pytest.raises(
        ValueError,
        match="Character identifier cannot be empty",
    ):
        coordinator.states_for_agent(
            ApplicationEvent.ANALYSIS_REQUESTED,
            "   ",
        )


def test_flow_records_event(
    coordinator: AgentFlowCoordinator,
) -> None:
    flow = coordinator.create_flow(
        ApplicationEvent.EXPLANATION_REQUESTED,
    )

    assert flow.event is ApplicationEvent.EXPLANATION_REQUESTED