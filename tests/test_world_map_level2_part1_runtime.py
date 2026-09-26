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


def test_network_capabilities_match_current_runtime_contract():
    capabilities = level2_runtime.route_status()["capabilities"]
    assert capabilities["loop_interceptor"] == "LIVE"
    assert capabilities["dynamic_edge_weighting"] == "LIVE"
    assert capabilities["protocol_bridge"] == "LIVE"
    assert capabilities["parallel_routing"] == "LIVE_SIMULATION"
    assert capabilities["event_dispatch"] == "PLANNED"


def test_loop_interceptor_trips_on_repeated_transition():
    result = level2_runtime.inspect_loop(["syvax", "anukor", "dharen", "anukor"])
    assert result["status"] == "CIRCUIT_TRIPPED"
    assert result["repeated_transition"] is True


def test_dynamic_edge_weighting_uses_runtime_metrics():
    edge = level2_runtime.update_edge_metric("anukor", "dharen", latency_ms=25, success=True, active_workload=1)
    assert edge["handoffs"] == 1
    assert edge["success_rate"] == 1.0
    assert edge["weight"] > 0


def test_protocol_bridge_returns_validated_translation():
    bridge = level2_runtime.translate_protocol("json", "criterivox-envelope", {"intent": "inspect"})
    assert bridge["validation"] == "VALID"
    assert bridge["translated_payload"]["intent"] == "inspect"


def test_parallel_route_is_explicitly_simulated():
    result = level2_runtime.parallel_route("anukor", ["dharen", "veridat"], "compare evidence")
    assert result["truth"] == "SIMULATED"
    assert len(result["branches"]) == 2


def test_event_dispatch_records_subscriber_delivery():
    level2_runtime.subscribe("FACT_VERIFIED", "veridat")
    event = level2_runtime.dispatch_event("FACT_VERIFIED", "medrus", {"fact_id": "f1"})
    assert event["delivery_state"] == "DELIVERED"
    assert "veridat" in event["subscribers"]
