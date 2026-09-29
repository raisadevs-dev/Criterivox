"""Sandre-owned quality capability facade over shared S5 mechanisms."""
from __future__ import annotations
from typing import Any
from criterivox.execution.runtime import EvaluationGate
from .sklearn_backend import SklearnAnomalyBackend

class SandreQuality:
    def __init__(self) -> None:
        self.evaluation_gate=EvaluationGate()
        self.ml_anomaly=SklearnAnomalyBackend()
    def evaluation_gate_result(self, metrics: dict[str,float], datasets: list[dict[str,Any]], minimum: float=.85) -> dict[str,Any]:
        return self.evaluation_gate.evaluate(metrics,datasets,minimum)
    def train_anomaly_review(self, rows: list[dict[str,Any]], contamination: float=.05):
        return self.ml_anomaly.train(rows,contamination)
    def score_anomaly_review(self, trained, rows: list[dict[str,Any]]) -> dict[str,Any]:
        return self.ml_anomaly.score(trained,rows)

__all__=["SandreQuality"]
