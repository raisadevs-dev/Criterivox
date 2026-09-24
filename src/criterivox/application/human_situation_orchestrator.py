from __future__ import annotations

from dataclasses import asdict
from typing import Any

from .decision_orchestrator import decision_orchestrator
from .situation import DecisionSupportResult, SafetyLevel, SituationUnderstanding
from .situation_understanding import SituationUnderstandingService
from .ollama_language import OllamaLanguageLayer


class HumanSituationOrchestrator:
    """Human-first gateway: understand -> safety -> existing decision pipeline -> synthesis."""

    def __init__(
        self,
        understanding: SituationUnderstandingService | None = None,
        language: OllamaLanguageLayer | None = None,
    ) -> None:
        self.understanding = understanding or SituationUnderstandingService()
        self.language = language or OllamaLanguageLayer()

    def execute(
        self,
        *,
        description: str,
        session_token: str = "",
        residence_id: str = "",
        image_count: int = 0,
        image_roles: tuple[str, ...] = (),
        supplied_data: str = "",
        context: str = "",
        allow_external_research: bool = False,
    ) -> dict[str, Any]:
        understanding = self.understanding.understand(
            description,
            image_count=image_count,
            image_roles=image_roles,
        )
        situation = understanding.situation

        if situation.safety is SafetyLevel.IMMEDIATE:
            return self._immediate(understanding)

        if understanding.needs_clarification:
            return {
                "status": "clarification_required",
                "understanding": self._understanding_payload(understanding),
                "questions": list(understanding.clarifying_questions),
                "ollama_used": False,
            }

        if session_token:
            result = decision_orchestrator.execute(
                session_token=session_token,
                residence_id=residence_id,
                goal=description,
                supplied_data=supplied_data,
                context=context,
                allow_external_research=allow_external_research,
            )
            strategy = result.strategy
            decision_id = result.decision_id
            trace = result.trace
            research = result.research
        else:
            from .syvax import syvax_engine
            plan = syvax_engine.compile_plan(description)
            strategy = {
                "goal": description,
                "plan": {
                    "task_id": plan.task_id,
                    "intent_type": plan.intent.intent_type,
                    "confidence": plan.intent.confidence,
                    "entities": list(plan.intent.entities),
                },
                "options": decision_orchestrator._options(description, plan, None),
                "challenges": [
                    "What information would change your choice?",
                    "What is the smallest reversible next step?",
                ],
                "research_authorized": False,
            }
            decision_id = None
            trace = []
            research = None

        support = self._support(understanding, strategy, trace, research)
        synthesis = self.language.synthesize(
            situation=description,
            structured={**asdict(situation), 'safety': situation.safety.value},
        )
        return {
            "status": "ready",
            "decision_id": decision_id,
            "understanding": self._understanding_payload(understanding),
            "support": support,
            "strategy": strategy,
            "trace": trace,
            "research": research,
            "ollama_used": synthesis is not None,
            "human_readable": synthesis or self._fallback_text(support),
        }

    def _immediate(self, understanding: SituationUnderstanding) -> dict[str, Any]:
        return {
            "status": "immediate_safety",
            "understanding": self._understanding_payload(understanding),
            "questions": ["Are you safe right now?"],
            "support": {
                "situation_summary": "Your description may involve an immediate safety concern.",
                "what_matters": ["Your immediate safety comes before ordinary decision analysis."],
                "suggested_next_steps": [
                    "Move toward a safe place or a trusted nearby person if you can do so safely.",
                    "Contact a trusted adult or appropriate real-world emergency/support service.",
                    "Do not confront or retaliate against someone who may be threatening you.",
                ],
                "safety_guidance": ["Criterivox is not a substitute for a responsible adult or emergency help."],
            },
            "ollama_used": False,
        }

    @staticmethod
    def _understanding_payload(u: SituationUnderstanding) -> dict[str, Any]:
        return {
            "situation": asdict(u.situation),
            "intent": u.intent,
            "needs_clarification": u.needs_clarification,
            "notes": list(u.notes),
        }

    @staticmethod
    def _support(u: SituationUnderstanding, strategy: dict[str, Any], trace: list[dict[str, Any]], research: Any) -> dict[str, Any]:
        options = strategy.get("options") or []
        next_steps: list[str] = []
        if u.situation.safety is SafetyLevel.SENSITIVE:
            next_steps = [
                "Tell a trusted adult or supportive person what happened.",
                "Keep relevant messages or records where doing so is safe and appropriate.",
                "Avoid escalating the confrontation; stay near supportive people.",
            ]
        elif options:
            next_steps = list(options[0].get("steps", []))
        result = DecisionSupportResult(
            situation_summary=u.situation.description,
            what_matters=("What the user reported", "What remains uncertain", "Which next step is safe and reversible"),
            options=tuple(options),
            relevant_evidence=(
                (f"{len(research.get('results', []))} external research results attached.",)
                if isinstance(research, dict)
                else ("No external evidence was requested.",)
            ),
            uncertainties=tuple(u.situation.uncertainties) or ("Some context may still be missing.",),
            suggested_next_steps=tuple(next_steps),
            safety_guidance=(
                ("The photos do not establish identity, intent, personality, or bullying behavior.",)
                if u.situation.image_count
                else ()
            ),
            reasoning_summary="Criterivox separated the reported situation from uncertain interpretation and routed it through existing decision capabilities.",
            deeper_inspection={"trace": trace},
        )
        return asdict(result)

    @staticmethod
    def _fallback_text(support: dict[str, Any]) -> str:
        lines = ["WHAT I UNDERSTAND", support["situation_summary"], "", "WHAT MATTERS"]
        lines.extend(f"• {x}" for x in support["what_matters"])
        lines += ["", "WHAT YOU CAN DO NEXT"]
        lines.extend(f"{i}. {x}" for i, x in enumerate(support["suggested_next_steps"], 1))
        lines += ["", "WHY", support["reasoning_summary"], "", "WHAT I'M NOT SURE ABOUT"]
        lines.extend(f"• {x}" for x in support["uncertainties"])
        return "\n".join(lines)


human_situation_orchestrator = HumanSituationOrchestrator()
