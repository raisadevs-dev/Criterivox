from __future__ import annotations

from dataclasses import dataclass
import re
from typing import Iterable

from .models import AnalysisSession, ArtifactKind


@dataclass(frozen=True, slots=True)
class MechanismRecord:
    mechanism_id: str
    name: str
    classification: str
    purpose: str
    provenance: str
    limitations: tuple[str, ...]


MECHANISMS = (
    MechanismRecord("s7-lexical-structure", "Deterministic lexical structure analysis", "EXISTING", "Extract claims, questions and explicit constraints from supplied text.", "Python standard library", ("Does not infer unstated meaning.",)),
    MechanismRecord("s7-hypothesis-variation", "Bounded hypothesis variation", "NEWLY_DESIGNED", "Generate explicit alternatives by varying identifiable claims or conditions without fabricating evidence.", "Criterivox S7 implementation", ("Not an empirical hypothesis generator; alternatives are bounded by supplied material.",)),
    MechanismRecord("s7-critical-check", "Deterministic critical consistency checks", "COMPOSED", "Check unsupported references, contradictions in supplied claims, and missing required context.", "Criterivox domain semantics + S7 composition", ("Cannot establish external truth without evidence.",)),
)


def mechanism_registry() -> tuple[MechanismRecord, ...]:
    return MECHANISMS


def decompose(task: str) -> tuple[str, ...]:
    text = task.strip()
    lower = text.lower()
    capabilities = ["reasoning_construction", "critical_evaluation"]
    if any(token in lower for token in ("alternative", "hypothesis", "possibilit", "scenario", "counterfactual")):
        capabilities.insert(1, "hypothesis_exploration")
    return tuple(dict.fromkeys(capabilities))


def build_reasoning(session: AnalysisSession):
    sentences = tuple(s.strip() for s in re.split(r"(?<=[.!?])\s+", session.task) if s.strip())
    claims = sentences or (session.task,)
    return session.artifact(ArtifactKind.REASONING, "Initial analytical structure", {"claims": claims, "method": "deterministic lexical structure analysis", "mechanism_id": "s7-lexical-structure"})


def build_hypotheses(session: AnalysisSession, reasoning_id: str):
    text = session.task.strip()
    alternatives = [text]
    if " because " in text.lower():
        alternatives.append(re.sub(r"\s+because\s+", " if the stated cause is supported, ", text, flags=re.I))
    if " or " in text.lower():
        alternatives.extend(part.strip() for part in re.split(r"\s+or\s+", text, flags=re.I) if part.strip())
    unique = tuple(dict.fromkeys(alternatives))[:3]
    return session.artifact(ArtifactKind.HYPOTHESIS, "Bounded candidate hypotheses", {"candidates": unique, "basis_artifact_id": reasoning_id, "mechanism_id": "s7-hypothesis-variation", "evidence_status": "not_established"}, parents=(reasoning_id,))


def evaluate(session: AnalysisSession, reasoning_id: str, hypothesis_id: str):
    reasoning = next(a for a in session.artifacts if a.artifact_id == reasoning_id)
    hypothesis = next(a for a in session.artifacts if a.artifact_id == hypothesis_id)
    claims = reasoning.content.get("claims", ())
    findings = []
    if not session.context:
        findings.append("No structured context was supplied; contextual validity cannot be established.")
    if any(len(str(c).split()) < 3 for c in claims):
        findings.append("One or more analytical claims are too sparse for meaningful logical assessment from text alone.")
    if not findings:
        findings.append("No deterministic defect was identified from the supplied structure; external truth remains unverified.")
    return session.artifact(ArtifactKind.EVALUATION, "Critical evaluation", {"findings": tuple(findings), "reasoning_artifact_id": reasoning_id, "hypothesis_artifact_id": hypothesis_id, "mechanism_id": "s7-critical-check", "status": "bounded"}, parents=(reasoning_id, hypothesis_id))
