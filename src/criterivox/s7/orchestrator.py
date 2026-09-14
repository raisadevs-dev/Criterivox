from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Mapping

from .mechanisms import build_hypotheses, build_reasoning, decompose, evaluate, mechanism_registry
from .models import AnalysisSession, ArtifactKind, SessionStatus


@dataclass
class ReasoningResearchBureau:
    """Standalone S7 coordinator; it coordinates capabilities, not characters."""
    sessions: dict[str, AnalysisSession] = field(default_factory=dict)

    def start(self, task: str, context: Mapping[str, Any] | None = None) -> AnalysisSession:
        if not task.strip():
            raise ValueError("An analytical task is required.")
        session = AnalysisSession.create(task, context)
        self.sessions[session.session_id] = session
        session.event("ANALYSIS_RECEIVED", task=session.task)
        if not session.context:
            session.missing_information = ("structured context",)
            session.status = SessionStatus.WAITING_FOR_INFORMATION
            session.artifact(ArtifactKind.LIMITATION, "Insufficient context", {"missing": session.missing_information, "reason": "The requested reasoning cannot establish contextual validity without supplied context."})
            session.event("INSUFFICIENT_INFORMATION", missing=session.missing_information)
            return session
        session.status = SessionStatus.RUNNING
        capabilities = decompose(session.task)
        session.event("CAPABILITY_PLAN_CREATED", capabilities=capabilities)
        session.artifact(ArtifactKind.CAPABILITY_PLAN, "Dynamic capability decomposition", {"capabilities": capabilities, "mechanisms": [m.mechanism_id for m in mechanism_registry()]})
        reasoning = build_reasoning(session)
        session.event("REASONING_ARTIFACT_CREATED", artifact_id=reasoning.artifact_id, capability="reasoning_construction")
        hypotheses = build_hypotheses(session, reasoning.artifact_id) if "hypothesis_exploration" in capabilities else None
        if hypotheses:
            session.event("HYPOTHESES_CREATED", artifact_id=hypotheses.artifact_id)
        evaluation = evaluate(session, reasoning.artifact_id, hypotheses.artifact_id if hypotheses else reasoning.artifact_id)
        session.event("EVALUATION_CREATED", artifact_id=evaluation.artifact_id, capability="critical_evaluation")
        result = session.artifact(ArtifactKind.RESULT, "Bounded reasoning result", {"reasoning_artifact_id": reasoning.artifact_id, "hypothesis_artifact_id": hypotheses.artifact_id if hypotheses else None, "evaluation_artifact_id": evaluation.artifact_id, "status": "bounded", "limitations": ("This implementation does not establish external factual truth without evidence or external validation.",)}, parents=(evaluation.artifact_id,))
        session.event("RESULT_READY", artifact_id=result.artifact_id)
        session.status = SessionStatus.COMPLETED
        session.event("ANALYSIS_COMPLETED", result_artifact_id=result.artifact_id)
        return session

    def challenge(self, session_id: str, artifact_id: str, challenge: str) -> AnalysisSession:
        session = self._get(session_id)
        if not challenge.strip():
            raise ValueError("A human challenge is required.")
        target = next((a for a in session.artifacts if a.artifact_id == artifact_id), None)
        if target is None:
            raise ValueError("Unknown analytical artifact.")
        session.branch_id = f"branch-{len({a.branch_id for a in session.artifacts}) + 1}"
        intervention = session.artifact(ArtifactKind.HUMAN_INTERVENTION, "Human challenge", {"action": "challenge", "challenge": challenge.strip(), "target_artifact_id": artifact_id}, parents=(artifact_id,))
        session.event("HUMAN_CHALLENGE", artifact_id=artifact_id, intervention_id=intervention.artifact_id)
        session.status = SessionStatus.RUNNING
        revised = session.artifact(ArtifactKind.REASONING, "Challenge-driven continuation", {"basis_artifact_id": artifact_id, "human_challenge": challenge.strip(), "method": "re-evaluation of affected artifact", "mechanism_id": "s7-critical-check"}, parents=(artifact_id, intervention.artifact_id))
        session.event("BRANCH_CONTINUATION", branch_id=session.branch_id, artifact_id=revised.artifact_id)
        session.status = SessionStatus.COMPLETED
        return session

    def snapshot(self, session_id: str) -> dict[str, Any]:
        session = self._get(session_id)
        return {"session_id": session.session_id, "task": session.task, "status": session.status.value, "branch_id": session.branch_id, "missing_information": session.missing_information, "artifacts": [{"artifact_id": a.artifact_id, "kind": a.kind.value, "title": a.title, "content": dict(a.content), "parent_ids": a.parent_ids, "version": a.version, "branch_id": a.branch_id, "created_at": a.created_at} for a in session.artifacts], "events": [{"event_id": e.event_id, "event_type": e.event_type, "payload": dict(e.payload), "created_at": e.created_at} for e in session.events]}

    def _get(self, session_id: str) -> AnalysisSession:
        try:
            return self.sessions[session_id]
        except KeyError as exc:
            raise ValueError(f"Unknown S7 session: {session_id}") from exc
