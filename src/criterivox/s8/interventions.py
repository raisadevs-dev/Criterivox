"""Artifact-grounded human challenge and revision contracts."""
from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone


def _now() -> datetime:
    return datetime.now(timezone.utc)


@dataclass(frozen=True)
class HumanIntervention:
    intervention_id: str
    actor_id: str
    target_artifact_ids: tuple[str, ...]
    target_relationship_ids: tuple[str, ...] = ()
    target_path_ids: tuple[str, ...] = ()
    evidence_ids: tuple[str, ...] = ()
    context: str = ""
    proposed_alternative: str = ""
    authorization: str = "pending"
    created_at: datetime = field(default_factory=_now)


@dataclass(frozen=True)
class RevisionRecord:
    revision_id: str
    intervention_id: str
    original_artifact_ids: tuple[str, ...]
    revised_artifact_ids: tuple[str, ...]
    affected_artifact_ids: tuple[str, ...]
    preserved_original: bool = True
    created_at: datetime = field(default_factory=_now)


class InterventionRegistry:
    """Append-only registry used to retain intervention/revision lineage."""

    def __init__(self) -> None:
        self.interventions: dict[str, HumanIntervention] = {}
        self.revisions: dict[str, RevisionRecord] = {}
        self._sequence = 0

    def _id(self, prefix: str) -> str:
        self._sequence += 1
        return f"{prefix}-{self._sequence:06d}"

    def create(self, actor_id: str, target_artifact_ids: tuple[str, ...], *, evidence_ids: tuple[str, ...] = (), context: str = "", proposed_alternative: str = "", target_relationship_ids: tuple[str, ...] = (), target_path_ids: tuple[str, ...] = ()) -> HumanIntervention:
        if not target_artifact_ids and not target_relationship_ids and not target_path_ids:
            raise ValueError("A challenge must target an artifact, relationship, or path.")
        intervention = HumanIntervention(self._id("S8I"), actor_id, target_artifact_ids, target_relationship_ids, target_path_ids, evidence_ids, context, proposed_alternative)
        self.interventions[intervention.intervention_id] = intervention
        return intervention

    def get(self, intervention_id: str) -> HumanIntervention:
        return self.interventions[intervention_id]

    def authorize(self, intervention_id: str, *, actor_id: str) -> HumanIntervention:
        current = self.get(intervention_id)
        updated = HumanIntervention(**{**current.__dict__, "authorization": f"authorized-by:{actor_id}"})
        self.interventions[intervention.intervention_id] = updated
        return updated

    def revise(self, intervention_id: str, original_ids: tuple[str, ...], revised_ids: tuple[str, ...], affected_ids: tuple[str, ...]) -> RevisionRecord:
        intervention = self.get(intervention_id)
        if not intervention.authorization.startswith("authorized-by:"):
            raise PermissionError("Explicit authorization is required before revision.")
        if not original_ids:
            raise ValueError("A revision must preserve at least one original artifact identity.")
        revision = RevisionRecord(self._id("S8R"), intervention_id, original_ids, revised_ids, affected_ids)
        self.revisions[revision.revision_id] = revision
        return revision
