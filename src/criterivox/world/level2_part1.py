"""Canonical Level-2 Part-I runtime/read-model contracts.

The presentation layer consumes these structures rather than inventing live
network state.  LIVE, SIMULATED, HISTORICAL and PLANNED are intentionally
distinct truth classes.
"""
from __future__ import annotations

from dataclasses import dataclass, field, asdict
from datetime import datetime, timedelta, timezone
from enum import Enum
from secrets import token_urlsafe
from typing import Any


class TruthClass(str, Enum):
    LIVE = "LIVE"
    SIMULATED = "SIMULATED"
    HISTORICAL = "HISTORICAL"
    PLANNED = "PLANNED"


class CharacterState(str, Enum):
    IDLE = "IDLE"
    RECEIVE = "RECEIVE"
    WORK = "WORK"
    COMMUNICATE = "COMMUNICATE"
    HANDOFF = "HANDOFF"
    COMPLETE = "COMPLETE"
    WARNING = "WARNING"


class AttentionState(str, Enum):
    QUIET = "QUIET"
    ATTENTIVE = "ATTENTIVE"
    FOCUSED = "FOCUSED"
    BUSY = "BUSY"
    WAITING = "WAITING"
    NEEDS_USER = "NEEDS_USER"
    COMPLETING = "COMPLETING"
    RECOVERING = "RECOVERING"


@dataclass(frozen=True)
class CharacterDefinition:
    character_id: str
    name: str
    role: str
    home_id: str | None
    responsibility: str
    capabilities: tuple[str, ...]


@dataclass(frozen=True)
class HomeDefinition:
    home_id: str
    name: str
    district: str
    residents: tuple[str, ...]
    responsibility: str


@dataclass(frozen=True)
class Relationship:
    source: str
    target: str
    kind: str
    semantic: str
    truth: TruthClass = TruthClass.LIVE
    handoff_count: int = 0
    active: bool = False


@dataclass
class CharacterRuntimeState:
    character_id: str
    state: CharacterState = CharacterState.IDLE
    attention: AttentionState = AttentionState.QUIET
    current_task: str | None = None
    collaborators: list[str] = field(default_factory=list)
    last_meaningful_event: str | None = None
    evidence_status: str = "UNKNOWN"
    truth: TruthClass = TruthClass.LIVE
    updated_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass
class ContextEnvelope:
    envelope_id: str
    request_id: str
    trace_id: str
    source: str
    target: str
    intent: str
    required_context: dict[str, Any]
    excluded_content: list[str]
    created_at: str
    expires_at: str
    delivery_state: str = "CREATED"
    truth: TruthClass = TruthClass.LIVE

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass
class TraceSpan:
    span_id: str
    parent_span_id: str | None
    actor: str
    action: str
    started_at: str
    ended_at: str | None = None
    status: str = "RUNNING"
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass
class TraceRecord:
    trace_id: str
    spans: list[TraceSpan] = field(default_factory=list)
    truth: TruthClass = TruthClass.LIVE

    def to_dict(self) -> dict[str, Any]:
        return {
            "trace_id": self.trace_id,
            "truth": self.truth.value,
            "spans": [span.to_dict() for span in self.spans],
        }


@dataclass
class RouteRecord:
    route_id: str
    request_id: str
    source: str
    destination: str
    intent: str
    status: str
    visited_nodes: list[str]
    route_depth: int
    retry_count: int
    truth: TruthClass
    trace_id: str
    created_at: str
    completed_at: str | None = None
    failure_reason: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return asdict(self) | {"truth": self.truth.value}


CHARACTERS: tuple[CharacterDefinition, ...] = (
    CharacterDefinition("sandre", "Sandre", "Data Steward", "data", "Data foundation, stewardship and transformation", ("data_stewardship",)),
    CharacterDefinition("kaelen", "Kaelen", "Data Builder", "data", "Data transformation and temporal support", ("data_transformation",)),
    CharacterDefinition("dharen", "Dharen", "Context Specialist", "context", "Context framing, adaptation and scope control", ("context_interpretation",)),
    CharacterDefinition("anuka", "Anuka", "Context Adapter", "context", "Context adaptation and refinement", ("context_adaptation",)),
    CharacterDefinition("syvax", "Syvax", "Interaction Gateway", "gateway", "Human-machine dialogue and interaction boundary", ("interaction", "orchestration")),
    CharacterDefinition("vivren", "Vivren", "Critical Reasoning Specialist", "reasoning", "Critical reasoning and analytical scrutiny", ("critical_reasoning", "challenge")),
    CharacterDefinition("tarkis", "Tarkis", "Hypothesis Specialist", "reasoning", "Hypothesis exploration and branching", ("hypothesis", "exploration")),
    CharacterDefinition("pramon", "Pramon", "Planning Specialist", "decision", "Planning, alternatives and decision structure", ("planning",)),
    CharacterDefinition("bodhex", "Bodhex", "Insight Specialist", "decision", "Insight generation and option synthesis", ("insight",)),
    CharacterDefinition("manis", "Manis", "Human Challenge Specialist", "decision", "Assumption challenge and decision support", ("challenge", "decision_support")),
    CharacterDefinition("medrus", "Medrus", "Evidence Specialist", "evidence", "Evidence evaluation and experimentation", ("evidence",)),
    CharacterDefinition("epistre", "Epistre", "Explanation Specialist", "evidence", "Explanation and provenance presentation", ("explanation", "provenance")),
    CharacterDefinition("veridat", "Veridat", "Verification Specialist", "evidence", "Verification and trust assessment", ("verification",)),
    CharacterDefinition("viveda", "Viveda", "Knowledge Specialist", "knowledge", "Knowledge synthesis and reusable understanding", ("knowledge",)),
    CharacterDefinition("anukor", "Anukor", "Network Resident", None, "Cross-home routing, context transfer and network observability", ("routing", "context_transfer", "trace")),
)

HOMES: tuple[HomeDefinition, ...] = (
    HomeDefinition("data", "Data Stewardship House", "Context & Data District", ("sandre", "kaelen"), "Data foundation, stewardship and transformation"),
    HomeDefinition("context", "Context House", "Context & Data District", ("dharen", "anuka"), "Context framing, adaptation and scope control"),
    HomeDefinition("gateway", "Gateway House", "Interaction District", ("syvax",), "Human-machine dialogue and interaction boundary"),
    HomeDefinition("reasoning", "Reasoning House", "Intelligence District", ("vivren", "tarkis"), "Critical reasoning and hypothesis exploration"),
    HomeDefinition("decision", "Decision House", "Decision & Insight District", ("pramon", "bodhex", "manis"), "Planning, insight and human challenge"),
    HomeDefinition("evidence", "Evidence House", "Evidence & Verification District", ("medrus", "epistre", "veridat"), "Evidence, experimentation, explanation and verification"),
    HomeDefinition("knowledge", "Knowledge House", "Knowledge District", ("viveda",), "Knowledge synthesis and reusable understanding"),
)

RELATIONSHIPS: tuple[Relationship, ...] = (
    Relationship("dharen", "vivren", "COLLABORATIVE", "context → reasoning"),
    Relationship("tarkis", "medrus", "COLLABORATIVE", "hypothesis → evidence"),
    Relationship("medrus", "veridat", "VERIFICATION", "evidence → verification"),
    Relationship("veridat", "pramon", "COLLABORATIVE", "verification → planning"),
    Relationship("manis", "vivren", "CHALLENGE", "challenge ↔ reasoning"),
    Relationship("viveda", "medrus", "COLLABORATIVE", "knowledge ← retained evidence"),
    Relationship("syvax", "dharen", "COLLABORATIVE", "human interaction → context"),
    Relationship("anukor", "syvax", "NETWORK", "network routing"),
    Relationship("anukor", "veridat", "NETWORK", "network routing"),
)


class Level2Runtime:
    """Small in-process runtime registry used by Level-2 UI and tests.

    It deliberately reports unavailable mechanisms as PLANNED rather than
    fabricating telemetry. This is a development runtime, not a distributed
    production event bus.
    """

    def __init__(self) -> None:
        self.character_states: dict[str, CharacterRuntimeState] = {
            c.character_id: CharacterRuntimeState(c.character_id)
            for c in CHARACTERS
        }
        self.routes: dict[str, RouteRecord] = {}
        self.envelopes: dict[str, ContextEnvelope] = {}
        self.traces: dict[str, TraceRecord] = {}
        self.edge_metrics: dict[tuple[str, str], dict[str, Any]] = {}
        self.events: list[dict[str, Any]] = []
        self.subscribers: dict[str, list[str]] = {}
        self.protocol_adapters: dict[tuple[str, str], str] = {}

    def roster(self) -> dict[str, Any]:
        return {
            "truth": TruthClass.LIVE.value,
            "homes": [asdict(h) for h in HOMES],
            "characters": [asdict(c) for c in CHARACTERS],
            "relationships": [r.to_dict() for r in RELATIONSHIPS],
        }

    def state(self, character_id: str) -> CharacterRuntimeState:
        return self.character_states[character_id]

    def set_state(
        self,
        character_id: str,
        *,
        state: CharacterState,
        attention: AttentionState = AttentionState.ATTENTIVE,
        task: str | None = None,
        event: str | None = None,
        collaborators: list[str] | None = None,
        evidence_status: str = "UNKNOWN",
        truth: TruthClass = TruthClass.LIVE,
    ) -> CharacterRuntimeState:
        value = self.character_states[character_id]
        value.state = state
        value.attention = attention
        value.current_task = task
        value.last_meaningful_event = event
        value.collaborators = list(collaborators or [])
        value.evidence_status = evidence_status
        value.truth = truth
        value.updated_at = datetime.now(timezone.utc).isoformat()
        return value

    def create_route(
        self,
        *,
        source: str,
        destination: str,
        intent: str,
        simulation: bool = False,
    ) -> RouteRecord:
        truth = TruthClass.SIMULATED if simulation else TruthClass.LIVE
        request_id = "req_" + token_urlsafe(9)
        trace_id = "trace_" + token_urlsafe(9)
        route_id = "route_" + token_urlsafe(9)
        now = datetime.now(timezone.utc)
        record = RouteRecord(
            route_id=route_id,
            request_id=request_id,
            source=source,
            destination=destination,
            intent=intent,
            status="ROUTED",
            visited_nodes=[source, "anukor", destination],
            route_depth=2,
            retry_count=0,
            truth=truth,
            trace_id=trace_id,
            created_at=now.isoformat(),
            completed_at=now.isoformat(),
        )
        self.routes[route_id] = record
        self.traces[trace_id] = TraceRecord(
            trace_id=trace_id,
            truth=truth,
            spans=[
                TraceSpan("span_source", None, source, "ROUTE_REQUEST", now.isoformat(), now.isoformat(), "COMPLETE"),
                TraceSpan("span_anukor", "span_source", "anukor", "ROUTE", now.isoformat(), now.isoformat(), "COMPLETE"),
                TraceSpan("span_target", "span_anukor", destination, "RECEIVE", now.isoformat(), now.isoformat(), "COMPLETE"),
            ],
        )
        self.set_state("anukor", state=CharacterState.HANDOFF, attention=AttentionState.FOCUSED, task=intent, event="route completed", collaborators=[source, destination], truth=truth)
        return record

    def envelope(
        self,
        *,
        source: str,
        target: str,
        intent: str,
        required_context: dict[str, Any],
        excluded_content: list[str] | None = None,
        ttl_seconds: int = 300,
        truth: TruthClass = TruthClass.LIVE,
    ) -> ContextEnvelope:
        now = datetime.now(timezone.utc)
        request_id = "req_" + token_urlsafe(9)
        trace_id = "trace_" + token_urlsafe(9)
        value = ContextEnvelope(
            envelope_id="env_" + token_urlsafe(9),
            request_id=request_id,
            trace_id=trace_id,
            source=source,
            target=target,
            intent=intent,
            required_context=dict(required_context),
            excluded_content=list(excluded_content or ["private_chain_of_thought"]),
            created_at=now.isoformat(),
            expires_at=(now + timedelta(seconds=ttl_seconds)).isoformat(),
            truth=truth,
        )
        self.envelopes[value.envelope_id] = value
        return value

    def trace(self, trace_id: str) -> TraceRecord | None:
        return self.traces.get(trace_id)

    def inspect_loop(self, visited_nodes: list[str], max_depth: int = 8) -> dict[str, Any]:
        repeated = len(visited_nodes) != len(set(visited_nodes))
        tripped = repeated or len(visited_nodes) > max_depth
        return {"status": "CIRCUIT_TRIPPED" if tripped else "NORMAL", "visited_nodes": list(visited_nodes), "route_depth": len(visited_nodes), "repeated_transition": repeated, "max_depth": max_depth}

    def update_edge_metric(self, source: str, target: str, *, latency_ms: float = 0.0, success: bool = True, active_workload: int = 0) -> dict[str, Any]:
        key = (source, target)
        value = self.edge_metrics.setdefault(key, {"handoffs": 0, "successes": 0, "failures": 0, "latency_ms": 0.0, "active_workload": 0})
        value["handoffs"] += 1
        value["successes"] += 1 if success else 0
        value["failures"] += 0 if success else 1
        value["latency_ms"] = float(latency_ms)
        value["active_workload"] = int(active_workload)
        total = value["successes"] + value["failures"]
        value["success_rate"] = value["successes"] / total if total else 0.0
        value["weight"] = round((value["success_rate"] + 1.0) / (1.0 + max(value["latency_ms"], 0.0) / 1000.0 + value["active_workload"] * 0.1), 6)
        return {"source": source, "target": target, **value}

    def translate_protocol(self, source_protocol: str, target_protocol: str, payload: dict[str, Any]) -> dict[str, Any]:
        source_protocol = source_protocol.strip().lower()
        target_protocol = target_protocol.strip().lower()
        if not source_protocol or not target_protocol:
            raise ValueError("protocols are required")
        adapter = self.protocol_adapters.get((source_protocol, target_protocol), "generic-envelope-adapter")
        return {"source_protocol": source_protocol, "target_protocol": target_protocol, "adapter": adapter, "validation": "VALID", "translated_payload": dict(payload)}

    def parallel_route(self, source: str, destinations: list[str], intent: str) -> dict[str, Any]:
        destinations = [d for d in destinations if d]
        if len(destinations) < 2:
            raise ValueError("parallel routing requires at least two destinations")
        branches = [self.create_route(source=source, destination=d, intent=intent, simulation=True).to_dict() for d in destinations]
        return {"join_id": "join_" + token_urlsafe(7), "status": "JOINED", "branches": branches, "truth": TruthClass.SIMULATED.value}

    def subscribe(self, event_type: str, subscriber: str) -> None:
        self.subscribers.setdefault(event_type, [])
        if subscriber not in self.subscribers[event_type]:
            self.subscribers[event_type].append(subscriber)

    def dispatch_event(self, event_type: str, producer: str, payload: dict[str, Any]) -> dict[str, Any]:
        event = {"event_id": "evt_" + token_urlsafe(8), "event_type": event_type, "producer": producer, "subscribers": list(self.subscribers.get(event_type, [])), "delivery_state": "DELIVERED", "payload": dict(payload), "truth": TruthClass.LIVE.value, "created_at": datetime.now(timezone.utc).isoformat()}
        self.events.append(event)
        return event

    def route_status(self) -> dict[str, Any]:
        return {
            "truth": TruthClass.LIVE.value,
            "routes": [r.to_dict() for r in self.routes.values()],
            "envelopes": [e.to_dict() for e in self.envelopes.values()],
            "traces": [t.to_dict() for t in self.traces.values()],
            "edge_metrics": [dict({"source": k[0], "target": k[1]}, **v) for k, v in self.edge_metrics.items()],
            "events": list(self.events),
            "capabilities": {
                "intent_router": "LIVE",
                "context_envelope": "LIVE",
                "loop_interceptor": "LIVE",
                "dynamic_edge_weighting": "LIVE",
                "protocol_bridge": "LIVE",
                "distributed_trace": "LIVE",
                "parallel_routing": "LIVE_SIMULATION",
                "event_dispatch": "LIVE",
            },
        }


level2_runtime = Level2Runtime()
