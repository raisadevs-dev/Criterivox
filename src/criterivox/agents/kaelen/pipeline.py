from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from .schema import SchemaDriftHealer, SchemaTransformer


@dataclass(frozen=True, slots=True)
class PipelineStep:
    name: str
    action: str
    inputs: tuple[str, ...] = ()
    outputs: tuple[str, ...] = ()


class KaelenPipeline:
    """Declarative pipeline DAG for normalization, repair and handoff preparation."""

    def __init__(self) -> None:
        self.steps = (
            PipelineStep("ingest", "load", (), ("raw",)),
            PipelineStep("profile", "profile", ("raw",), ("profile",)),
            PipelineStep("validate", "quality_gate", ("raw", "profile"), ("validated",)),
            PipelineStep("normalize", "normalize", ("validated",), ("normalized",)),
            PipelineStep("patch", "schema_patch", ("normalized",), ("canonical",)),
            PipelineStep("handoff", "package", ("canonical", "profile"), ("handoff",)),
        )
        self.healer = SchemaDriftHealer()
        self.transformer = SchemaTransformer()

    def dag(self) -> dict[str, Any]:
        return {
            "nodes": [step.name for step in self.steps],
            "edges": [[a.name, b.name] for a, b in zip(self.steps, self.steps[1:])],
            "steps": [
                {
                    "name": step.name,
                    "action": step.action,
                    "inputs": list(step.inputs),
                    "outputs": list(step.outputs),
                }
                for step in self.steps
            ],
        }

    def execute(
        self,
        data: list[dict[str, Any]],
        *,
        expected_schema: list[str] | None = None,
        aliases: dict[str, str] | None = None,
        casts: dict[str, str] | None = None,
    ) -> dict[str, Any]:
        old_schema = self.transformer.schema(data)
        target_schema = expected_schema or old_schema
        patched = self.healer.patch(
            data, old_schema, target_schema, aliases=aliases, casts=casts
        )
        canonical = patched["patched_rows"]
        return {
            "status": "ready",
            "rows": len(canonical),
            "schema": target_schema,
            "canonical_data": canonical,
            "schema_patch": patched,
            "dag": self.dag(),
        }

    def handoff_package(self, data: list[dict[str, Any]], **kwargs: Any) -> dict[str, Any]:
        result = self.execute(data, **kwargs)
        return {
            "kind": "kaelen.normalized_pipeline_handoff",
            "status": result["status"],
            "schema": result["schema"],
            "rows": result["rows"],
            "data": result["canonical_data"],
            "dag": result["dag"],
            "transformation": result["schema_patch"],
        }
