from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Any, Mapping
from uuid import uuid4


class ContextDimension(str, Enum):
    CONTENT = "content"
    CREATOR = "creator"
    PLATFORM = "platform"
    TEMPORAL = "temporal"
    AUDIENCE = "audience"
    ENVIRONMENT = "environment"


class EvidenceStatus(str, Enum):
    OBSERVED = "observed"
    DERIVED = "derived"
    ASSUMED = "assumed"
    SIMULATED = "simulated"
    HYPOTHETICAL = "hypothetical"
    UNKNOWN = "unknown"
    UNAVAILABLE = "unavailable"
    NOT_OBSERVED = "not_observed"


@dataclass(frozen=True, slots=True)
class ContextItem:
    key: str
    value: Any
    dimension: ContextDimension
    status: EvidenceStatus = EvidenceStatus.OBSERVED
    source_ids: tuple[str, ...] = ()
    observed_at: str | None = None
    semantic_label: str | None = None
    uncertainty: str | None = None
    limitations: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        if not self.key.strip():
            raise ValueError("Context item key cannot be empty.")
        if len(self.key) > 200:
            raise ValueError("Context item key is too long.")


@dataclass(frozen=True, slots=True)
class ContextLineage:
    material_set_id: str | None
    created_at: str
    user_intent_context: Mapping[str, Any] = field(default_factory=dict)
    context_definition: str = "criterivox.context.v1"
    source_ids: tuple[str, ...] = ()
    immutable: bool = False


@dataclass(frozen=True, slots=True)
class ContextRecord:
    context_id: str
    created_at: str
    items: tuple[ContextItem, ...] = ()
    lineage: ContextLineage | None = None

    @classmethod
    def create(
        cls,
        *,
        items: tuple[ContextItem, ...] = (),
        material_set_id: str | None = None,
        user_intent_context: Mapping[str, Any] | None = None,
        source_ids: tuple[str, ...] = (),
    ) -> "ContextRecord":
        now = datetime.now(timezone.utc).isoformat()
        return cls(
            context_id=f"CTX-{uuid4().hex[:10].upper()}",
            created_at=now,
            items=items,
            lineage=ContextLineage(
                material_set_id=material_set_id,
                created_at=now,
                user_intent_context=dict(user_intent_context or {}),
                source_ids=source_ids,
            ),
        )

    def by_dimension(self, dimension: ContextDimension) -> tuple[ContextItem, ...]:
        return tuple(item for item in self.items if item.dimension is dimension)

    def missing_dimensions(self) -> tuple[ContextDimension, ...]:
        present = {item.dimension for item in self.items}
        return tuple(d for d in ContextDimension if d not in present)


@dataclass(frozen=True, slots=True)
class NormalizationDecision:
    field: str
    operation: str
    result: Any
    semantic_equivalence_asserted: bool = False
    limitation: str | None = None


@dataclass(frozen=True, slots=True)
class BaselineSpec:
    baseline_id: str
    scope: str
    reference_set: tuple[str, ...] = ()
    observation_window: str | None = None
    context_dimensions: tuple[ContextDimension, ...] = ()
    eligibility: tuple[str, ...] = ()
    provenance: tuple[str, ...] = ()
    status: EvidenceStatus = EvidenceStatus.UNKNOWN
    limitations: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class ContextInterpretation:
    interpretation_id: str
    context_id: str
    observed_information: tuple[str, ...] = ()
    contextual_factors: tuple[str, ...] = ()
    interpretation: str = ""
    uncertainty: tuple[str, ...] = ()
    limitations: tuple[str, ...] = ()
    lineage: ContextLineage | None = None


__all__ = [
    "BaselineSpec", "ContextDimension", "ContextInterpretation", "ContextItem",
    "ContextLineage", "ContextRecord", "EvidenceStatus", "NormalizationDecision",
]
