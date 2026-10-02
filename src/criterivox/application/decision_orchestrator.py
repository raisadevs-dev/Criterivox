from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from criterivox.agents.sandre.store import data_foundations
from criterivox.agents.pramon import PramonPlanner
from .external_research import google_research
from .human_residence_local_store import human_residence_local
from .syvax import syvax_engine
from .case_catalog import load_case


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
        foundation_id: str | None = None,
        case_id: str = "CASE-010",
    ) -> DecisionResult:
        owner_id = human_residence_local.owner_for_session(session_token)
        if owner_id is None:
            raise PermissionError("invalid_session")
        identity = human_residence_local._identity(owner_id)
        email = str(identity.get("email", ""))
        goal = goal.strip()
        if not goal:
            raise ValueError("goal is required")
        case = load_case(case_id)
        case_id = case["case_id"]

        trace: list[dict[str, Any]] = []

        def event(actor: str, responsibility: str, detail: str, **extra: Any) -> None:
            trace.append({
                "actor": actor,
                "agent_id": actor,
                "agent_label": {
                    "human": "Human decision-maker", "sandre": "Sandre",
                    "kaelen": "Kaelen", "dharen": "Dharen",
                    "case": "Case execution contract", "google-research": "External research",
                    "tarkis": "Tarkis", "pramon": "Pramon", "manis": "Manis",
                }.get(actor, actor.replace("-", " ").title()),
                "stage": responsibility, "responsibility": responsibility,
                "status": "completed", "detail": detail, **extra,
            })

        event("human", "authority", "Submitted natural-language problem, supplied material and context.", email=email, case_id=case_id)
        event("sandre", "data stewardship", "Registered supplied material and provenance.")
        event("kaelen", "structure", "Structured the decision inputs and constraints.")
        event(
            "dharen",
            "context",
            "Interpreted goal and context without inventing missing constraints.",
            case_id=case_id,
        )
        event(
            "case",
            "execution contract",
            "Loaded selected case execution contract.",
            case_id=case_id,
            case_title=case.get("title", case_id),
            expected_capabilities=list(case.get("expected_capabilities") or []),
        )

        plan = syvax_engine.compile_plan(goal)
        foundation = None
        foundation_id = foundation_id.strip() if foundation_id else None
        if foundation_id:
            foundation = data_foundations.get(foundation_id)
        elif supplied_data.strip():
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
        option_rows = PramonPlanner().build_options(goal, plan, research_run, foundation=foundation, context=context)        for option in option_rows:
            option["generated_by"] = {"agent_id": "pramon", "agent_label": "Pramon", "stage": "decision options"}
            option["section_attribution"] = {
                key: {"agent_id": "pramon", "agent_label": "Pramon"}
                for key in ("objective", "approach", "steps", "benefits", "tradeoffs", "risk", "evidence", "evidence_basis")
                if key in option
            }
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
            "section_attribution": {
                "goal": {"agent_id": "human", "agent_label": "Human decision-maker"},
                "plan": {"agent_id": "syvax", "agent_label": "Syvax"},
                "options": {"agent_id": "pramon", "agent_label": "Pramon"},
                "challenges": {"agent_id": "manis", "agent_label": "Manis"},
                "evidence_summary": {"agent_id": "sandre", "agent_label": "Sandre"},
            },
            "challenges": [
                "What assumption would break this option first?",
                "What evidence would make you reject this path?",
                "What changes would require replanning before execution?",
            ],
            "research_authorized": allow_external_research,
            "case_id": case_id,
            "case_title": case.get("title", case_id),
            "expected_capabilities": list(case.get("expected_capabilities") or []),
            "evidence_summary": self._foundation_summary(foundation),
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
    def _foundation_summary(foundation: Any) -> dict[str, Any]:
        if foundation is None:
            return {"source_count": 0, "canonical_row_count": 0, "source_names": []}
        return {
            "source_count": len(foundation.sources),
            "canonical_row_count": len(foundation.canonical_data),
            "source_names": [str(source.name) for source in foundation.sources[:20]],
        }

    @staticmethod
    def _options(goal: str, plan: Any, research_run: Any) -> list[dict[str, Any]]:
        return PramonPlanner().build_options(goal, plan, research_run)

    @staticmethod
    def _research_query(goal: str, context: str) -> str:
        context = " ".join(context.split())
        return f"{goal} {context}".strip()[:500]



decision_orchestrator = DecisionOrchestrator()
