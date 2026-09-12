from __future__ import annotations

from typing import Any, Mapping

from .models import AdaptiveContextState, ContextCheckpoint, ContextFork, ContextFrame, ContextInput
from criterivox.ml.anuka import AnukaMLAgent
from criterivox.ml.dharen import DharenMLAgent


class ContextIntelligenceEngine:
    """S6 computational control plane with learned Dharen/Anuka by default."""

    def __init__(self, dharen: DharenMLAgent | None = None, anuka: AnukaMLAgent | None = None) -> None:
        self.dharen = dharen or DharenMLAgent()
        self.anuka = anuka or AnukaMLAgent(model_registry=self.dharen.model_registry)
        self.model_registry = self.dharen.model_registry

    def build(self, context: ContextInput, *, previous: AdaptiveContextState | ContextFrame | None = None, anuka_triggers: Mapping[str, bool] | None = None, manual_activation: bool = False) -> AdaptiveContextState:
        frame = self.dharen.frame(context)
        previous_state = previous if isinstance(previous, AdaptiveContextState) else None
        previous_frame = previous_state.frame if previous_state else previous
        triggers = dict(anuka_triggers or {})
        triggers.setdefault("new_context", True)
        if not self.anuka.should_activate(triggers, manual_activation=manual_activation):
            current = {item.key: item.value for item in frame.items}
            return AdaptiveContextState(frame=frame, diff=self.anuka.diff({}, current), active_context=current, state_version=1)
        return self.anuka.adapt(previous_frame, frame, previous_state=previous_state)

    def checkpoint(self, state: AdaptiveContextState, scratchpad: Mapping[str, Any] | None = None) -> AdaptiveContextState:
        checkpoint = self.anuka.checkpoint(state, scratchpad or {})
        return AdaptiveContextState(frame=state.frame, diff=state.diff, active_context=state.active_context, sandbox_states=state.sandbox_states, checkpoint_id=checkpoint.checkpoint_id, state_version=state.state_version)

    def fork(self, state: AdaptiveContextState, fork_id: str, overrides: Mapping[str, Any]) -> ContextFork:
        return self.anuka.fork(state, fork_id, overrides)

    def learned_model_status(self) -> dict[str, Any]:
        return self.model_registry.status()


__all__ = ["ContextIntelligenceEngine"]
