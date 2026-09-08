from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class ExecutionTier(str, Enum):
    LOCAL = "LOCAL"
    FREE = "FREE"
    PRIMARY = "PRIMARY"


@dataclass(frozen=True, slots=True)
class ExecutionRoute:
    engine: str
    tier: ExecutionTier
    fallback: bool


class ExecutionRouter:
    """Selects a truthful execution path without forcing paid model usage.

    S4 deliberately treats the deterministic local runtime as the free fallback.
    Provider-backed models can be added later without changing task contracts.
    """

    PRIMARY = ExecutionRoute("Primary Agent", ExecutionTier.PRIMARY, False)
    LOCAL = ExecutionRoute("Local Deterministic Runtime", ExecutionTier.LOCAL, False)
    FREE_FALLBACK = ExecutionRoute("Free-Tier Background Agent", ExecutionTier.FREE, True)

    def route(self, *, critical: bool, finalized: bool, provider_available: bool = False) -> ExecutionRoute:
        if critical and finalized and provider_available:
            return self.PRIMARY
        if provider_available and finalized:
            return self.PRIMARY
        return self.LOCAL

    def fallback(self) -> ExecutionRoute:
        return self.FREE_FALLBACK


execution_router = ExecutionRouter()
