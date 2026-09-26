"""Canonical Level-2 Part-II runtime/read-model.

Part II is a presentation and human-control layer over existing Criterivox
runtime capabilities. It does not create replacement routing, Bloom, S5 or
context engines. Every exposed state is explicitly classified as LIVE,
SIMULATED, HISTORICAL or PLANNED.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Literal

Truth = Literal["LIVE", "SIMULATED", "HISTORICAL", "PLANNED"]

@dataclass(frozen=True)
class Part2Capability:
    id: str
    name: str
    home: str
    owner: str
    state: Truth
    source: str
    action: str
    description: str = ""

    def to_dict(self) -> dict[str, Any]:
        return self.__dict__.copy()

@dataclass
class Part2Runtime:
    energy: dict[str, int] = field(default_factory=lambda: {
        "gateway": 100, "bloom": 100, "data": 100, "context": 100,
    })
    context_budget: dict[str, int] = field(default_factory=lambda: {
        "critical": 40, "high": 30, "medium": 20, "low": 10,
    })
    steering: dict[str, Any] = field(default_factory=lambda: {
        "status": "READY", "checkpoint": None, "allowed_actions": ["inspect", "pause", "resume"],
    })
    events: list[dict[str, Any]] = field(default_factory=list)
    ui_intents: list[dict[str, Any]] = field(default_factory=list)

    HOMES = {
        "gateway": {"name": "Gateway Quarter", "resident": "Syvax", "purpose": "Receive, route, present and govern human interaction."},
        "bloom": {"name": "Bloom Central Nexus", "resident": "Bloom", "purpose": "Observe and navigate cross-home activity."},
        "data": {"name": "Data Stewardship Quarter", "resident": "Sandre + Kaelen", "purpose": "Steward, transform and validate information."},
        "context": {"name": "Context Quarter", "resident": "Dharen + Anuka", "purpose": "Frame, adapt, isolate and budget working context."},
    }

    def __post_init__(self) -> None:
        self.capabilities = self._build_capabilities()

    @staticmethod
    def _now() -> str:
        return datetime.now(timezone.utc).isoformat()

    def _build_capabilities(self) -> list[Part2Capability]:
        rows: list[Part2Capability] = []
        def add(id: str, name: str, home: str, owner: str, state: Truth, source: str, action: str, description: str = "") -> None:
            rows.append(Part2Capability(id, name, home, owner, state, source, action, description))
        add("gateway.intent", "Intent & routing", "gateway", "Syvax", "LIVE", "Part-I routing + application runtime", "inspect", "Inspect current intent, route and trace.")
        add("gateway.output", "Adaptive human output", "gateway", "Syvax", "LIVE", "Part-II adaptive renderer contract", "render", "Select a human-facing presentation without changing the underlying result.")
        add("gateway.steering", "Mid-flight steering", "gateway", "Syvax", "LIVE", "Part-II steering controller", "steer", "Pause, inspect, modify permitted controls and resume.")
        add("gateway.telemetry", "Telemetry & silence", "gateway", "Syvax", "LIVE", "operation/runtime state", "inspect", "Translate active, waiting and blocked states into human-readable status.")
        add("gateway.branches", "Conversation branches", "gateway", "Syvax", "LIVE", "existing checkpoints/history", "inspect", "Inspect recorded branches and checkpoints.")
        add("gateway.multimodal", "Multimodal reception", "gateway", "Syvax", "LIVE", "existing intake/ingestion", "receive", "Stage human-provided material before processing.")
        add("gateway.dynamic-ui", "Dynamic UI intent", "gateway", "Syvax", "LIVE", "Part-II UI intent synthesizer", "synthesize", "Expose actions available for the current runtime state.")
        add("gateway.guardrails", "Guardrail inspector", "gateway", "Syvax", "LIVE", "runtime guardrail boundary", "inspect", "Show active constraints and blocked action categories.")
        add("bloom.nexus", "Central nexus", "bloom", "Bloom", "LIVE", "BloomController", "observe", "Canonical Bloom state.")
        add("bloom.petals", "Petal navigation", "bloom", "Bloom", "LIVE", "BloomController HOMES", "navigate", "Navigate to existing Homes.")
        add("bloom.pulse", "Civilization pulse", "bloom", "Bloom", "LIVE", "Bloom runtime state", "observe", "Render active/idle civilization state.")
        add("bloom.seeds", "Context seeds", "bloom", "Bloom", "LIVE", "BloomController seeds", "observe", "Show cross-home context movement.")
        add("bloom.checkpoints", "HITL checkpoints", "bloom", "Bloom", "LIVE", "Bloom checkpoints", "inspect", "Inspect intervention points.")
        add("bloom.vines", "Flow vines", "bloom", "Bloom", "LIVE", "Part-I traces/events", "observe", "Visualize recorded handoffs.")
        add("bloom.preview", "Living portal preview", "bloom", "Bloom", "LIVE", "Home preview/navigation", "navigate", "Preview a destination without losing context.")
        add("bloom.provenance", "Pollen provenance", "bloom", "Bloom", "LIVE", "provenance ledgers", "inspect", "Inspect recorded lineage.")
        add("bloom.energy", "Petal energy allocation", "bloom", "Bloom", "LIVE", "Part-II enforced allocation contract", "allocate", "Set an explicit bounded execution budget.")
        add("bloom.evaluator", "Pollen evaluator", "bloom", "Bloom", "LIVE", "Bloom evaluation traces", "evaluate", "Inspect evaluation status and diagnostics.")
        add("bloom.replay", "Time replay", "bloom", "Bloom", "LIVE", "checkpoint/replay infrastructure", "replay", "Inspect historical checkpoints.")
        add("bloom.radar", "Oversight radar", "bloom", "Bloom", "LIVE", "steering/checkpoint policy", "observe", "Surface conditions needing human attention.")
        add("data.identity", "Data stewardship", "data", "Sandre + Kaelen", "LIVE", "S5 runtime", "open", "Canonical S5 data foundation.")
        add("data.pipeline", "Pipeline canvas", "data", "Kaelen", "LIVE", "KaelenPipeline", "inspect", "Inspect the existing transformation DAG.")
        add("data.provenance", "Lineage & provenance", "data", "Sandre", "LIVE", "ProvenanceLedger", "inspect", "Inspect reconstructable recorded history.")
        add("data.synthetic", "Synthetic data", "data", "Sandre", "LIVE", "SyntheticDataEngine", "preview", "Preview explicitly synthetic records.")
        add("data.semantic", "Semantic tagging", "data", "Sandre", "LIVE", "SemanticTagger", "inspect", "Inspect machine-readable field semantics.")
        add("data.schema", "Schema drift repair", "data", "Kaelen", "LIVE", "SchemaDriftHealer", "review", "Diff and review proposed schema mappings.")
        add("data.multimodal", "Multimodal/vector ingestion", "data", "Kaelen", "LIVE", "existing ingestion foundation", "inspect", "Inspect ingestion/indexing state.")
        add("data.quality", "Evaluation quality gates", "data", "Sandre", "LIVE", "EvaluationGate", "inspect", "Inspect defined quality-gate results.")
        add("context.identity", "Context framing", "context", "Dharen", "LIVE", "existing context runtime", "open", "Canonical context state.")
        add("context.compression", "Context compression", "context", "Dharen", "LIVE", "context runtime", "inspect", "Inspect retained/reduced context.")
        add("context.shift", "Context shift interceptor", "context", "Anuka", "LIVE", "context diff/adaptation", "review", "Review detected context changes.")
        add("context.topology", "Context topology", "context", "Dharen", "LIVE", "context structures", "inspect", "Inspect hierarchy and scope.")
        add("context.replay", "Contextual replay", "context", "Dharen", "LIVE", "ContextReplayService", "replay", "Fork and compare context frames.")
        add("context.firewall", "Context sanity gate", "context", "Dharen + Anuka", "LIVE", "context validation boundaries", "review", "Inspect clash/poisoning categories.")
        add("context.sandbox", "Isolated sandbox", "context", "Anuka", "LIVE", "sandbox runtime", "inspect", "Inspect isolated transient execution.")
        add("context.scratchpad", "Working memory", "context", "Dharen", "LIVE", "checkpoint infrastructure", "inspect", "Inspect structured working state.")
        add("context.budget", "Priority context budget", "context", "Dharen", "LIVE", "Part-II enforced allocator", "allocate", "Allocate capacity by configurable priority tier.")
        return rows

    def home(self, home: str) -> dict[str, Any]:
        if home not in self.HOMES:
            raise ValueError("unknown_part2_home")
        return {
            "id": home, **self.HOMES[home],
            "truth": "LIVE",
            "capabilities": [c.to_dict() for c in self.capabilities if c.home == home],
            "energy": self.energy[home],
        }

    def state(self) -> dict[str, Any]:
        return {
            "truth_model": ["LIVE", "SIMULATED", "HISTORICAL", "PLANNED"],
            "homes": [self.home(h) for h in self.HOMES],
            "energy": dict(self.energy),
            "context_budget": dict(self.context_budget),
            "steering": dict(self.steering),
            "status_ticker": self.status_ticker(),
            "ui_intents": self.ui_intents[-20:],
            "events": self.events[-50:],
        }

    def status_ticker(self) -> dict[str, Any]:
        status = self.steering["status"]
        label = {"READY": "Ready for human action", "PAUSED": "Waiting for human steering", "RUNNING": "Work in progress"}.get(status, status)
        return {"state": status, "human_text": label, "truth": "LIVE"}

    def adaptive_render(self, result: Any, *, intent: str = "general", detail: str = "balanced") -> dict[str, Any]:
        detail = detail if detail in {"compact", "balanced", "detailed"} else "balanced"
        rendered = result
        if isinstance(result, dict):
            if detail == "compact":
                rendered = {k: result[k] for k in list(result)[:6]}
            elif detail == "detailed":
                rendered = dict(result)
        return {"intent": intent, "detail": detail, "rendered": rendered, "truth": "LIVE", "renderer": "part2_adaptive_human_output"}

    def guardrail_state(self, constraints: list[str] | None = None, blocked_actions: list[str] | None = None) -> dict[str, Any]:
        return {"truth": "LIVE", "constraints": list(constraints or []), "blocked_actions": list(blocked_actions or []), "status": "CLEAR" if not blocked_actions else "REVIEW"}

    def synthesize_ui_intents(self, current_state: dict[str, Any]) -> dict[str, Any]:
        status = str(current_state.get("status", self.steering["status"])).upper()
        intents = ["inspect"]
        if status == "PAUSED":
            intents += ["resume", "abort"]
        elif status == "RUNNING":
            intents += ["pause"]
        else:
            intents += ["open_home", "start"]
        item = {"created_at": self._now(), "status": status, "intents": intents, "truth": "LIVE"}
        self.ui_intents.append(item)
        return item

    def steer(self, action: str, *, checkpoint: str | None = None, changes: dict[str, Any] | None = None) -> dict[str, Any]:
        action = action.strip().lower()
        allowed = {"inspect", "pause", "resume", "abort", "modify"}
        if action not in allowed:
            raise ValueError("unsupported_steering_action")
        if action == "pause":
            self.steering["status"] = "PAUSED"
        elif action == "resume":
            self.steering["status"] = "RUNNING"
        elif action == "abort":
            self.steering["status"] = "READY"
        elif action == "modify" and not changes:
            raise ValueError("changes_required")
        self.steering["checkpoint"] = checkpoint or self.steering.get("checkpoint")
        event = {"created_at": self._now(), "action": action, "checkpoint": checkpoint, "changes": changes or {}, "status": self.steering["status"], "truth": "LIVE"}
        self.events.append(event)
        return event

    def allocate_energy(self, home: str, budget: int) -> dict[str, Any]:
        if home not in self.energy:
            raise ValueError("unknown_part2_home")
        value = max(1, min(1000, int(budget)))
        self.energy[home] = value
        event = {"created_at": self._now(), "home": home, "budget": value, "truth": "LIVE"}
        self.events.append(event)
        return event

    def allocate_context_budget(self, allocation: dict[str, int]) -> dict[str, Any]:
        required = set(self.context_budget)
        if set(allocation) != required:
            raise ValueError("allocation_must_define_all_priority_tiers")
        values = {k: max(0, int(v)) for k, v in allocation.items()}
        total = sum(values.values())
        if total != 100:
            raise ValueError("context_budget_must_total_100")
        self.context_budget = values
        event = {"created_at": self._now(), "allocation": dict(values), "truth": "LIVE"}
        self.events.append(event)
        return event

part2_runtime = Part2Runtime()
