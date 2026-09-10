from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from enum import StrEnum
from typing import Iterable, Mapping


class EvidenceDebtLevel(StrEnum):
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"
    UNKNOWN = "UNKNOWN"


@dataclass(frozen=True, slots=True)
class ProvenanceNode:
    node_id: str
    label: str
    kind: str


@dataclass(frozen=True, slots=True)
class ProvenanceEdge:
    source: str
    target: str
    relation: str


@dataclass(frozen=True, slots=True)
class ContextProvenanceGraph:
    nodes: tuple[ProvenanceNode, ...]
    edges: tuple[ProvenanceEdge, ...]


@dataclass(frozen=True, slots=True)
class ContextDiff:
    added_dimensions: tuple[str, ...]
    removed_dimensions: tuple[str, ...]
    unchanged_dimensions: tuple[str, ...]
    changed_fields: tuple[str, ...]


@dataclass(frozen=True, slots=True)
class EvidenceDebt:
    completeness_percent: int
    level: EvidenceDebtLevel
    tags: tuple[str, ...]


@dataclass(frozen=True, slots=True)
class ContextMemoryPolicy:
    ttl: timedelta | None
    expires_at: datetime | None
    status: str

    @classmethod
    def disabled(cls) -> "ContextMemoryPolicy":
        return cls(ttl=None, expires_at=None, status="UNKNOWN")

    @classmethod
    def from_created_at(
        cls,
        created_at: datetime,
        *,
        ttl: timedelta | None,
        now: datetime | None = None,
    ) -> "ContextMemoryPolicy":
        if ttl is None:
            return cls.disabled()
        if ttl.total_seconds() <= 0:
            raise ValueError("Context memory TTL must be positive.")
        current = now or datetime.now(timezone.utc)
        expires_at = created_at + ttl
        return cls(
            ttl=ttl,
            expires_at=expires_at,
            status="EXPIRED" if expires_at <= current else "ACTIVE",
        )


def build_provenance_graph(
    *,
    foundation_id: str | None,
    context_id: str | None,
    interpretation_id: str | None,
    source_ids: Iterable[str] = (),
) -> ContextProvenanceGraph:
    nodes: list[ProvenanceNode] = []
    edges: list[ProvenanceEdge] = []

    for source_id in source_ids:
        nodes.append(ProvenanceNode(source_id, source_id, "SOURCE"))
    if foundation_id:
        nodes.append(ProvenanceNode(foundation_id, "Data Foundation", "FOUNDATION"))
    if context_id:
        nodes.append(ProvenanceNode(context_id, "Context", "CONTEXT"))
    if interpretation_id:
        nodes.append(ProvenanceNode(interpretation_id, "Interpretation", "INTERPRETATION"))

    if foundation_id:
        for source_id in source_ids:
            edges.append(ProvenanceEdge(source_id, foundation_id, "EXTRACTED_INTO"))
    if foundation_id and context_id:
        edges.append(ProvenanceEdge(foundation_id, context_id, "STRUCTURED_AS"))
    if context_id and interpretation_id:
        edges.append(ProvenanceEdge(context_id, interpretation_id, "INTERPRETED_AS"))

    return ContextProvenanceGraph(tuple(nodes), tuple(edges))


def diff_contexts(
    previous_dimensions: Iterable[str],
    current_dimensions: Iterable[str],
    *,
    previous_fields: Mapping[str, object] | None = None,
    current_fields: Mapping[str, object] | None = None,
) -> ContextDiff:
    previous = set(previous_dimensions)
    current = set(current_dimensions)
    previous_fields = previous_fields or {}
    current_fields = current_fields or {}
    changed_fields = tuple(sorted(
        key for key in previous_fields.keys() & current_fields.keys()
        if previous_fields[key] != current_fields[key]
    ))
    return ContextDiff(
        added_dimensions=tuple(sorted(current - previous)),
        removed_dimensions=tuple(sorted(previous - current)),
        unchanged_dimensions=tuple(sorted(previous & current)),
        changed_fields=changed_fields,
    )


def calculate_evidence_debt(
    evidence: Iterable[Mapping[str, object]],
    *,
    missing_context_count: int = 0,
    uncertainty_count: int = 0,
) -> EvidenceDebt:
    items = list(evidence)
    if not items:
        return EvidenceDebt(0, EvidenceDebtLevel.UNKNOWN, ("NO_EVIDENCE",))

    supported = 0
    tags: set[str] = set()
    for item in items:
        status = str(item.get("status", "UNKNOWN")).upper()
        if status in {"OBSERVED", "VERIFIED", "CONFIRMED", "SUPPORTED"}:
            supported += 1
        elif status in {"ASSUMED", "HYPOTHETICAL"}:
            tags.add("ASSUMPTION_OR_HYPOTHESIS")
        elif status == "SIMULATED":
            tags.add("SIMULATED_EVIDENCE")
        else:
            tags.add("UNVERIFIED_EVIDENCE")

    completeness = round((supported / len(items)) * 100)
    if missing_context_count > 0:
        completeness = max(0, completeness - min(30, missing_context_count * 5))
        tags.add("MISSING_CONTEXT")
    if uncertainty_count > 0:
        completeness = max(0, completeness - min(20, uncertainty_count * 4))
        tags.add("UNCERTAINTY")

    if completeness >= 80:
        level = EvidenceDebtLevel.LOW
    elif completeness >= 50:
        level = EvidenceDebtLevel.MEDIUM
    else:
        level = EvidenceDebtLevel.HIGH

    if not tags:
        tags.add("SUPPORTED")
    return EvidenceDebt(completeness, level, tuple(sorted(tags)))


__all__ = [
    "ContextDiff",
    "ContextMemoryPolicy",
    "ContextProvenanceGraph",
    "EvidenceDebt",
    "EvidenceDebtLevel",
    "ProvenanceEdge",
    "ProvenanceNode",
    "build_provenance_graph",
    "calculate_evidence_debt",
    "diff_contexts",
]
