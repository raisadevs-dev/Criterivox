from criterivox.world.level2_part1 import (
    AttentionState,
    CharacterState,
    TruthClass,
    HOMES,
    CHARACTERS,
    level2_runtime,
)


def test_level2_registry_contains_all_fifteen_characters_and_seven_homes():
    assert len(CHARACTERS) == 15
    assert len(HOMES) == 7
    assert {c.character_id for c in CHARACTERS}.__contains__("anukor")


def test_anukor_is_network_resident_without_home():
    anukor = next(c for c in CHARACTERS if c.character_id == "anukor")
    assert anukor.home_id is None
    assert "routing" in anukor.capabilities


def test_runtime_state_has_truth_class_and_semantic_states():
    state = level2_runtime.set_state(
        "dharen",
        state=CharacterState.WORK,
        attention=AttentionState.FOCUSED,
        task="context inspection",
        event="context received",
    )
    assert state.state is CharacterState.WORK
    assert state.attention is AttentionState.FOCUSED
    assert state.truth is TruthClass.LIVE


def test_simulated_handshake_is_explicitly_simulated_and_traceable():
    route = level2_runtime.create_route(
        source="syvax",
        destination="dharen",
        intent="inspect context",
        simulation=True,
    )
    assert route.truth is TruthClass.SIMULATED
    assert route.visited_nodes == ["syvax", "anukor", "dharen"]
    trace = level2_runtime.trace(route.trace_id)
    assert trace is not None
    assert trace.truth is TruthClass.SIMULATED
    assert [span.actor for span in trace.spans] == ["syvax", "anukor", "dharen"]


def test_context_envelope_excludes_private_chain_of_thought_by_default():
    envelope = level2_runtime.envelope(
        source="syvax",
        target="dharen",
        intent="inspect context",
        required_context={"task": "test"},
    )
    assert "private_chain_of_thought" in envelope.excluded_content
    assert envelope.truth is TruthClass.LIVE


def test_planned_network_capabilities_are_not_reported_as_live():
    capabilities = level2_runtime.route_status()["capabilities"]
    assert capabilities["loop_interceptor"] == "PLANNED"
    assert capabilities["dynamic_edge_weighting"] == "PLANNED"
    assert capabilities["protocol_bridge"] == "PLANNED"
    assert capabilities["parallel_routing"] == "PLANNED"
    assert capabilities["event_dispatch"] == "PLANNED"
