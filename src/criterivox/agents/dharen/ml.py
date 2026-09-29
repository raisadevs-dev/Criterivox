"""Dharen learned context-ranking facade."""

from criterivox.context.ml import S6LearnedModelRegistry
from criterivox.context.models import ContextFrame, ContextInput
from .agent import DharenAgent


class DharenMLAgent(DharenAgent):
    """Dharen with learned tier ranking fused into deterministic context safety."""

    model_version = "dharen-context-learned-1"

    def __init__(self, *args, model_registry: S6LearnedModelRegistry | None = None, **kwargs):
        super().__init__(*args, **kwargs)
        self.model_registry = model_registry or S6LearnedModelRegistry()
        self.learned_model = self.model_registry.dharen
        self.learned_model.load()

    @property
    def is_ready(self) -> bool:
        return True

    @property
    def learned_model_available(self) -> bool:
        return self.learned_model.available

    def frame(self, context: ContextInput, *, max_items: int = 64) -> ContextFrame:
        base = super().frame(context, max_items=max_items)
        if not self.learned_model.available:
            return base
        predictions = {}
        for item in base.items:
            prediction = self.learned_model.predict_one(
                f"key={item.key}; value={item.value}; deterministic_tier={item.tier.name.lower()}"
            )
            if prediction:
                predictions[item.key] = prediction
        order = {"critical": 1, "high": 2, "medium": 3, "low": 4}
        def score(item):
            prediction = predictions.get(item.key)
            return (
                item.critical,
                -(prediction.confidence if prediction else 0.0),
                -order.get(prediction.label if prediction else "low", 4),
            )
        items = tuple(sorted(base.items, key=score, reverse=True))
        environment = {
            **dict(base.environment),
            "ml": {
                "agent": "dharen",
                "model_version": self.learned_model.model_version,
                "available": True,
                "predictions": {
                    key: {"label": p.label, "confidence": p.confidence}
                    for key, p in predictions.items()
                },
            },
        }
        return ContextFrame(
            base.frame_id, base.request, items, base.hard_constraints,
            base.soft_guidelines, environment, base.violations,
            base.compression_ratio, base.original_item_count, base.tier_budget,
        )
