from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import json
from typing import Any, Iterable, Mapping

try:
    import joblib
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.linear_model import LogisticRegression
    from sklearn.pipeline import Pipeline
    from sklearn.metrics import accuracy_score, f1_score
except ImportError:
    joblib = None
    TfidfVectorizer = LogisticRegression = Pipeline = None
    accuracy_score = f1_score = None


@dataclass(frozen=True)
class ModelMetrics:
    accuracy: float
    macro_f1: float
    examples: int


class LearnedContextModel:
    def __init__(self, model_path: str | Path | None = None) -> None:
        self.model_path = Path(model_path) if model_path else None
        self.model = None

    @property
    def available(self) -> bool:
        return self.model is not None

    def load(self) -> bool:
        if joblib is None or self.model_path is None or not self.model_path.exists(): return False
        self.model = joblib.load(self.model_path); return True

    def predict(self, texts: Iterable[str]) -> list[str]:
        if self.model is None: return []
        return [str(value) for value in self.model.predict(list(texts))]


class DharenLearnedModel(LearnedContextModel):
    """Learned scope/tier classifier. Rule-based firewall remains authoritative."""
    labels = ("critical", "high", "medium", "low")


class AnukaLearnedModel(LearnedContextModel):
    """Learned adaptation-trigger classifier. State gates remain deterministic."""
    labels = ("stable", "requirements_changed", "evidence_changed", "constraint_changed", "drift_detected", "counterfactual_requested")


def train_text_model(texts: list[str], labels: list[str], output_path: str | Path) -> ModelMetrics:
    if Pipeline is None or joblib is None: raise RuntimeError("Install the optional ML dependencies before training.")
    model = Pipeline([("tfidf", TfidfVectorizer(ngram_range=(1, 2), min_df=1, sublinear_tf=True)), ("classifier", LogisticRegression(max_iter=1200, class_weight="balanced"))])
    model.fit(texts, labels)
    predictions = model.predict(texts)
    metrics = ModelMetrics(float(accuracy_score(labels, predictions)), float(f1_score(labels, predictions, average="macro")), len(texts))
    output = Path(output_path); output.parent.mkdir(parents=True, exist_ok=True); joblib.dump(model, output)
    return metrics


def evaluate_text_model(model_path: str | Path, texts: list[str], labels: list[str]) -> ModelMetrics:
    if joblib is None or accuracy_score is None: raise RuntimeError("Install the optional ML dependencies before evaluation.")
    model = joblib.load(model_path); predictions = model.predict(texts)
    return ModelMetrics(float(accuracy_score(labels, predictions)), float(f1_score(labels, predictions, average="macro")), len(labels))


def save_training_report(path: str | Path, *, model: str, metrics: Mapping[str, Any], datasets: list[Mapping[str, Any]], split: Mapping[str, Any]) -> None:
    payload = {"model": model, "metrics": dict(metrics), "datasets": datasets, "split": dict(split)}
    Path(path).parent.mkdir(parents=True, exist_ok=True); Path(path).write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")


__all__ = ["DharenLearnedModel", "AnukaLearnedModel", "LearnedContextModel", "ModelMetrics", "train_text_model", "evaluate_text_model", "save_training_report"]
