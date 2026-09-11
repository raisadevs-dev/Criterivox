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
    """Local, interpretable S5 ML baseline with an in-app train/predict lifecycle."""

    def __init__(self, alert_threshold: float = 0.85) -> None:
        if not 0 < alert_threshold < 1:
            raise ValueError("alert_threshold must be between 0 and 1")
        self.alert_threshold = alert_threshold
        self._baseline: dict[str, float] | None = None

    def train(self, clean_rows: list[dict[str, Any]]) -> dict[str, float]:
        if not clean_rows:
            raise ValueError("clean_rows must not be empty")
        self._baseline = self.quality_features(clean_rows)
        return dict(self._baseline)

    @property
    def is_trained(self) -> bool:
        return self._baseline is not None

    def predict(self, rows: list[dict[str, Any]]) -> SandrePrediction:
        if not rows:
            return SandrePrediction(1.0, 0.0, ("empty_dataset",))
        fields = sorted({key for row in rows for key in row})
        missing = sum(1 for row in rows for key in fields if row.get(key) in (None, ""))
        cells = max(1, len(rows) * max(1, len(fields)))
        missing_rate = missing / cells
        duplicate_rate = 1 - (len({self._stable_row(row) for row in rows}) / len(rows))
        schema_penalty = max((abs(len(row) - len(fields)) / max(1, len(fields)) for row in rows), default=0.0)
        current = self.quality_features(rows)
        scale_penalty = 0.0
        if self._baseline is not None:
            expected_fields = max(1.0, self._baseline["fields"])
            scale_penalty = min(1.0, abs(current["fields"] - expected_fields) / expected_fields)
        anomaly = min(1.0, 0.45 * missing_rate + 0.30 * duplicate_rate + 0.15 * schema_penalty + 0.10 * scale_penalty)
        readiness = max(0.0, 1.0 - anomaly)
        signals: list[str] = []
        if missing_rate > 0.05:
            signals.append("missingness")
        if duplicate_rate > 0:
            signals.append("duplicate_candidates")
        if schema_penalty > 0 or scale_penalty > 0:
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
        return {"rows": float(len(rows),), "fields": float(len(fields)), "entropy_proxy": log1p(unique_rows) / max(1.0, log1p(len(rows)))}
