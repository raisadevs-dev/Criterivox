"""Reusable domain capability contracts for S5/S6/S7/S8 consumers.

These are intentionally deterministic contract-level primitives. They do not
claim to provide an ML model where the repository has not established one.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Mapping


class ReadinessDecision(str, Enum):
    READY = "READY"
    BLOCKED = "BLOCKED"
    UNKNOWN = "UNKNOWN"


@dataclass(frozen=True, slots=True)
class DataProfile:
    dataset_id: str
    row_count: int
    field_count: int
    missing_fields: tuple[str, ...] = ()
    semantic_tags: tuple[str, ...] = ()
    vector_ready: bool = False
    multimodal_ready: bool = False


@dataclass(frozen=True, slots=True)
class SchemaContract:
    schema_id: str
    version: str
    required_fields: tuple[str, ...] = ()
    optional_fields: tuple[str, ...] = ()

    def validate(self, record: Mapping[str, Any]) -> tuple[str, ...]:
        return tuple(field for field in self.required_fields if field not in record)


@dataclass(frozen=True, slots=True)
class SchemaDriftReport:
    schema_id: str
    added: tuple[str, ...] = ()
    removed: tuple[str, ...] = ()
    changed: tuple[str, ...] = ()

    @property
    def drifted(self) -> bool:
        return bool(self.added or self.removed or self.changed)


@dataclass(frozen=True, slots=True)
class DataQualityGate:
    minimum_quality: float = 0.0
    anomaly_count: int = 0
    quality_score: float = 1.0

    def decision(self) -> ReadinessDecision:
        if self.quality_score < self.minimum_quality:
            return ReadinessDecision.BLOCKED
        return ReadinessDecision.READY


@dataclass(frozen=True, slots=True)
class DataReadinessDecision:
    decision: ReadinessDecision
    reasons: tuple[str, ...] = ()
    profile_id: str | None = None


@dataclass(frozen=True, slots=True)
class ContextFrame:
    context_id: str
    scope: str
    values: Mapping[str, Any] = field(default_factory=dict)
    priority: int = 0
    parent_context_id: str | None = None


@dataclass(frozen=True, slots=True)
class ContextDiff:
    context_id: str
    added: Mapping[str, Any] = field(default_factory=dict)
    removed: tuple[str, ...] = ()
    changed: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True, slots=True)
class ContextCheckpoint:
    checkpoint_id: str
    context_id: str
    sequence: int
    state: Mapping[str, Any]


@dataclass(frozen=True, slots=True)
class KnowledgeVersion:
    knowledge_id: str
    version: str
    parents: tuple[str, ...] = ()
    schema_version: str = "1"
    status: str = "active"


@dataclass(frozen=True, slots=True)
class SkillMetadata:
    skill_id: str
    version: str
    taxonomy_path: tuple[str, ...] = ()
    constraints: tuple[str, ...] = ()
    status: str = "active"


@dataclass(frozen=True, slots=True)
class MigrationContract:
    migration_id: str
    from_version: str
    to_version: str
    reversible: bool = False
    notes: str = ""


@dataclass(frozen=True, slots=True)
class DecisionRationale:
    decision_id: str
    alternatives: tuple[str, ...]
    tradeoffs: Mapping[str, Any] = field(default_factory=dict)
    evidence_ids: tuple[str, ...] = ()
    limitations: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class ActionVector:
    action_id: str
    operation: str
    parameters: Mapping[str, Any] = field(default_factory=dict)
    preconditions: tuple[str, ...] = ()
    required_permissions: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class ExecutionTreeNode:
    node_id: str
    action_id: str
    on_success: str | None = None
    on_failure: str | None = None
    contingency: str | None = None


__all__ = ["ActionVector", "ContextCheckpoint", "ContextDiff", "ContextFrame", "DataProfile", "DataQualityGate", "DataReadinessDecision", "DecisionRationale", "ExecutionTreeNode", "KnowledgeVersion", "MigrationContract", "ReadinessDecision", "SchemaContract", "SchemaDriftReport", "SkillMetadata"]
