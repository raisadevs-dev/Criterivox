from __future__ import annotations

from enum import Enum
from typing import Any, Iterable


class ResearchStatus(str, Enum):
    ESTABLISHED = "established"
    RESEARCHER_DEFINED = "researcher-defined"
    UNRESOLVED = "unresolved"


class ResearchPriority(str, Enum):
    BLOCKING = "blocking"
    IMPORTANT = "important"
    DEFERRED = "deferred"


class Comparability(str, Enum):
    DIRECT = "direct"
    CONDITIONAL = "conditional"
    RELATED = "related"
    NOT_COMPARABLE = "not_comparable"
    UNRESOLVED = "unresolved"


class EvidenceLayer(str, Enum):
    SOURCE = "source"
    EVIDENCE = "evidence"
    FINDING = "finding"
    INTERPRETATION = "interpretation"
    RESEARCH_QUESTION = "research_question"
    HYPOTHESIS = "hypothesis"


class ValidationState(str, Enum):
    EXTRACTED = "extracted"
    VALIDATED = "validated"
    PENDING_RESEARCHER_APPROVAL = "pending_researcher_approval"
    ESTABLISHED = "established"
    UNRESOLVED = "unresolved"
    RESEARCHER_DEFINED = "researcher-defined"


class ConfidenceDimension(str, Enum):
    EXTRACTION = "extraction"
    CLASSIFICATION = "classification"
    INTENT_PREDICTION = "intent_prediction"
    RESEARCH_EVIDENCE = "research_evidence"
    DATA_QUALITY = "data_quality"


CORE_PLATFORMS = ("instagram", "youtube", "facebook", "x", "linkedin")
DEFERRED_PLATFORMS = ("reddit", "telegram", "whatsapp", "sharechat")
MISSINGNESS_STATES = (
    "unknown",
    "not_provided",
    "not_applicable",
    "not_measured",
    "not_observed",
    "withheld",
    "unavailable",
    "extraction_failed",
)


class ResearchSemanticsError(ValueError):
    pass


def require_status(value: str | ResearchStatus) -> ResearchStatus:
    try:
        return value if isinstance(value, ResearchStatus) else ResearchStatus(value)
    except ValueError as exc:
        raise ResearchSemanticsError(f"Unsupported research status: {value!r}") from exc


def validate_confidence(*, dimension: str | ConfidenceDimension, score: float | None, method: str | None = None) -> None:
    """Reject scientifically implied confidence when its method is undefined."""
    try:
        ConfidenceDimension(dimension)
    except ValueError as exc:
        raise ResearchSemanticsError(f"Unsupported confidence dimension: {dimension!r}") from exc
    if score is None:
        return
    if not 0.0 <= score <= 1.0:
        raise ResearchSemanticsError("Confidence score must be between 0 and 1.")
    if not method or not method.strip():
        raise ResearchSemanticsError("A confidence score requires an explicit calculation/validation method.")


def normalize_deterministic(value: Any) -> Any:
    """Only perform representation-safe normalization approved by R-01."""
    if isinstance(value, str):
        return value.strip()
    return value


def classify_comparability(value: str | Comparability) -> Comparability:
    try:
        return value if isinstance(value, Comparability) else Comparability(value)
    except ValueError as exc:
        raise ResearchSemanticsError(f"Unsupported comparability relationship: {value!r}") from exc


def validate_research_trace(*, source_id: str | None, evidence_id: str | None, finding_id: str | None, status: str | ResearchStatus) -> None:
    state = require_status(status)
    if state in {ResearchStatus.ESTABLISHED, ResearchStatus.RESEARCHER_DEFINED} and (not source_id or not evidence_id):
        raise ResearchSemanticsError("Established or researcher-defined material requires source and evidence traceability.")
    if finding_id is not None and not finding_id.strip():
        raise ResearchSemanticsError("Finding identifiers cannot be empty.")


def validate_missingness(value: str, *, allowed: Iterable[str] = MISSINGNESS_STATES) -> str:
    value = value.strip().lower()
    if value not in set(allowed):
        raise ResearchSemanticsError(f"Unsupported missingness state: {value!r}")
    return value


__all__ = [
    "CORE_PLATFORMS", "DEFERRED_PLATFORMS", "MISSINGNESS_STATES", "Comparability",
    "ConfidenceDimension", "EvidenceLayer", "ResearchPriority", "ResearchSemanticsError",
    "ResearchStatus", "ValidationState", "classify_comparability", "normalize_deterministic",
    "require_status", "validate_confidence", "validate_missingness", "validate_research_trace",
]
