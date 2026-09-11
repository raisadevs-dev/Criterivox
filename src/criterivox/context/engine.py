from __future__ import annotations

from typing import Any, Mapping

from .agents import AnukaAgent, DharenAgent
from .models import AdaptiveContextState, ContextCheckpoint, ContextFork, ContextFrame, ContextInput


class ContextIntelligenceEngine:
    """Coordinates the S6 Context Master and Context Adaptor agents.

    Dharen establishes the validated contextual boundary. Anuka continuously
    evaluates whether that boundary remains appropriate as state changes.
    """

    def __init__(self, dharen: DharenAgent | None = None, anuka: AnukaAgent | None = None) -> None:
        self.dharen = dharen or DharenAgent()
        self.anuka = anuka or AnukaAgent()

    def build(self, context: ContextInput, *, previous: ContextFrame | None = None) -> AdaptiveContextState:
        frame = self.dharen.frame(context)
        return self.anuka.adapt(previous, frame)

    def checkpoint(self, state: AdaptiveContextState, scratchpad: Mapping[str, Any] | None = None) -> ContextCheckpoint:
        checkpoint = self.anuka.checkpoint(state, scratchpad or {})
        return AdaptiveContextState(
            frame=state.frame,
            diff=state.diff,
            active_context=state.active_context,
            sandbox_states=state.sandbox_states,
            checkpoint_id=checkpoint.checkpoint_id,
            state_version=state.state_version,
        )

    def fork(self, state: AdaptiveContextState, fork_id: str, overrides: Mapping[str, Any]) -> ContextFork:
        return self.anuka.fork(state, fork_id, overrides)


__all__ = ["ContextIntelligenceEngine"]
