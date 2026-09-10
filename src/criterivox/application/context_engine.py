from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Any, Mapping

from criterivox.domain.context import (
    BaselineSpec,
    ContextDimension,
    ContextInterpretation,
    ContextItem,
    ContextLineage,
    ContextRecord,
    EvidenceStatus,
    NormalizationDecision,
)
from criterivox.domain.context_intelligence import (
    ContextDiff,
    ContextMemoryPolicy,
    ContextProvenanceGraph,
    EvidenceDebt,
    build_provenance_graph,
    calculate_evidence_debt,
    diff_contexts,
)
from criterivox.domain.data_foundation import DataFoundation, DataHandoff


@dataclass(frozen=True, slots=True)
class ContextBuildResult:
    context: ContextRecord
    normalization: tuple[NormalizationDecision, ...]
    baselines: tuple[BaselineSpec, ...]
    interpretation: ContextInterpretation
    provenance_graph: ContextProvenanceGraph
    context_diff: ContextDiff
    evidence_debt: EvidenceDebt
    memory: ContextMemoryPolicy


class ContextEngine:
    """Research-bounded S6 context engine."""

    def create_from_material_set(
        self,
        material: DataFoundation | DataHandoff,
        *,
        user_intent_context: Mapping[str, Any] | None = None,
        previous_context: Mapping[str, Any] | None = None,
        memory_recheck_seconds: int | None = None,
        memory_recheck_reason: str | None = None,
        now: datetime | None = None,
    ) -> ContextBuildResult:
        material_id = getattr(material, "foundation_id", None)
        canonical = tuple(getattr(material, "canonical_data", ()))
        source_records = tuple(getattr(material, "sources", ()))
        source_ids = tuple(getattr(material, "source_ids", ())) or tuple(
            source.source_id for source in source_records
        )
        supplied = dict(getattr(material, "supplied_context", {}) or {})
        supplied.update(user_intent_context or {})

        items: list[ContextItem] = []
        if canonical:
            items.append(
                ContextItem(
                    "material.record_count",
                    len(canonical),
                    ContextDimension.CONTENT,
                    source_ids=source_ids,
                )
            )
        else:
            items.append(
                ContextItem(
                    "material.record_count",
                    None,
                    ContextDimension.CONTENT,
                    status=EvidenceStatus.UNKNOWN,
                    source_ids=source_ids,
                    limitations=("No canonical rows are available.",),
                )
            )
        for key, value in supplied.items():
            items.append(
                ContextItem(
                    key=f"supplied.{key}",
                    value=value,
                    dimension=ContextDimension.ENVIRONMENT,
                    status=EvidenceStatus.OBSERVED,
                    source_ids=source_ids,
                )
            )

        created_at = now or datetime.now(timezone.utc)
        lineage = ContextLineage(
            material_set_id=material_id,
            created_at=created_at.isoformat(),
            user_intent_context=supplied,
            source_ids=source_ids,
            immutable=False,
        )
        context = ContextRecord(
            context_id=f"CTX-{material_id or 'UNBOUND'}",
            created_at=created_at.isoformat(),
            items=tuple(items),
            lineage=lineage,
        )
        normalization = self.normalize(context)
        baselines = (self.create_baseline(context),)
        interpretation = self.interpret(context)
        current_fields = {item.key: item.value for item in context.items}
        context_diff = diff_contexts(
            previous_context.keys() if previous_context else (),
            current_fields.keys(),
            previous_fields=previous_context,
            current_fields=current_fields,
        )
        evidence = tuple({"status": item.status.value} for item in context.items)
        evidence_debt = calculate_evidence_debt(
            evidence,
            missing_context_count=len(context.missing_dimensions()),
            uncertainty_count=len(interpretation.uncertainty),
        )
        provenance_graph = build_provenance_graph(
            foundation_id=material_id,
            context_id=context.context_id,
            interpretation_id=interpretation.interpretation_id,
            source_ids=source_ids,
        )
        if memory_recheck_seconds is None:
            if memory_recheck_reason:
                raise ValueError(
                    "A memory recheck interval is required when a recheck reason is supplied."
                )
            memory = ContextMemoryPolicy.disabled()
        else:
            if memory_recheck_seconds <= 0:
                raise ValueError("Context memory TTL must be positive.")
            if not memory_recheck_reason or not memory_recheck_reason.strip():
                raise ValueError(
                    "A memory recheck reason is required when a recheck interval is supplied."
                )
            memory = ContextMemoryPolicy.from_created_at(
                created_at,
                ttl=timedelta(seconds=memory_recheck_seconds),
                reason=memory_recheck_reason.strip(),
                now=created_at,
            )
        return ContextBuildResult(
            context,
            normalization,
            baselines,
            interpretation,
            provenance_graph,
            context_diff,
            evidence_debt,
            memory,
        )

    def normalize(self, context: ContextRecord) -> tuple[NormalizationDecision, ...]:
        decisions: list[NormalizationDecision] = []
        for item in context.items:
            if isinstance(item.value, str):
                trimmed = item.value.strip()
                if trimmed != item.value:
                    decisions.append(
                        NormalizationDecision(
                            field=item.key,
                            operation="trim_whitespace",
                            result=trimmed,
                            limitation="Representation cleanup only; semantic equivalence was not inferred.",
                        )
                    )
        return tuple(decisions)

    def create_baseline(self, context: ContextRecord) -> BaselineSpec:
        return BaselineSpec(
            baseline_id=f"BASE-{context.context_id}",
            scope="context-specific reference representation",
            reference_set=(context.context_id,),
            context_dimensions=tuple(item.dimension for item in context.items),
            provenance=context.lineage.source_ids if context.lineage else (),
            status=EvidenceStatus.UNKNOWN,
            limitations=(
                "Baseline-selection methodology is not empirically validated for Criterivox.",
            ),
        )

    def interpret(self, context: ContextRecord) -> ContextInterpretation:
        observed = tuple(
            item.key for item in context.items if item.status is EvidenceStatus.OBSERVED
        )
        factors = tuple(item.key for item in context.items)
        limitations = [
            limitation for item in context.items for limitation in item.limitations
        ]
        if not context.items:
            limitations.append("No contextual information is available.")
        limitations.append(
            "This structure is not a validated causal or predictive explanation."
        )
        return ContextInterpretation(
            interpretation_id=f"INT-{context.context_id}",
            context_id=context.context_id,
            observed_information=observed,
            contextual_factors=factors,
            interpretation="Structured contextual record prepared for downstream inspection.",
            uncertainty=("Context completeness and baseline validity may be limited.",),
            limitations=tuple(dict.fromkeys(limitations)),
            lineage=context.lineage,
        )


@dataclass(frozen=True, slots=True)
class ScratchpadEntry:
    key: str
    value: Any
    expires_at: datetime


class Scratchpad:
    """Short-lived working state for implementation and experimentation."""

    def __init__(self, ttl: timedelta = timedelta(hours=24)) -> None:
        if ttl.total_seconds() <= 0:
            raise ValueError("Scratchpad TTL must be positive.")
        self._ttl = ttl
        self._entries: dict[str, ScratchpadEntry] = {}

    @property
    def ttl(self) -> timedelta:
        return self._ttl

    def put(self, key: str, value: Any, *, now: datetime | None = None) -> ScratchpadEntry:
        current = now or datetime.now(timezone.utc)
        entry = ScratchpadEntry(key, value, current + self._ttl)
        self._entries[key] = entry
        return entry

    def cleanup(self, *, now: datetime | None = None, signed_off: bool = False) -> tuple[str, ...]:
        current = now or datetime.now(timezone.utc)
        removed: list[str] = []
        for key, entry in tuple(self._entries.items()):
            if signed_off or entry.expires_at <= current:
                removed.append(key)
                del self._entries[key]
        return tuple(removed)

    def get(self, key: str, *, now: datetime | None = None) -> Any | None:
        self.cleanup(now=now)
        entry = self._entries.get(key)
        return None if entry is None else entry.value

    def snapshot(self, *, now: datetime | None = None) -> tuple[ScratchpadEntry, ...]:
        self.cleanup(now=now)
        return tuple(self._entries.values())


class ScratchpadRegistry:
    """Task-scoped scratchpads shared by S6 character runtime handoffs."""

    def __init__(self, ttl: timedelta = timedelta(hours=24)) -> None:
        self._ttl = ttl
        self._pads: dict[str, Scratchpad] = {}

    @property
    def ttl(self) -> timedelta:
        return self._ttl

    def for_task(self, task_id: str) -> Scratchpad:
        key = task_id.strip() or "UNBOUND"
        if key not in self._pads:
            self._pads[key] = Scratchpad(ttl=self._ttl)
        return self._pads[key]

    def sign_off(self, task_id: str) -> tuple[str, ...]:
        key = task_id.strip() or "UNBOUND"
        pad = self._pads.pop(key, None)
        return () if pad is None else pad.cleanup(signed_off=True)


__all__ = ["ContextBuildResult", "ContextEngine", "Scratchpad", "ScratchpadEntry", "ScratchpadRegistry"]
