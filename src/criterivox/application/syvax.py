from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from hashlib import sha256
import re
from typing import Any, Literal

OversightMode = Literal["HITL", "HOTL"]

@dataclass(frozen=True)
class Intent:
    goal: str
    intent_type: str
    confidence: float
    entities: tuple[str, ...]

@dataclass(frozen=True)
class RouteStep:
    actor: str
    home: str
    capability: str
    reason: str

@dataclass(frozen=True)
class TaskPlan:
    task_id: str
    intent: Intent
    steps: tuple[RouteStep, ...]
    created_at: str

@dataclass(frozen=True)
class Trace:
    trace_id: str
    task_id: str
    source: str
    target: str
    status: str
    score: float
    reason: str
    created_at: str

class SyvaxEngine:
    """Home 03 intelligence boundary.

    Deterministic baselines are intentionally replaceable by trained intent,
    routing, rendering and anomaly models later. The character is the actor;
    this engine is the computational capability behind that actor.
    """
    _RULES = (
        ("analyze", re.compile(r"\b(analy[sz]e|investigate|examine|understand)\b", re.I)),
        ("compare", re.compile(r"\b(compare|versus|vs\.?|trade[- ]?off)\b", re.I)),
        ("explain", re.compile(r"\b(explain|why|interpret|clarify)\b", re.I)),
        ("build", re.compile(r"\b(build|implement|create|develop|code)\b", re.I)),
        ("explore", re.compile(r"\b(explore|research|find|discover)\b", re.I)),
        ("decide", re.compile(r"\b(decide|choose|recommend|decision)\b", re.I)),
    )
    _INJECTION = (
        re.compile(r"ignore\s+(all|any|previous|prior)\s+instructions", re.I),
        re.compile(r"reveal\s+(the\s+)?system\s+prompt", re.I),
        re.compile(r"bypass\s+(safety|guardrails|security)", re.I),
    )

    def __init__(self) -> None:
        self.mode: OversightMode = "HITL"
        self.budgets = {f"Home {i:02d}": 100 for i in range(1, 9)}
        self.traces: list[Trace] = []
        self.checkpoints: dict[str, dict[str, Any]] = {}

    @staticmethod
    def _now() -> str:
        return datetime.now(timezone.utc).isoformat()

    def safety_check(self, message: str) -> dict[str, Any]:
        reasons = ["Potential instruction-injection pattern detected." for p in self._INJECTION if p.search(message)]
        if not message.strip():
            reasons.append("A non-empty request is required.")
        status = "blocked" if any("injection" in r.lower() for r in reasons) else ("review" if reasons else "clear")
        return {"status": status, "reasons": reasons}

    def extract_intent(self, message: str) -> Intent:
        matches = [name for name, pattern in self._RULES if pattern.search(message)]
        intent_type = matches[0] if matches else "general"
        confidence = min(.55 + .1 * len(matches), .95) if matches else .42
        entities = tuple(sorted(set(re.findall(r"\b[A-Z][A-Za-z]{2,}\b", message))))
        return Intent(message.strip(), intent_type, confidence, entities)

    def compile_plan(self, message: str, task_id: str | None = None) -> TaskPlan:
        intent = self.extract_intent(message)
        task_id = task_id or "S3-" + sha256(f"{message}:{self._now()}".encode()).hexdigest()[:12]
        routes = {
            "analyze": [
                RouteStep("Dharen", "Home 02", "context intelligence", "structure task context"),
                RouteStep("Tarkis", "Home 04", "hypothesis challenge", "question candidate explanations"),
                RouteStep("Medrus", "Home 06", "evidence investigation", "test claims against evidence"),
                RouteStep("Syvax", "Home 03", "output translation", "return an inspectable human-facing result"),
            ],
            "compare": [
                RouteStep("Dharen", "Home 02", "context normalization", "establish comparable context"),
                RouteStep("Pramon", "Home 05", "decision planning", "construct trade-offs"),
                RouteStep("Syvax", "Home 03", "adaptive rendering", "render comparison for the task"),
            ],
            "explain": [
                RouteStep("Vivren", "Home 04", "reasoning critique", "inspect reasoning structure"),
                RouteStep("Epistre", "Home 06", "provenance", "surface evidence lineage"),
                RouteStep("Syvax", "Home 03", "adaptive rendering", "translate explanation"),
            ],
            "build": [
                RouteStep("Dharen", "Home 02", "context constraints", "establish requirements"),
                RouteStep("Kaelen", "Home 01", "construction", "build the requested artifact"),
                RouteStep("Syvax", "Home 03", "output translation", "present implementation status"),
            ],
            "explore": [
                RouteStep("Dharen", "Home 02", "context framing", "frame the exploration"),
                RouteStep("Tarkis", "Home 04", "question generation", "surface alternatives and gaps"),
                RouteStep("Syvax", "Home 03", "output translation", "organize findings"),
            ],
            "decide": [
                RouteStep("Dharen", "Home 02", "context framing", "establish decision context"),
                RouteStep("Pramon", "Home 05", "decision planning", "evaluate options and constraints"),
                RouteStep("Manis", "Home 07", "human challenge", "stress-test the decision from the human side"),
                RouteStep("Syvax", "Home 03", "decision rendering", "return options and trade-offs"),
            ],
        }
        return TaskPlan(task_id, intent, tuple(routes.get(intent.intent_type, [RouteStep("Dharen", "Home 02", "context framing", "establish context"), RouteStep("Syvax", "Home 03", "dialogue", "retain the human boundary")])), self._now())

    def steer(self, task_id: str, correction: str) -> dict[str, Any]:
        if not correction.strip():
            raise ValueError("A steering correction is required.")
        return {"type": "STEER_EXECUTION", "task_id": task_id, "paused": True, "correction": correction.strip(), "recipients": ["Anuka", "Dharen"], "resume_required": True}

    def set_budget(self, home: str, limit: int) -> int:
        if home not in self.budgets:
            raise KeyError(f"Unknown home: {home}")
        self.budgets[home] = max(1, min(1000, int(limit)))
        return self.budgets[home]

    def set_mode(self, mode: OversightMode) -> str:
        if mode not in {"HITL", "HOTL"}:
            raise ValueError("Oversight mode must be HITL or HOTL.")
        self.mode = mode
        return mode

    def checkpoint(self, task_id: str, state: dict[str, Any]) -> dict[str, Any]:
        canonical = repr(sorted(state.items())).encode()
        item = {"checkpoint_id": f"cp-{len(self.checkpoints)+1:06d}", "task_id": task_id, "state_hash": sha256(canonical).hexdigest(), "state": state, "created_at": self._now()}
        self.checkpoints[item["checkpoint_id"]] = item
        return item

    def record_trace(self, task_id: str, source: str, target: str, score: float, status: str = "ok", reason: str = "") -> dict[str, Any]:
        item = Trace(f"trace-{len(self.traces)+1:06d}", task_id, source, target, status, max(0, min(1, float(score))), reason, self._now())
        self.traces.append(item)
        return asdict(item)

syvax_engine = SyvaxEngine()
