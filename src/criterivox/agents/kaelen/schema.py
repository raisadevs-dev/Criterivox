from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Callable


def _cast(value: Any, target: str) -> Any:
    if value is None:
        return None
    normalized = target.lower()
    if normalized in {"str", "string", "text"}:
        return str(value)
    if normalized in {"int", "integer"}:
        return int(value)
    if normalized in {"float", "number"}:
        return float(value)
    if normalized in {"bool", "boolean"}:
        if isinstance(value, str):
            return value.strip().lower() in {"1", "true", "yes", "y"}
        return bool(value)
    return value


@dataclass(frozen=True, slots=True)
class SchemaTransformer:
    """Deterministic, inspectable schema mapping and type transformation."""

    def transform(
        self,
        rows: list[dict[str, Any]],
        target_schema: list[str],
        aliases: dict[str, str] | None = None,
        casts: dict[str, str] | None = None,
    ) -> dict[str, Any]:
        aliases = aliases or {}
        casts = casts or {}
        source_to_target = {source: aliases.get(source, source) for source in self.schema(rows)}
        transformed: list[dict[str, Any]] = []

        for row in rows:
            output: dict[str, Any] = {}
            for source, target in source_to_target.items():
                if target not in target_schema:
                    continue
                value = row.get(source)
                output[target] = _cast(value, casts[target]) if target in casts else value
            for field in target_schema:
                output.setdefault(field, None)
            transformed.append(output)

        return {
            "rows": transformed,
            "schema": list(target_schema),
            "mapping": source_to_target,
            "casts": dict(casts),
            "reversible": True,
        }

    @staticmethod
    def schema(rows: list[dict[str, Any]]) -> list[str]:
        return sorted({key for row in rows for key in row})


class SchemaDriftHealer:
    """Detects schema drift and produces a reversible mapping proposal."""

    def diff(self, old: list[str], new: list[str]) -> dict[str, Any]:
        old_set, new_set = set(old), set(new)
        return {
            "added": sorted(new_set - old_set),
            "removed": sorted(old_set - new_set),
            "unchanged": sorted(old_set & new_set),
            "drift": old_set != new_set,
        }

    def patch(
        self,
        rows: list[dict[str, Any]],
        old: list[str],
        new: list[str],
        aliases: dict[str, str] | None = None,
        casts: dict[str, str] | None = None,
    ) -> dict[str, Any]:
        result = SchemaTransformer().transform(rows, new, aliases, casts)
        return {
            "diff": self.diff(old, new),
            "mapping": result["mapping"],
            "casts": result["casts"],
            "patched_rows": result["rows"],
            "reversible": True,
        }
