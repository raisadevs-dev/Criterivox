from __future__ import annotations

from .attention_selection import AttentionCandidate


class AttentionActivation:
    """Controls how many relevant characters may demand attention."""

    @staticmethod
    def select(
        candidates: tuple[AttentionCandidate, ...],
    ) -> tuple[AttentionCandidate, ...]:
        """Select the highest-priority candidate for activation.

        Only one character is selected at a time. This prevents
        unnecessary simultaneous activation in the interface.
        """

        if not candidates:
            return ()

        highest_priority = max(
            candidate.priority
            for candidate in candidates
        )

        for candidate in candidates:
            if candidate.priority == highest_priority:
                return (candidate,)

        return ()