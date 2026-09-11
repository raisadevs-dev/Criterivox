from __future__ import annotations

from dataclasses import dataclass
from random import Random
from typing import Any


@dataclass(frozen=True, slots=True)
class CorruptionCase:
    mutation_type: str
    seed: int
    affected_fields: tuple[str, ...]
    before: tuple[dict[str, Any], ...]
    after: tuple[dict[str, Any], ...]
    expected_action: str


def corrupt(rows: list[dict[str, Any]], mutation_type: str, seed: int = 7) -> CorruptionCase:
    if not rows:
        raise ValueError("rows must not be empty")
    rng = Random(seed)
    before = [dict(row) for row in rows]
    after = [dict(row) for row in rows]
    fields = sorted({key for row in after for key in row})
    if mutation_type == "missing_value":
        field = rng.choice(fields)
        after[0][field] = None
        action = "impute_or_review"
    elif mutation_type == "duplicate_row":
        after.append(dict(after[0]))
        field = "__row__"
        action = "deduplicate_or_review"
    elif mutation_type == "type_change":
        field = rng.choice(fields)
        after[0][field] = str(after[0][field])
        action = "type_repair"
    elif mutation_type == "rename_field":
        field = rng.choice(fields)
        new_name = f"{field}_renamed"
        for row in after:
            row[new_name] = row.pop(field)
        field = f"{field}->{new_name}"
        action = "schema_mapping_review"
    elif mutation_type == "categorical_normalization":
        field = rng.choice(fields)
        after[0][field] = str(after[0][field]).strip().lower()
        action = "normalize_category"
    elif mutation_type == "numeric_outlier":
        numeric = next((f for f in fields if isinstance(after[0].get(f), (int, float)) and not isinstance(after[0].get(f), bool)), None)
        if numeric is None:
            raise ValueError("numeric_outlier requires a numeric field")
        after[0][numeric] = float(after[0][numeric]) * 1000 + 1
        field = numeric
        action = "anomaly_review"
    else:
        raise ValueError(f"Unsupported corruption type: {mutation_type}")
    return CorruptionCase(mutation_type, seed, (field,), tuple(before), tuple(after), action)


__all__ = ["CorruptionCase", "corrupt"]
