from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True, slots=True)
class KaelenPlan:
    action: str
    confidence: float
    operations: tuple[dict[str, Any], ...]
    model_version: str = "kaelen-schema-baseline-1"


class KaelenMLAgent:
    """Constrained schema-diff agent.

    The agent proposes declarative operations only. Execution belongs to a
    validated transformation layer, preventing arbitrary model-generated code.
    """

    def propose(self, before: dict[str, str], after: dict[str, str]) -> KaelenPlan:
        before_keys, after_keys = set(before), set(after)
        removed = sorted(before_keys - after_keys)
        added = sorted(after_keys - before_keys)
        type_changes = sorted(k for k in before_keys & after_keys if before[k] != after[k])
        operations: list[dict[str, Any]] = []
        for field in type_changes:
            operations.append({"op": "cast", "field": field, "from": before[field], "to": after[field]})
        for field in added:
            operations.append({"op": "add_field", "field": field, "type": after[field]})
        for field in removed:
            operations.append({"op": "remove_field", "field": field, "type": before[field]})
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
        change_count = len(type_changes) + len(added) + len(removed)
        confidence = 1.0 if change_count == 0 else max(0.50, 1.0 - 0.10 * change_count)
        return KaelenPlan(action, confidence, tuple(operations))

    @staticmethod
    def validate_plan(plan: KaelenPlan) -> None:
        allowed = {"cast", "add_field", "remove_field"}
        for operation in plan.operations:
            if operation.get("op") not in allowed:
                raise ValueError(f"Unsupported transformation operation: {operation.get('op')}")
