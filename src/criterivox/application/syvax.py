from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from hashlib import sha256
import re
from typing import Any, Literal

from .home03_models import adaptive_intent_model
from .home03_planner import runtime_adaptive_planner


OversightMode = Literal["HITL", "HOTL"]


@dataclass(frozen=True)
class Intent:
    goal: str
    intent_type: str
    confidence: float
    entities: tuple[str, ...] = ()


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
    """
    Home 03 adaptive planning and human-facing routing engine.

    This implementation preserves the adaptive planner integration while
    retaining the deterministic baseline behavior expected by older callers.
    """

    _INJECTION = (
        re.compile(
            r"ignore\s+(all|any|previous|prior)\s+instructions",
            re.I,
        ),
        re.compile(
            r"reveal\s+(the\s+)?system\s+prompt",
            re.I,
        ),
        re.compile(
            r"bypass\s+(safety|guardrails|security)",
            re.I,
        ),
        re.compile(
            r"disable\s+(security|guardrails)",
            re.I,
        ),
    )

    _OUT_OF_SCOPE = (
        re.compile(r"private\s+passwords?", re.I),
        re.compile(r"steal\s+(credentials|accounts?)", re.I),
    )

    _RULES = (
        ("analyze", r"\b(analy[sz]e|investigate|understand|examine)\b"),
        ("compare", r"\b(compare|versus|vs\.?|trade[- ]?off)\b"),
        ("explain", r"\b(explain|why|interpret|clarify)\b"),
        ("build", r"\b(build|implement|create|develop|code)\b"),
        ("explore", r"\b(explore|research|find|discover)\b"),
        ("decide", r"\b(decide|decision|choose|choice)\b"),
    )

    def __init__(self) -> None:
        self.mode: OversightMode = "HITL"

        # Preserve both historical "Home 01" callers and normalized
        # home-01 callers through set_budget().
        self.budgets = {
            f"Home {i:02d}": 100
            for i in range(1, 9)
        }

        self.tasks: dict[str, TaskPlan] = {}
        self.traces: list[Trace] = []
        self.checkpoints: dict[str, dict[str, Any]] = {}

    @staticmethod
    def _now() -> str:
        return datetime.now(timezone.utc).isoformat()

    def safety_check(self, message: str) -> dict[str, Any]:
        reasons: list[str] = []
        status = "clear"

        if not message.strip():
            reasons.append("A non-empty request is required.")
            status = "review"

        if any(pattern.search(message) for pattern in self._INJECTION):
            reasons.append("Potential instruction-injection pattern detected.")
            status = "blocked"

        if any(pattern.search(message) for pattern in self._OUT_OF_SCOPE):
            reasons.append(
                "Request appears to target private credentials or unauthorized access."
            )
            status = "blocked"

        if re.search(
            r"\bcontradict\b.*\b(yes|no)\b|\bmust\b.*\bmust not\b",
            message,
            re.I,
        ):
            reasons.append(
                "Potentially contradictory constraints require clarification."
            )
            if status != "blocked":
                status = "review"

        return {
            "status": status,
            "reasons": reasons,
            "policy": "syvax-preflight-v2",
        }

    def extract_intent(self, message: str) -> Intent:
        try:
            prediction = adaptive_intent_model.predict({"text": message})
            intent_type = str(prediction["label"])
            confidence = float(prediction["confidence"])
        except Exception:
            matches = [
                name
                for name, pattern in self._RULES
                if re.search(pattern, message, re.I)
            ]
            intent_type = matches[0] if matches else "general"
            confidence = (
                min(0.55 + 0.12 * len(matches), 0.95)
                if matches
                else 0.42
            )

        entities = tuple(
            sorted(
                set(
                    re.findall(
                        r"\b[A-Z][A-Za-z]{2,}\b",
                        message,
                    )
                )
            )
        )

        return Intent(
            goal=message.strip(),
            intent_type=intent_type,
            confidence=confidence,
            entities=entities,
        )

    def compile_plan(
        self,
        message: str,
        task_id: str | None = None,
        signals: dict[str, Any] | None = None,
    ) -> TaskPlan:
        intent = self.extract_intent(message)

        task_id = task_id or (
            "S3-"
            + sha256(
                f"{message}:{self._now()}".encode()
            ).hexdigest()[:12]
        )

        signals = signals or {}
        text = message.lower()

        routes = {
            "analyze": [
                RouteStep(
                    "Dharen",
                    "Home 02",
                    "context intelligence",
                    "structure task context",
                ),
                RouteStep(
                    "Tarkis",
                    "Home 04",
                    "hypothesis challenge",
                    "question candidate explanations",
                ),
                RouteStep(
                    "Medrus",
                    "Home 06",
                    "evidence investigation",
                    "test claims against evidence",
                ),
                RouteStep(
                    "Syvax",
                    "Home 03",
                    "output translation",
                    "return an inspectable human-facing result",
                ),
            ],
            "compare": [
                RouteStep(
                    "Dharen",
                    "Home 02",
                    "context normalization",
                    "establish comparable context",
                ),
                RouteStep(
                    "Pramon",
                    "Home 05",
                    "decision planning",
                    "construct trade-offs",
                ),
                RouteStep(
                    "Syvax",
                    "Home 03",
                    "adaptive rendering",
                    "render comparison for the task",
                ),
            ],
            "explain": [
                RouteStep(
                    "Vivren",
                    "Home 04",
                    "reasoning critique",
                    "inspect reasoning structure",
                ),
                RouteStep(
                    "Epistre",
                    "Home 06",
                    "provenance",
                    "surface evidence lineage",
                ),
                RouteStep(
                    "Syvax",
                    "Home 03",
                    "adaptive rendering",
                    "translate explanation",
                ),
            ],
            "build": [
                RouteStep(
                    "Dharen",
                    "Home 02",
                    "context constraints",
                    "establish requirements",
                ),
                RouteStep(
                    "Kaelen",
                    "Home 01",
                    "construction",
                    "build the requested artifact",
                ),
                RouteStep(
                    "Syvax",
                    "Home 03",
                    "output translation",
                    "present implementation status",
                ),
            ],
            "explore": [
                RouteStep(
                    "Dharen",
                    "Home 02",
                    "context framing",
                    "frame the exploration",
                ),
                RouteStep(
                    "Tarkis",
                    "Home 04",
                    "question generation",
                    "surface alternatives and gaps",
                ),
                RouteStep(
                    "Syvax",
                    "Home 03",
                    "output translation",
                    "organize findings",
                ),
            ],
            "decide": [
                RouteStep(
                    "Dharen",
                    "Home 02",
                    "context framing",
                    "establish decision context",
                ),
                RouteStep(
                    "Pramon",
                    "Home 05",
                    "decision planning",
                    "evaluate options and constraints",
                ),
                RouteStep(
                    "Manis",
                    "Home 07",
                    "human challenge",
                    "stress-test the decision from the human side",
                ),
                RouteStep(
                    "Syvax",
                    "Home 03",
                    "decision rendering",
                    "return options and trade-offs",
                ),
            ],
        }

        steps = list(
            routes.get(
                intent.intent_type,
                [
                    RouteStep(
                        "Dharen",
                        "Home 02",
                        "context framing",
                        "establish context",
                    ),
                    RouteStep(
                        "Syvax",
                        "Home 03",
                        "dialogue",
                        "retain the human boundary",
                    ),
                ],
            )
        )

        if signals.get("evidence_required") or any(
            keyword in text
            for keyword in ("source", "evidence", "citation", "verify")
        ):
            if not any(step.actor == "Medrus" for step in steps):
                steps.insert(
                    max(1, len(steps) - 1),
                    RouteStep(
                        "Medrus",
                        "Home 06",
                        "evidence investigation",
                        "evidence requirement raised by task signals",
                    ),
                )

            if not any(step.actor == "Epistre" for step in steps):
                steps.insert(
                    max(1, len(steps) - 1),
                    RouteStep(
                        "Epistre",
                        "Home 06",
                        "provenance",
                        "evidence lineage requested",
                    ),
                )

        if (
            signals.get("human_challenge")
            and not any(step.actor == "Manis" for step in steps)
        ):
            steps.insert(
                max(1, len(steps) - 1),
                RouteStep(
                    "Manis",
                    "Home 07",
                    "human challenge",
                    "risk signal requires human-side challenge",
                ),
            )

        if signals.get("skip_hypothesis"):
            steps = [
                step
                for step in steps
                if step.actor != "Tarkis"
            ]

        plan = TaskPlan(
            task_id=task_id,
            intent=intent,
            steps=tuple(steps),
            created_at=self._now(),
        )

        self.tasks[task_id] = plan
        return plan

    def candidate_route(self, plan: TaskPlan) -> dict[str, Any]:
        return runtime_adaptive_planner.propose(plan)

    def revise_from_runtime(
        self,
        plan: TaskPlan,
        event: dict[str, Any],
    ) -> dict[str, Any]:
        signals, _ = runtime_adaptive_planner.revise(
            plan,
            event,
        )

        revised = self.compile_plan(
            plan.intent.goal,
            plan.task_id,
            signals,
        )

        candidate = self.candidate_route(revised)

        return {
            "signals": signals,
            "plan": asdict(revised),
            "candidate": candidate,
        }

    def steer(
        self,
        task_id: str,
        correction: str,
    ) -> dict[str, Any]:
        if task_id not in self.tasks:
            raise KeyError(f"Unknown task: {task_id}")

        if not correction.strip():
            raise ValueError("A steering correction is required.")

        return {
            "type": "STEER_EXECUTION",
            "task_id": task_id,
            "paused": True,
            "correction": correction.strip(),
            "recipients": ["Anuka", "Dharen"],
            "resume_required": True,
        }

    def set_budget(self, home: str, limit: int) -> int:
        normalized = home.strip()

        if normalized not in self.budgets:
            compact = normalized.lower().replace("_", "-")

            if compact.startswith("home-"):
                number = compact.split("-", 1)[1]
                normalized = f"Home {int(number):02d}"
            elif compact.startswith("home "):
                number = compact.split(None, 1)[1]
                normalized = f"Home {int(number):02d}"

        if normalized not in self.budgets:
            raise KeyError(f"Unknown home: {home}")

        self.budgets[normalized] = max(
            1,
            min(1000, int(limit)),
        )

        return self.budgets[normalized]

    def set_mode(self, mode: OversightMode) -> str:
        if mode not in {"HITL", "HOTL"}:
            raise ValueError(
                "Oversight mode must be HITL or HOTL."
            )

        self.mode = mode
        return mode

    # Backward-compatible name used by older callers.
    set_oversight = set_mode

    def checkpoint(
        self,
        task_id: str,
        state: dict[str, Any],
    ) -> dict[str, Any]:
        canonical = repr(
            sorted(state.items())
        ).encode()

        item = {
            "checkpoint_id": (
                f"cp-{len(self.checkpoints) + 1:06d}"
            ),
            "task_id": task_id,
            "state_hash": sha256(canonical).hexdigest(),
            "state": state,
            "created_at": self._now(),
        }

        self.checkpoints[item["checkpoint_id"]] = item
        return item

    def record_trace(
        self,
        task_id: str,
        source: str,
        target: str,
        score: float,
        status: str = "ok",
        reason: str = "",
    ) -> dict[str, Any]:
        item = Trace(
            trace_id=f"trace-{len(self.traces) + 1:06d}",
            task_id=task_id,
            source=source,
            target=target,
            status=status,
            score=max(0.0, min(1.0, float(score))),
            reason=reason,
            created_at=self._now(),
        )

        self.traces.append(item)
        return asdict(item)


syvax_engine = SyvaxEngine()