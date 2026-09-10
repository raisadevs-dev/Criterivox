from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any

from criterivox.domain.characters import CharacterState
from criterivox.presentation.states import VisualPresentation


@dataclass(frozen=True, slots=True)
class PresentationContract:
    contract_version: int
    character_id: str
    character_state: str
    animation: str
    active: bool
    prominence: float
    reduced_motion: bool
    message: str | None = None
    event: str | None = None
    task_id: str | None = None
    task_state: str | None = None
    task_source: str | None = None
    task: str | None = None
    task_data_fields: int | None = None
    task_context_fields: int | None = None
    task_created_at: str | None = None
    task_updated_at: str | None = None
    task_references: tuple[str, ...] = ()
    foundation_id: str | None = None
    foundation_material_set_id: str | None = None
    foundation_source_count: int | None = None
    foundation_candidate_count: int | None = None
    foundation_confirmation: str | None = None
    foundation_preview_question: str | None = None
    foundation_match_ratio: float | None = None
    foundation_auto_fill: bool | None = None
    foundation_intent_guesses: tuple[str, ...] = ()
    foundation_recipient: str | None = None
    foundation_log_count: int | None = None
    foundation_log_entries: tuple[str, ...] = ()
    foundation_conflict_fields: tuple[str, ...] = ()
    foundation_conditional_provenance: tuple[str, ...] = ()
    context_id: str | None = None
    context_dimensions: tuple[str, ...] = ()
    context_missing_dimensions: tuple[str, ...] = ()
    context_normalization_count: int | None = None
    context_baseline_id: str | None = None
    context_baseline_status: str | None = None
    context_interpretation_id: str | None = None
    context_uncertainty: tuple[str, ...] = ()
    context_limitations: tuple[str, ...] = ()
    provenance_graph: dict[str, Any] | None = None
    context_diff: dict[str, Any] | None = None
    evidence_completeness: int | None = None
    evidence_debt_level: str | None = None
    evidence_tags: tuple[str, ...] = ()
    memory_status: str | None = None
    memory_recheck_at: str | None = None
    memory_recheck_reason: str | None = None
    observability_events: tuple[dict[str, Any], ...] = ()
    execution_engine: str | None = None
    execution_tier: str | None = None
    fallback_used: bool | None = None
    door_address: str | None = None
    lineage_snapshot: dict[str, Any] | None = None
    coordination_id: str | None = None
    coordination_members: tuple[str, ...] = ()
    delivery_id: str | None = None
    delivery_recipient: str | None = None
    delivery_status: str | None = None
    observations: tuple[dict[str, str], ...] = ()
    findings: tuple[dict[str, str], ...] = ()
    evidence: tuple[dict[str, str], ...] = ()
    activity: tuple[str, ...] = ()
    error: str | None = None

    @classmethod
    def from_visual_presentation(cls, presentation: VisualPresentation, *, active: bool = True, prominence: float = .75, reduced_motion: bool = False, message: str | None = None, event: str | None = None, **task_fields: Any) -> 'PresentationContract':
        character_id = presentation.character_id.strip().lower()
        return cls(1, character_id, presentation.state.value, presentation.animation.value, active, max(0, min(1, prominence)), reduced_motion, message, event, **task_fields)

    @classmethod
    def from_state(cls, character_id: str, state: CharacterState, *, active: bool = True, prominence: float = .75, reduced_motion: bool = False, message: str | None = None, event: str | None = None, **task_fields: Any) -> 'PresentationContract':
        from criterivox.presentation.states import present_state
        canonical_id = character_id.strip().lower()
        return cls.from_visual_presentation(present_state(canonical_id, state), active=active, prominence=prominence, reduced_motion=reduced_motion, message=message, event=event, **task_fields)

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
