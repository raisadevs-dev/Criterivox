from __future__ import annotations

from typing import Any

from .home03_learning import TRAINING_REPORT, intent_model, ui_model


_RENDER_COMPONENTS = {
    "executive": ["summary", "tradeoffs"],
    "reasoning": ["reasoning_tree", "evidence"],
    "json": ["json"],
    "comparison": ["comparison_table", "tradeoffs"],
    "code": ["code_block", "validation"],
}


class AdaptiveIntentModel:
    """Model adapter used only for Syvax intent classification."""

    def __init__(self) -> None:
        self.name = "adaptive-intent-v1-trained"

    def predict(self, payload: dict[str, Any]) -> dict[str, Any]:
        prediction = intent_model.predict(str(payload.get("text", "")))
        return {
            **prediction,
            "model": self.name,
            "training_report": TRAINING_REPORT["intent"],
        }


class OutputRendererModel:
    """Model adapter used only after Syvax has accepted a task plan."""

    def __init__(self) -> None:
        self.name = "adaptive-renderer-v1-trained"

    def predict(self, payload: dict[str, Any]) -> dict[str, Any]:
        prediction = ui_model.predict(str(payload.get("text", "")))
        requested = str(payload.get("mode", "")).lower().strip()
        label = str(prediction.get("label", "executive"))
        mode = requested if requested in _RENDER_COMPONENTS else (
            label if label in _RENDER_COMPONENTS else "executive"
        )
        return {
            "mode": mode,
            "components": _RENDER_COMPONENTS[mode],
            "model": self.name,
            "confidence": prediction["confidence"],
            "scores": prediction["scores"],
            "training_report": TRAINING_REPORT["ui"],
        }


class UIIntentModel:
    """Maps the already-classified Syvax intent to a presentation contract."""

    def __init__(self) -> None:
        self.name = "ui-intent-v1-trained"

    def predict(self, payload: dict[str, Any]) -> dict[str, Any]:
        text = str(payload.get("text", payload.get("intent", "")))
        intent = str(payload.get("intent", "general"))
        prediction = ui_model.predict(text)
        mapping = {
            "compare": (["comparison_table", "parameter_slider"], True),
            "decide": (["tradeoff_matrix", "approval_card"], True),
            "analyze": (["reasoning_tree", "evidence_card"], True),
            "explain": (["reasoning_tree", "provenance_card"], False),
            "build": (["code_editor", "validation_card"], True),
        }
        components, interactive = mapping.get(
            intent,
            ([prediction["label"]], False),
        )
        return {
            "components": components,
            "interactive": interactive,
            "model": self.name,
            "confidence": prediction["confidence"],
            "scores": prediction["scores"],
        }


adaptive_intent_model = AdaptiveIntentModel()
output_renderer_model = OutputRendererModel()
ui_intent_model = UIIntentModel()
