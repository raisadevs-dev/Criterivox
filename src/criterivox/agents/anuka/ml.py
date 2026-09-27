"""Anuka learned adaptation facade."""

from criterivox.context.ml import S6LearnedModelRegistry
from .agent import AnukaAgent


class AnukaMLAgent(AnukaAgent):
    """Anuka with learned adaptation classification fused with deterministic gates."""

    model_version = "anuka-adaptation-learned-1"

    def __init__(self, *args, model_registry=None, **kwargs):
        super().__init__(*args, **kwargs)
        self.model_registry = model_registry or S6LearnedModelRegistry()
        self.learned_model = self.model_registry.anuka
        self.learned_model.load()

    @property
    def is_ready(self):
        return True

    @property
    def learned_model_available(self):
        return self.learned_model.available

    def adapt(self, previous, current, *, previous_state=None):
        state = super().adapt(previous, current, previous_state=previous_state)
        if not self.learned_model.available:
            return state

        prompt = (
            f"request={current.request}; "
            f"added={state.diff.added}; removed={state.diff.removed}; "
            f"changed={state.diff.changed}; "
            f"goal_shift={state.diff.goal_shift}; "
            f"constraint_shift={state.diff.constraint_shift}"
        )
        prediction = self.learned_model.predict_one(prompt)
        if not prediction:
            return state

        active = dict(state.active_context)
        active["_ml"] = {
            "agent": "anuka",
            "model_version": prediction.model_version,
            "label": prediction.label,
            "confidence": prediction.confidence,
        }
        from criterivox.context.models import AdaptiveContextState
        return AdaptiveContextState(
            frame=state.frame,
            diff=state.diff,
            active_context=active,
            sandbox_states=state.sandbox_states,
            checkpoint_id=state.checkpoint_id,
            state_version=state.state_version,
        )
