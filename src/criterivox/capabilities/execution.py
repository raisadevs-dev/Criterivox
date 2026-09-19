from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from typing import Iterable


class ExecutionPolicyError(PermissionError):
    pass


@dataclass(frozen=True, slots=True)
class PermissionBoundary:
    actor_id: str
    allowed_operations: frozenset[str] = frozenset({"inspect"})
    human_authorized: bool = False

    def require(self, operation: str) -> None:
        if operation not in self.allowed_operations:
            raise ExecutionPolicyError(f"Permission denied for operation: {operation}")
        if operation in {"execute", "mutate", "tool", "reevaluate"} and not self.human_authorized:
            raise ExecutionPolicyError("Explicit human authority is required for consequential execution.")


@dataclass(slots=True)
class ResourceBudget:
    max_cost: float = 100.0
    max_calls: int = 100
    max_tokens: int | None = None
    spent_cost: float = 0.0
    calls: int = 0
    tokens: int = 0

    def reserve(self, *, cost: float = 0.0, tokens: int = 0) -> None:
        if cost < 0 or tokens < 0:
            raise ValueError("Budget reservations cannot be negative.")
        if self.calls + 1 > self.max_calls or self.spent_cost + cost > self.max_cost:
            raise BudgetExceeded("BUDGET_CAP_REACHED")
        if self.max_tokens is not None and self.tokens + tokens > self.max_tokens:
            raise BudgetExceeded("BUDGET_CAP_REACHED")
        self.calls += 1
        self.spent_cost += cost
        self.tokens += tokens

    @property
    def exhausted(self) -> bool:
        return self.calls >= self.max_calls or self.spent_cost >= self.max_cost or (self.max_tokens is not None and self.tokens >= self.max_tokens)


class BudgetExceeded(RuntimeError):
    pass


@dataclass(frozen=True, slots=True)
class RetryPolicy:
    max_attempts: int = 3
    backoff_seconds: float = 0.0

    def __post_init__(self) -> None:
        if self.max_attempts < 1:
            raise ValueError("max_attempts must be at least one")
        if self.backoff_seconds < 0:
            raise ValueError("backoff_seconds cannot be negative")


@dataclass(slots=True)
class CircuitBreaker:
    failure_threshold: int = 3
    reset_after_seconds: float = 30.0
    failures: int = 0
    tripped_at: datetime | None = None

    def allow(self) -> bool:
        if self.tripped_at is None:
            return True
        if datetime.now(timezone.utc) - self.tripped_at >= timedelta(seconds=self.reset_after_seconds):
            self.reset()
            return True
        return False

    def record_success(self) -> None:
        self.failures = 0
        self.tripped_at = None

    def record_failure(self) -> None:
        self.failures += 1
        if self.failures >= self.failure_threshold:
            self.tripped_at = datetime.now(timezone.utc)

    def require_available(self) -> None:
        if not self.allow():
            raise CircuitTripped("CIRCUIT_TRIPPED")

    def reset(self) -> None:
        self.failures = 0
        self.tripped_at = None


class CircuitTripped(RuntimeError):
    pass


@dataclass(frozen=True, slots=True)
class ExecutionContext:
    execution_id: str
    actor_id: str
    correlation_id: str
    permission: PermissionBoundary
    budget: ResourceBudget = field(default_factory=ResourceBudget)
    metadata: dict[str, str] = field(default_factory=dict)


@dataclass(frozen=True, slots=True)
class ExecutionPolicy:
    permission: PermissionBoundary
    budget: ResourceBudget = field(default_factory=ResourceBudget)
    retry: RetryPolicy = field(default_factory=RetryPolicy)
    circuit_breaker: CircuitBreaker = field(default_factory=CircuitBreaker)
    max_hops: int = 32

    def validate_route(self, hops: Iterable[str]) -> None:
        seen: set[str] = set()
        count = 0
        for hop in hops:
            count += 1
            if count > self.max_hops or hop in seen:
                raise ExecutionPolicyError("Capability route loop or hop limit detected.")
            seen.add(hop)


__all__ = ["BudgetExceeded", "CircuitBreaker", "CircuitTripped", "ExecutionContext", "ExecutionPolicy", "ExecutionPolicyError", "PermissionBoundary", "ResourceBudget", "RetryPolicy"]
