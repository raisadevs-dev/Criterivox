from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from criterivox.context.ml import S6LearnedModelRegistry


@dataclass(frozen=True, slots=True)
class KaelenPlan:
    action: str
    confidence: float
    operations: tuple[dict[str, Any], ...]
    model_version: str = "kaelen-schema-fused-1"
    learned_action: str | None = None
    learned_confidence: float | None = None


class KaelenMLAgent:
    """Constrained schema-change planning for Kaelen's build responsibility."""

    model_version = "kaelen-schema-fused-1"

    def __init__(self, *, model_registry: S6LearnedModelRegistry | None = None):
        self.model_registry = model_registry or S6LearnedModelRegistry()
        self.learned_model = self.model_registry.kaelen
        self.learned_model.load()

    @property
    def is_ready(self) -> bool:
        return True

    @property
    def learned_model_available(self) -> bool:
        return self.learned_model.available

    def propose(self, before: dict[str, str], after: dict[str, str]) -> KaelenPlan:
        before_keys, after_keys = set(before), set(after)
        removed = sorted(before_keys - after_keys)
        added = sorted(after_keys - before_keys)
        type_changes = sorted(
            key for key in before_keys & after_keys if before[key] != after[key]
        )
        operations: list[dict[str, Any]] = [
            {"op": "cast", "field": field, "from": before[field], "to": after[field]}
            for field in type_changes
        ]
        operations.extend(
            {"op": "add_field", "field": field, "type": after[field]} for field in added
        )
        operations.extend(
            {"op": "remove_field", "field": field, "type": before[field]}
            for field in removed
        )

        if type_changes:
            action = "type_repair"
        elif added and removed and len(added) == len(removed):
            action = "schema_mapping_review"
        elif added:
            action = "schema_extension"
        elif removed:
            action = "schema_reduction_review"
        else:
            action = "no_change"

        learned_action = learned_confidence = None
        if self.learned_model.available:
            prediction = self.learned_model.predict_one(
                f"schema before={sorted(before.items())}; after={sorted(after.items())}; "
                f"added={added}; removed={removed}; type_changes={type_changes}"
            )
            if prediction:
                learned_action, learned_confidence = prediction.label, prediction.confidence
            if learned_action == action and learned_confidence is not None:
                action = learned_action

        change_count = len(type_changes) + len(added) + len(removed)
        deterministic_confidence = 1.0 if change_count == 0 else max(
            0.5, 1.0 - 0.1 * change_count
        )
        confidence = (
            deterministic_confidence
            if learned_confidence is None
            else (deterministic_confidence + learned_confidence) / 2
        )
        return KaelenPlan(
            action=action,
            confidence=confidence,
            operations=tuple(operations),
            learned_action=learned_action,
            learned_confidence=learned_confidence,
        )

    @staticmethod
    def validate_plan(plan: KaelenPlan) -> None:
        allowed = {"cast", "add_field", "remove_field"}
        for operation in plan.operations:
            if operation.get("op") not in allowed:
                raise ValueError(
                    f"Unsupported transformation operation: {operation.get('op')}"
                )
