from __future__ import annotations

from dataclasses import dataclass, field
from enum import IntEnum
from typing import Any, Mapping


class ContextTier(IntEnum):
    CRITICAL = 1
    HIGH = 2
    MEDIUM = 3
    LOW = 4


@dataclass(frozen=True, slots=True)
class ContextItem:
    key: str
    value: Any
    tier: ContextTier = ContextTier.MEDIUM
    critical: bool = False
    source_ids: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class ContextViolation:
    code: str
    message: str
    keys: tuple[str, ...] = ()
    blocked: bool = True


@dataclass(frozen=True, slots=True)
class ContextInput:
    request: str
    items: tuple[ContextItem, ...] = ()
    hard_constraints: tuple[str, ...] = ()
    soft_guidelines: tuple[str, ...] = ()
    environment: Mapping[str, Any] = field(default_factory=dict)
    scratchpad: Mapping[str, Any] = field(default_factory=dict)
    metadata: Mapping[str, Any] = field(default_factory=dict)


@dataclass(frozen=True, slots=True)
class ContextFrame:
    frame_id: str
    request: str
    items: tuple[ContextItem, ...]
    hard_constraints: tuple[str, ...]
    soft_guidelines: tuple[str, ...]
    environment: Mapping[str, Any]
    violations: tuple[ContextViolation, ...] = ()
    compression_ratio: float = 1.0
    original_item_count: int = 0
    tier_budget: Mapping[str, float] = field(default_factory=dict)


@dataclass(frozen=True, slots=True)
class ContextDiff:
    added: tuple[str, ...] = ()
    removed: tuple[str, ...] = ()
    changed: tuple[str, ...] = ()
    unchanged: tuple[str, ...] = ()
    goal_shift: bool = False
    constraint_shift: bool = False


@dataclass(frozen=True, slots=True)
class AdaptiveContextState:
    frame: ContextFrame
    diff: ContextDiff
    active_context: Mapping[str, Any]
    sandbox_states: Mapping[str, Mapping[str, Any]] = field(default_factory=dict)
    checkpoint_id: str | None = None
    state_version: int = 1


@dataclass(frozen=True, slots=True)
class ContextCheckpoint:
    checkpoint_id: str
    frame_id: str
    state_version: int
    active_context: Mapping[str, Any]
    scratchpad: Mapping[str, Any]


@dataclass(frozen=True, slots=True)
class ContextFork:
    fork_id: str
    base_checkpoint_id: str | None
    state: Mapping[str, Any]
