from __future__ import annotations

from dataclasses import asdict
from datetime import datetime, timezone
from typing import Any, Mapping

from .engine import ContextIntelligenceEngine
from .models import (
    AdaptiveContextState, ContextCheckpoint, ContextFrame, ContextInput, ContextItem,
    ContextTier,
)


class ContextRuntime:
    """Authoritative S6 runtime state over the S5 DataFoundation boundary."""

    schema_version = "s6.context-runtime.v1"

    def __init__(self, engine: ContextIntelligenceEngine | None = None) -> None:
        self.engine = engine or ContextIntelligenceEngine()
        self.frames: dict[str, ContextFrame] = {}
        self.states: dict[str, AdaptiveContextState] = {}
        self.checkpoints: dict[str, ContextCheckpoint] = {}
        self.scratchpads: dict[str, dict[str, Any]] = {}
        self.revisions: dict[str, int] = {}

    def build_from_foundation(
        self,
        foundation: Any,
        *,
        task_id: str,
        user_context: Mapping[str, Any] | None = None,
        manual: bool = False,
        activation_reason: str = "normal_pipeline",
    ) -> AdaptiveContextState:
        foundation_id = str(foundation.foundation_id)
        previous = self.states.get(foundation_id)
        supplied = dict(getattr(foundation, "supplied_context", {}) or {})
        supplied.update(user_context or {})
        items = self._foundation_items(foundation)
        request = str(supplied.pop("request", "Analyze the curated research foundation in context.")).strip()
        hard = tuple(str(v) for v in supplied.pop("hard_constraints", ()) or ())
        soft = tuple(str(v) for v in supplied.pop("soft_guidelines", ()) or ())
        scratch = dict(supplied.pop("scratchpad", {}) or {})
        context = ContextInput(
            request=request,
            items=items,
            hard_constraints=hard,
            soft_guidelines=soft,
            environment={**supplied, "foundation_id": foundation_id, "task_id": task_id},
            scratchpad=scratch,
            metadata={"foundation_revision": self.revision_for(foundation_id), "manual": manual, "activation_reason": activation_reason},
        )
        previous_frame = previous.frame if previous else None
        state = self.engine.build(context, previous=previous_frame)
        self.frames[foundation_id] = state.frame
        self.states[foundation_id] = state
        self.scratchpads.setdefault(task_id, {}).update(scratch)
        self.revisions[foundation_id] = self.revision_for(foundation_id) + 1
        return state

    def checkpoint(self, foundation_id: str, *, task_id: str, scratchpad: Mapping[str, Any] | None = None) -> ContextCheckpoint:
        state = self.states[foundation_id]
        pad = dict(self.scratchpads.get(task_id, {}))
        pad.update(scratchpad or {})
        checkpoint = self.engine.anuka.checkpoint(state, pad)
        self.checkpoints[checkpoint.checkpoint_id] = checkpoint
        self.scratchpads[task_id] = pad
        self.states[foundation_id] = AdaptiveContextState(
            frame=state.frame, diff=state.diff, active_context=state.active_context,
            sandbox_states=state.sandbox_states, checkpoint_id=checkpoint.checkpoint_id,
            state_version=state.state_version,
        )
        return checkpoint

    def revision_for(self, foundation_id: str) -> int:
        return self.revisions.get(foundation_id, 0)

    def should_activate_anuka(
        self,
        *,
        new_context: bool = False,
        requirements_changed: bool = False,
        evidence_changed: bool = False,
        hypothesis_changed: bool = False,
        constraint_changed: bool = False,
        drift_detected: bool = False,
        counterfactual_requested: bool = False,
        downstream_incompatible: bool = False,
        manual_activation: bool = False,
    ) -> bool:
        return manual_activation or any((new_context, requirements_changed, evidence_changed, hypothesis_changed, constraint_changed, drift_detected, counterfactual_requested, downstream_incompatible))

    def compact_projection(self, foundation_id: str) -> dict[str, Any]:
        state = self.states[foundation_id]
        return {
            "context_id": state.frame.frame_id,
            "state_version": state.state_version,
            "checkpoint_id": state.checkpoint_id,
            "diff": {"added": list(state.diff.added), "removed": list(state.diff.removed), "changed": list(state.diff.changed), "goal_shift": state.diff.goal_shift, "constraint_shift": state.diff.constraint_shift},
            "item_count": len(state.frame.items),
            "violation_count": len(state.frame.violations),
            "revision": self.revision_for(foundation_id),
        }

    def durable_payload(self, foundation_id: str, *, task_id: str) -> dict[str, Any]:
        state = self.states[foundation_id]
        checkpoint = self.checkpoints.get(state.checkpoint_id or "")
        return {
            "message_type": "context_state",
            "schema_version": self.schema_version,
            "foundation_id": foundation_id,
            "task_id": task_id,
            "revision": self.revision_for(foundation_id),
            "updated_at": datetime.now(timezone.utc).isoformat(),
            "context_frame": _jsonable(state.frame),
            "adaptive_context_state": _jsonable(state),
            "context_checkpoint": _jsonable(checkpoint) if checkpoint else None,
            "scratchpad": dict(self.scratchpads.get(task_id, {})),
            "provenance_reference_ids": _source_ids(state.frame),
        }

    def handoff_payload(self, foundation_id: str, *, task_id: str, recipient: str, reason: str) -> dict[str, Any]:
        state = self.states[foundation_id]
        return {
            "message_type": "context_handoff",
            "schema_version": self.schema_version,
            "sender": "dharen",
            "recipient": recipient,
            "foundation_id": foundation_id,
            "task_id": task_id,
            "reason": reason,
            "frame_id": state.frame.frame_id,
            "state_version": state.state_version,
            "checkpoint_id": state.checkpoint_id,
            "active_context": dict(state.active_context),
            "diff": {"added": list(state.diff.added), "removed": list(state.diff.removed), "changed": list(state.diff.changed), "goal_shift": state.diff.goal_shift, "constraint_shift": state.diff.constraint_shift},
            "provenance_reference_ids": _source_ids(state.frame),
        }

    @staticmethod
    def _foundation_items(foundation: Any) -> tuple[ContextItem, ...]:
        source_ids = tuple(getattr(source, "source_id", "") for source in getattr(foundation, "sources", ()) if getattr(source, "source_id", ""))
        rows = tuple(getattr(foundation, "canonical_data", ()) or ())
        items: list[ContextItem] = [
            ContextItem("foundation.canonical_record_count", len(rows), ContextTier.CRITICAL, True, source_ids),
            ContextItem("foundation.candidate_count", len(getattr(foundation, "candidates", ()) or ()), ContextTier.HIGH, False, source_ids),
            ContextItem("foundation.source_count", len(getattr(foundation, "sources", ()) or ()), ContextTier.HIGH, False, source_ids),
            ContextItem("foundation.confirmation", str(getattr(getattr(foundation, "confirmation_status", None), "value", "unknown")), ContextTier.CRITICAL, True, source_ids),
            ContextItem("foundation.handoff_ready", bool(getattr(foundation, "handoff_ready", False)), ContextTier.CRITICAL, True, source_ids),
        ]
        quality = getattr(foundation, "quality", None)
        if quality is not None:
            items.extend((
                ContextItem("foundation.quality.validation_errors", tuple(getattr(quality, "validation_errors", ())), ContextTier.HIGH, False, source_ids),
                ContextItem("foundation.quality.validation_warnings", tuple(getattr(quality, "validation_warnings", ())), ContextTier.MEDIUM, False, source_ids),
                ContextItem("foundation.quality.anomaly_count", int(getattr(quality, "anomaly_count", 0)), ContextTier.HIGH, False, source_ids),
                ContextItem("foundation.quality.missing_count", int(getattr(quality, "missing_count", 0)), ContextTier.HIGH, False, source_ids),
            ))
        return tuple(items)


def _jsonable(value: Any) -> Any:
    if value is None or isinstance(value, (str, int, float, bool)):
        return value
    if isinstance(value, Mapping):
        return {str(k): _jsonable(v) for k, v in value.items()}
    if isinstance(value, (list, tuple, set)):
        return [_jsonable(v) for v in value]
    if hasattr(value, "value") and not hasattr(value, "__dataclass_fields__"):
        return _jsonable(value.value)
    if hasattr(value, "__dataclass_fields__"):
        return {k: _jsonable(v) for k, v in asdict(value).items()}
    return str(value)


def _source_ids(frame: ContextFrame) -> list[str]:
    return sorted({source for item in frame.items for source in item.source_ids if source})


__all__ = ["ContextRuntime"]
