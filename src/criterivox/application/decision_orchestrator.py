from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from .data_foundation_store import data_foundations
from .external_research import google_research
from .human_residence_local_store import human_residence_local
from .syvax import syvax_engine


@dataclass(frozen=True)
class DecisionResult:
    decision_id: str
    strategy: dict[str, Any]
    trace: list[dict[str, Any]]
    research: dict[str, Any] | None
    foundation_id: str | None


class DecisionOrchestrator:
    """Authoritative Human Residence decision pipeline.

    Character names are responsibility surfaces in the trace, not competing
    decision engines. The orchestrator owns the sequence and decision record.
    """

    def execute(
        self,
        *,
        session_token: str,
        residence_id: str,
        goal: str,
        supplied_data: str,
        context: str,
        allow_external_research: bool,
    ) -> DecisionResult:
        owner_id = human_residence_local.owner_for_session(session_token)
        if owner_id is None:
            raise PermissionError("invalid_session")
        identity = human_residence_local._identity(owner_id)
        email = str(identity.get("email", ""))
        goal = goal.strip()
        if not goal:
            raise ValueError("goal is required")

        trace: list[dict[str, Any]] = []

        def event(actor: str, responsibility: str, detail: str, **extra: Any) -> None:
            trace.append({"actor": actor, "responsibility": responsibility, "detail": detail, **extra})

        event("human", "authority", "Submitted goal, supplied material and context.", email=email)
        event("sandre", "data stewardship", "Registered supplied material and provenance.")
        event("kaelen", "structure", "Structured the decision inputs and constraints.")
        event("dharen", "context", "Interpreted goal and context without inventing missing constraints.")

        plan = syvax_engine.compile_plan(goal)
        foundation_id: str | None = None
        if supplied_data.strip():
            foundation = data_foundations.ingest({
                "sources": [{
                    "name": "Human Residence supplied text",
                    "source_type": "text",
                    "channel": "human-residence",
                    "content": supplied_data,
                    "processing_status": "received",
                }],
                "collection_id": residence_id,
                "supplied_context": {"goal": goal, "context": context, "entered_through": "Human Residence"},
            })
            foundation_id = foundation.foundation_id

        research_run = None
        if allow_external_research:
            query = self._research_query(goal, context)
            research_run = google_research.search(query, requested_by_email=email)
            event(
                "google-research",
                "external evidence",
                f"Searched Google for: {query}",
                run_id=research_run.run_id,
                result_count=len(research_run.results),
            )
            if research_run.results:
                research_sources = [
                    {
                        "name": result.title or result.url,
                        "source_type": "url",
                        "channel": "google-research",
                        "location": result.url,
                        "content": result.snippet,
                        "processing_status": "received",
                        "parent_source_id": residence_id,
                    }
                    for result in research_run.results
                ]
                research_foundation = data_foundations.ingest({
                    "sources": research_sources[:50],
                    "collection_id": foundation_id or residence_id,
                    "supplied_context": {
                        "entered_through": "Google Research",
                        "research_run_id": research_run.run_id,
                    },
                })
                foundation_id = research_foundation.foundation_id
            event("dharen", "evidence context", "Integrated external evidence into the decision context.")
        else:
            event("human", "research authorization", "External research was not authorized; supplied material only.")

        event("tarkis", "reasoning", "Evaluated the structured goal, constraints and available evidence.")
        option_rows = self._options(goal, plan, research_run)
        event("pramon", "decision options", "Produced strategy candidates with explicit trade-offs.", option_count=len(option_rows))
        event("manis", "challenge", "Generated challenge points for the human to stress-test.")

        strategy = {
            "goal": goal,
            "plan": {
                "task_id": plan.task_id,
                "intent_type": plan.intent.intent_type,
                "confidence": plan.intent.confidence,
                "entities": list(plan.intent.entities),
            },
            "options": option_rows,
            "tradeoffs": {"speed": 50, "cost": 50, "reliability": 50},
            "challenges": [
                "What assumption would break this option first?",
                "What evidence would make you reject this path?",
                "What changes would require replanning before execution?",
            ],
            "research_authorized": allow_external_research,
            "research": research_run.to_dict() if research_run else None,
            "foundation_id": foundation_id,
        }
        decision = human_residence_local.save_decision(
            owner_id=owner_id,
            residence_id=residence_id,
            title=goal,
            goal=goal,
            strategy=strategy,
            trace=trace,
        )
        event("human", "decision authority", "Strategy returned for human review; execution remains behind the action gate.", decision_id=decision["decision_id"])
        return DecisionResult(
            decision_id=decision["decision_id"],
            strategy=strategy,
            trace=trace,
            research=research_run.to_dict() if research_run else None,
            foundation_id=foundation_id,
        )

    @staticmethod
    def _research_query(goal: str, context: str) -> str:
        context = " ".join(context.split())
        return f"{goal} {context}".strip()[:500]

    @staticmethod
    def _options(goal: str, plan: Any, research_run: Any) -> list[dict[str, Any]]:
        evidence = [] if research_run is None else [r.to_dict() for r in research_run.results]
        return [
            {
                "id": "strategy-rapid",
                "label": "Rapid path",
                "objective": goal,
                "approach": f"Act on the strongest supported path for: {goal}",
                "steps": ["Confirm the highest-confidence evidence", "Execute the smallest reversible action", "Review the result before expanding"],
                "benefits": ["Fast feedback", "Low initial commitment"],
                "tradeoffs": {"speed": 90, "cost": 70, "reliability": 55},
                "risk": "Higher uncertainty",
                "evidence": evidence[:3],
            },
            {
                "id": "strategy-balanced",
                "label": "Balanced path",
                "objective": goal,
                "approach": "Combine validation with measured execution and explicit checkpoints.",
                "steps": ["Validate assumptions", "Execute in checkpoints", "Measure outcome", "Adjust before the next step"],
                "benefits": ["Balanced evidence and execution", "Explicit rollback points"],
                "tradeoffs": {"speed": 65, "cost": 55, "reliability": 78},
                "risk": "Moderate time and cost",
                "evidence": evidence[:5],
            },
            {
                "id": "strategy-rigor",
                "label": "Rigor path",
                "objective": goal,
                "approach": "Add deeper validation, alternative checks and rollback boundaries before action.",
                "steps": ["Validate primary and alternative evidence", "Stress-test assumptions", "Define rollback", "Execute only after the evidence gate"],
                "benefits": ["Higher confidence", "Stronger rollback boundary"],
                "tradeoffs": {"speed": 35, "cost": 75, "reliability": 92},
                "risk": "Slower execution",
                "evidence": evidence[:8],
            },
        ]


decision_orchestrator = DecisionOrchestrator()
