"""Implementation-level S8 research support mechanisms.

These mechanisms create inspectable artifacts/records. They do not decide truth,
resolve contradictions automatically, or replace human authorization.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Mapping

from .models import Artifact, ArtifactKind


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


@dataclass(frozen=True)
class ExperimentRecord:
    experiment_id: str
    capability: str
    inputs: Mapping[str, Any]
    artifact_ids: tuple[str, ...]
    execution_receipt: Mapping[str, Any]
    created_at: datetime = field(default_factory=utc_now)


class TemporalRetriever:
    """Deterministic temporal retrieval over S8 temporal artifacts."""

    def retrieve(self, artifacts: Mapping[str, Artifact], *, subject: str, at: datetime | None = None) -> list[Artifact]:
        point = at or utc_now()
        matches: list[Artifact] = []
        for artifact in artifacts.values():
            if artifact.kind is not ArtifactKind.TEMPORAL or artifact.status == "invalidated":
                continue
            payload = artifact.payload
            if payload.get("subject") != subject:
                continue
            start = _parse(payload.get("valid_from"))
            end = _parse(payload.get("valid_to"))
            if start is not None and point < start:
                continue
            if end is not None and point >= end:
                continue
            matches.append(artifact)
        return sorted(matches, key=lambda item: item.created_at)


def _parse(value: Any) -> datetime | None:
    if not value:
        return None
    if isinstance(value, datetime):
        return value
    return datetime.fromisoformat(str(value))


class MemoryConsolidator:
    """Consolidates references without discarding epistemic metadata."""

    def consolidate(self, artifacts: Mapping[str, Artifact], *, artifact_ids: tuple[str, ...], tenant_id: str | None = None, context_id: str | None = None) -> Artifact:
        selected = [artifacts[item] for item in artifact_ids if item in artifacts]
        return Artifact(
            artifact_id=f"S8M-{len(selected):06d}-{int(utc_now().timestamp())}",
            kind=ArtifactKind.MEMORY,
            payload={
                "member_artifact_ids": tuple(a.artifact_id for a in selected),
                "retains_provenance": True,
                "retains_temporal_history": True,
                "retains_verification": True,
                "retains_integrity": True,
                "retains_uncertainty": True,
                "write_mode": "derived_reference_only",
            },
            source_ids=tuple(a.artifact_id for a in selected),
            tenant_id=tenant_id,
            context_id=context_id,
            status="consolidated",
        )


class EvaluationRecorder:
    """Records reproducibility and human-evaluation inputs as inspectable data."""

    def __init__(self) -> None:
        self.records: list[ExperimentRecord] = []

    def record(self, capability: str, inputs: Mapping[str, Any], artifact_ids: tuple[str, ...], *, execution_receipt: Mapping[str, Any]) -> ExperimentRecord:
        record = ExperimentRecord(
            experiment_id=f"S8X-{len(self.records) + 1:06d}",
            capability=capability,
            inputs=dict(inputs),
            artifact_ids=artifact_ids,
            execution_receipt=dict(execution_receipt),
        )
        self.records.append(record)
        return record
