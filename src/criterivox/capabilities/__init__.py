"""Reusable S9 capability and pipeline contracts.

The package is presentation-agnostic. Characters and Homes consume its state,
but never own computation. Existing S7/S8 artifacts/events remain the durable
record through the repository adapter in :mod:`adapters`.
"""
from .core import (
    Capability,
    CapabilityDescriptor,
    CapabilityRegistry,
    CapabilityRequest,
    CapabilityResult,
    PipelineContext,
    PipelineDefinition,
    PipelineExecutor,
    PipelineResult,
    PipelineStep,
    DomainEvent,
    EventBus,
    ArtifactRepository,
    ExecutionAudit,
)
from .execution import ExecutionContext, ExecutionPolicy, PermissionBoundary, ResourceBudget, CircuitBreaker, RetryPolicy
from .human import HumanChallenge, HumanAuthority, HumanChallengeState
from .adapters import S8ArtifactRepository

__all__ = [
    "ArtifactRepository", "Capability", "CapabilityDescriptor", "CapabilityRegistry",
    "CapabilityRequest", "CapabilityResult", "CircuitBreaker", "DomainEvent", "EventBus",
    "ExecutionAudit", "ExecutionContext", "ExecutionPolicy", "HumanAuthority",
    "HumanChallenge", "HumanChallengeState", "PermissionBoundary", "PipelineContext",
    "PipelineDefinition", "PipelineExecutor", "PipelineResult", "PipelineStep",
    "ResourceBudget", "RetryPolicy", "S8ArtifactRepository",
]
