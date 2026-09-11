from __future__ import annotations

from dataclasses import dataclass
from math import log1p
from typing import Any


@dataclass(frozen=True, slots=True)
class SandrePrediction:
    anomaly_score: float
    readiness_score: float
    signals: tuple[str, ...]
    model_version: str = "sandre-baseline-1"


class SandreMLAgent:
    """Small, local, dependency-light baseline for S5 stewardship.

    This first baseline deliberately uses interpretable statistical signals rather
    than hiding the gate behind an opaque model. A future adapter can replace the
    scorer with IsolationForest/gradient boosting after benchmark calibration.
    """

    def __init__(self, alert_threshold: float = 0.85) -> None:
        if not 0 < alert_threshold < 1:
            raise ValueError("alert_threshold must be between 0 and 1")
        self.alert_threshold = alert_threshold

    def predict(self, rows: list[dict[str, Any]]) -> SandrePrediction:
        if not rows:
            return SandrePrediction(1.0, 0.0, ("empty_dataset",))
        fields = sorted({key for row in rows for key in row})
        missing = sum(1 for row in rows for key in fields if row.get(key) in (None, ""))
        cells = max(1, len(rows) * max(1, len(fields)))
        missing_rate = missing / cells
        duplicate_rate = 1 - (len({self._stable_row(row) for row in rows}) / len(rows))
        schema_penalty = 0.0
        for row in rows:
            schema_penalty = max(schema_penalty, abs(len(row) - len(fields)) / max(1, len(fields)))
        anomaly = min(1.0, 0.55 * missing_rate + 0.35 * duplicate_rate + 0.10 * schema_penalty)
        readiness = max(0.0, 1.0 - anomaly)
        signals: list[str] = []
        if missing_rate > 0.05:
            signals.append("missingness")
        if duplicate_rate > 0:
            signals.append("duplicate_candidates")
        if schema_penalty > 0:
            signals.append("schema_inconsistency")
        if anomaly >= self.alert_threshold:
            signals.append("quarantine_review")
        return SandrePrediction(anomaly, readiness, tuple(signals))

    @staticmethod
    def _stable_row(row: dict[str, Any]) -> str:
        return "|".join(f"{key}={row[key]!r}" for key in sorted(row))

    @staticmethod
    def quality_features(rows: list[dict[str, Any]]) -> dict[str, float]:
        if not rows:
            return {"rows": 0.0, "fields": 0.0, "entropy_proxy": 0.0}
        fields = {k for row in rows for k in row}
        unique_rows = len({SandreMLAgent._stable_row(row) for row in rows})
        return {
            "rows": float(len(rows)),
            "fields": float(len(fields)),
            "entropy_proxy": log1p(unique_rows) / max(1.0, log1p(len(rows))),
        }
