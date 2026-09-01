from __future__ import annotations

from dataclasses import dataclass

from criterivox.application.bloom_integration import (
    BloomCapability,
)


@dataclass(frozen=True, slots=True)
class ContextualCapability:
    """A Bloom capability made available for the current context."""

    capability: BloomCapability
    reason: str


class ContextualCapabilityProvider:
    """Provides relevant Bloom capabilities without owning UI behavior."""

    def get_capabilities(
        self,
        *,
        context: dict[str, object] | None = None,
    ) -> tuple[ContextualCapability, ...]:
        """Return capabilities relevant to the supplied context."""

        context = context or {}

        capabilities: list[ContextualCapability] = []

        capabilities.append(
            ContextualCapability(
                capability=BloomCapability.ANALYZE,
                reason="Analysis is available for the current task.",
            )
        )

        if context.get("comparison_available") is True:
            capabilities.append(
                ContextualCapability(
                    capability=BloomCapability.COMPARE,
                    reason="Comparable information is available.",
                )
            )

        if context.get("exploration_available") is True:
            capabilities.append(
                ContextualCapability(
                    capability=BloomCapability.EXPLORE,
                    reason="Additional exploration is relevant.",
                )
            )

        if context.get("planning_available") is True:
            capabilities.append(
                ContextualCapability(
                    capability=BloomCapability.PLAN,
                    reason="Planning is relevant to the current context.",
                )
            )

        if context.get("insights_available") is True:
            capabilities.append(
                ContextualCapability(
                    capability=BloomCapability.INSIGHTS,
                    reason="Insights are available from existing analysis.",
                )
            )

        if context.get("explanation_available") is True:
            capabilities.append(
                ContextualCapability(
                    capability=BloomCapability.EXPLAIN,
                    reason="An explanation can be requested.",
                )
            )

        return tuple(capabilities)