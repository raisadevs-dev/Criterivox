from __future__ import annotations

from hashlib import sha256
from typing import Any

from criterivox.context.models import (
    ContextFrame,
    ContextInput,
    ContextItem,
    ContextTier,
    ContextViolation,
)
from criterivox.context.token_budget import DynamicTokenAllocator


class DharenAgent:
    """Context Master: baseline framing, scope, hierarchy, compression and firewall."""

    agent_id = "dharen"
    role = "Context Master / Scope Boundary Control"

    def __init__(
        self,
        allocator: DynamicTokenAllocator | None = None,
    ) -> None:
        self.allocator = allocator or DynamicTokenAllocator()

    def frame(
        self,
        context: ContextInput,
        *,
        max_items: int = 64,
    ) -> ContextFrame:
        request = context.request.strip()

        if not request:
            raise ValueError("Context request cannot be empty.")

        violations = self._firewall(context)

        rejected = {
            key
            for violation in violations
            if violation.blocked
            for key in violation.keys
        }

        accepted = tuple(
            item
            for item in context.items
            if item.key not in rejected
        )

        ranked = sorted(
            accepted,
            key=lambda item: (
                item.critical,
                -int(item.tier),
                bool(item.source_ids),
            ),
            reverse=True,
        )

        kept = tuple(ranked[:max_items])

        if not kept:
            kept = (
                ContextItem(
                    "request",
                    request,
                    ContextTier.CRITICAL,
                    True,
                ),
            )

        budget = int(
            context.environment.get(
                "context_token_budget",
                4096,
            )
            or 4096
        )

        allocation = self.allocator.allocate(
            kept,
            budget,
        )

        selected_keys = set(allocation.selected_keys)

        selected = tuple(
            item
            for item in kept
            if item.key in selected_keys or item.critical
        )

        if not selected:
            selected = kept[:1]

        # The S6 contract defines the context-tier budget distribution
        # independently from the number of tokens consumed by the current
        # frame. Keeping this distribution deterministic prevents the runtime
        # frame from reporting an accidental, input-dependent allocation
        # instead of the declared tier contract.
        tier_budget = {
            "critical": 0.40,
            "high": 0.30,
            "medium": 0.20,
            "low": 0.10,
        }

        return ContextFrame(
            frame_id=self._id(
                request,
                [item.key for item in selected],
            ),
            request=request,
            items=selected,
            hard_constraints=tuple(
                dict.fromkeys(context.hard_constraints)
            ),
            soft_guidelines=tuple(
                dict.fromkeys(context.soft_guidelines)
            ),
            environment={
                **dict(context.environment),
                "context_token_budget": budget,
                "context_tokens_used": allocation.used,
                "context_tokens_remaining": allocation.remaining,
                "context_dropped_keys": allocation.dropped_keys,
            },
            violations=tuple(violations),
            compression_ratio=(
                len(selected)
                / max(1, len(context.items))
            ),
            original_item_count=len(context.items),
            tier_budget=tier_budget,
        )

    def _firewall(
        self,
        context: ContextInput,
    ) -> tuple[ContextViolation, ...]:
        violations: list[ContextViolation] = []
        seen: dict[str, Any] = {}

        for item in context.items:
            if (
                item.key in seen
                and seen[item.key] != item.value
            ):
                violations.append(
                    ContextViolation(
                        "CONTEXT_CLASH",
                        f"Conflicting values for {item.key}.",
                        (item.key,),
                    )
                )

            seen[item.key] = item.value

        injection_markers = (
            "ignore previous instructions",
            "override system",
            "disregard prior instructions",
            "bypass safety",
        )

        for item in context.items:
            text = str(item.value).lower()

            if any(
                marker in text
                for marker in injection_markers
            ):
                violations.append(
                    ContextViolation(
                        "CONTEXT_POISONING",
                        (
                            "Prompt-injection pattern detected "
                            f"in {item.key}."
                        ),
                        (item.key,),
                    )
                )

        return tuple(violations)

    @staticmethod
    def _id(
        request: str,
        keys: list[str],
    ) -> str:
        return (
            "CTXF-"
            + sha256(
                (
                    request
                    + "|"
                    + "|".join(keys)
                ).encode()
            ).hexdigest()[:16]
        )

