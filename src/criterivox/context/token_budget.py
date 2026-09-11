from __future__ import annotations

from dataclasses import dataclass
from typing import Mapping

from .models import ContextItem, ContextTier


@dataclass(frozen=True)
class TokenAllocation:
    budget: int
    used: int
    remaining: int
    by_tier: Mapping[str, int]
    selected_keys: tuple[str, ...]
    dropped_keys: tuple[str, ...]


class DynamicTokenAllocator:
    """Deterministic budget allocator using tier, criticality and item cost."""

    def __init__(self, minimum_per_tier: int = 0) -> None:
        self.minimum_per_tier = minimum_per_tier

    @staticmethod
    def estimate_tokens(value: object) -> int:
        text = str(value)
        return max(1, (len(text) + 3) // 4)

    def allocate(self, items: tuple[ContextItem, ...], budget: int) -> TokenAllocation:
        if budget < 1:
            raise ValueError("Context token budget must be positive.")
        weights = {ContextTier.CRITICAL: 0.50, ContextTier.HIGH: 0.25, ContextTier.MEDIUM: 0.15, ContextTier.LOW: 0.10}
        groups: dict[ContextTier, list[ContextItem]] = {tier: [] for tier in ContextTier}
        for item in items:
            groups[item.tier].append(item)
        limits = {tier: int(budget * weight) for tier, weight in weights.items()}
        limits[ContextTier.CRITICAL] += budget - sum(limits.values())
        selected: list[str] = []
        dropped: list[str] = []
        by_tier: dict[str, int] = {}
        used = 0
        for tier in ContextTier:
            tier_used = 0
            for item in sorted(groups[tier], key=lambda x: (not x.critical, x.key)):
                cost = self.estimate_tokens(item.value)
                if item.critical or tier_used + cost <= limits[tier]:
                    if used + cost <= budget:
                        selected.append(item.key); tier_used += cost; used += cost
                    else:
                        dropped.append(item.key)
                else:
                    dropped.append(item.key)
            by_tier[tier.name.lower()] = tier_used
        return TokenAllocation(budget, used, budget - used, by_tier, tuple(selected), tuple(dropped))


__all__ = ["DynamicTokenAllocator", "TokenAllocation"]
