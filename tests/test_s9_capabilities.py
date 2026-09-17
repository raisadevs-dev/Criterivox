from __future__ import annotations

from dataclasses import replace

from criterivox.capabilities import (
    CapabilityDescriptor,
    CapabilityRegistry,
    CapabilityRequest,
    CapabilityResult,
    EventBus,
    HumanAuthority,
    HumanChallengeState,
    PipelineContext,
    PipelineDefinition,
    PipelineExecutor,
    PipelineStep,
    S8ArtifactRepository,
)
from criterivox.capabilities.adapters import make_audit_artifact
from criterivox.capabilities.execution import BudgetExceeded, CircuitBreaker, CircuitTripped, PermissionBoundary, ResourceBudget
from criterivox.capabilities.runtime import ArtifactIntegrity, CapabilityRouter, ExecutionJournal
from criterivox.s8.persistence import S8SQLiteStore


class EchoCapability:
    def __init__(self, name: str = "echo"):
        self.descriptor = CapabilityDescriptor(name, name, input_types=("mapping",), output_types=("mapping",))

    def execute(self, request: CapabilityRequest, context: PipelineContext) -> CapabilityResult:
        return CapabilityResult(request.request_id, request.capability_id, "OK", {"value": request.payload.get("input", request.payload)})


def test_multiple_homes_reuse_one_capability_without_character_dependency() -> None:
    registry = CapabilityRegistry()
    capability = EchoCapability()
    registry.register(capability)
    executor = PipelineExecutor(registry)
    definition = PipelineDefinition("shared", "1", (PipelineStep("one", "echo"),))
    first = executor.execute(definition, {"home": "sandres"})
    second = executor.execute(definition, {"home": "dharen"})
    assert first.status == second.status == "COMPLETED"
    assert capability.descriptor.character_ids == ()


def test_one_home_can_compose_multiple_capabilities_and_events_connect_them() -> None:
    registry = CapabilityRegistry()
    registry.register(EchoCapability("data.normalize"))
    registry.register(EchoCapability("reason.inspect"))
    bus = EventBus()
    seen: list[str] = []
    bus.subscribe("capability.completed", lambda event: seen.append(event.payload["capability_id"]))
    result = PipelineExecutor(registry, event_bus=bus).execute(
        PipelineDefinition("compose", "1", (PipelineStep("a", "data.normalize"), PipelineStep("b", "reason.inspect", ("a",)))),
        {"x": 1},
    )
    assert result.status == "COMPLETED"
    assert seen == ["data.normalize", "reason.inspect"]


def test_persistence_and_integrity_survive_reload(tmp_path) -> None:
    repository = S8ArtifactRepository(S8SQLiteStore(tmp_path / "state.sqlite3"))
    artifact = make_audit_artifact(artifact_id="A-1", payload={"x": 1}, context_id="CTX")
    repository.save_artifact(artifact)
    restored = repository.get_artifact("A-1")
    assert restored is not None
    assert ArtifactIntegrity(repository).verify("A-1")
    mutated = replace(restored, payload={"x": 2})
    repository.save_artifact(mutated)
    assert not ArtifactIntegrity(repository).verify("A-1")


def test_human_authority_records_interruption_state() -> None:
    authority = HumanAuthority()
    challenge = authority.intercept("human-1", ("A-1",), "Premise is unsupported", state=HumanChallengeState.PREMISE_CORRECTION_REQUIRED)
    assert challenge.state is HumanChallengeState.PREMISE_CORRECTION_REQUIRED
    assert authority.event_bus.history[-1].event_type == "human.challenge"


def test_permissions_budgets_and_circuit_breaker() -> None:
    boundary = PermissionBoundary("human-1", frozenset({"inspect", "execute"}), human_authorized=True)
    boundary.require("execute")
    budget = ResourceBudget(max_cost=1, max_calls=1)
    budget.reserve(cost=1)
    try:
        budget.reserve(cost=0)
    except BudgetExceeded as exc:
        assert str(exc) == "BUDGET_CAP_REACHED"
    else:
        raise AssertionError("budget should have stopped the second call")
    breaker = CircuitBreaker(failure_threshold=2)
    breaker.record_failure(); breaker.record_failure()
    try:
        breaker.require_available()
    except CircuitTripped as exc:
        assert str(exc) == "CIRCUIT_TRIPPED"
    else:
        raise AssertionError("breaker should be tripped")


def test_checkpoint_replay_and_route_loop_detection(tmp_path) -> None:
    repository = S8ArtifactRepository(S8SQLiteStore(tmp_path / "journal.sqlite3"))
    journal = ExecutionJournal(repository)
    checkpoint = journal.checkpoint("EX-1", 1, {"step": "a"}, context_id="CTX")
    assert journal.replay("EX-1", context_id="CTX")[0].checkpoint_id == checkpoint.checkpoint_id
    router = CapabilityRouter()
    router.advertise("echo", ("node-a",))
    assert router.route("echo") == "node-a"
    try:
        router.route("echo", visited=("node-a",))
    except RuntimeError as exc:
        assert str(exc) == "ROUTING_LOOP_DETECTED"
    else:
        raise AssertionError("route loop should be blocked")


def test_pipeline_dependency_cycle_is_rejected() -> None:
    definition = PipelineDefinition("cycle", "1", (PipelineStep("a", "x", ("b",)), PipelineStep("b", "x", ("a",))))
    try:
        definition.validate()
    except ValueError as exc:
        assert "cycle" in str(exc).lower()
    else:
        raise AssertionError("cyclic pipeline must be rejected")
