"""Deterministic S5 Home 01 feature services.

These services intentionally stay local, explainable, and lightweight. They provide
an executable baseline for Sandre/Kaelen feature surfaces without introducing a
vector database or remote model dependency.
"""
from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
import hashlib
import json
import random
from typing import Any


@dataclass(frozen=True)
class ReadinessSnapshot:
    completeness: float
    schema_alignment: float
    anomaly_score: float
    readiness: float
    decision: str


class S5FeatureRuntime:
    """Computes auditable Home 01 signals and safe local previews."""

    provisional_alert_threshold = 0.85

    def readiness(self, foundation: Any) -> ReadinessSnapshot:
        profile = foundation.profile
        completeness = max(0.0, min(1.0, 1.0 - float(getattr(profile, "missingness_rate", 0.0))))
        duplicate_rate = float(getattr(profile, "duplicate_rate", 0.0))
        schema_alignment = 1.0
        if foundation.sources and getattr(profile, "column_count", 0) == 0:
            schema_alignment = 0.0
        anomaly_score = max(0.0, min(1.0, float(len(foundation.anomalies)) / max(1, len(foundation.candidates))))
        readiness = max(0.0, min(1.0, completeness * 0.45 + schema_alignment * 0.35 + (1.0 - anomaly_score) * 0.20 - duplicate_rate * 0.10))
        decision = "READY" if readiness >= self.provisional_alert_threshold else "REVIEW"
        return ReadinessSnapshot(completeness, schema_alignment, anomaly_score, readiness, decision)

    def provenance(self, foundation: Any) -> dict[str, Any]:
        payload = json.dumps(foundation.raw_data, sort_keys=True, default=str).encode()
        return {
            "payload_hash": hashlib.sha256(payload).hexdigest(),
            "captured_at": datetime.now(timezone.utc).isoformat(),
            "source_count": len(foundation.sources),
            "transformation_count": len(foundation.transformations),
            "timeline_supported": True,
        }

    def synthetic_preview(self, foundation: Any, seed: int = 17) -> dict[str, Any]:
        rng = random.Random(seed)
        rows = foundation.canonical_data if isinstance(foundation.canonical_data, list) else []
        preview = []
        for row in rows[:5]:
            if isinstance(row, dict):
                clone = dict(row)
                if clone:
                    key = next(iter(clone))
                    value = clone[key]
                    if isinstance(value, (int, float)):
                        clone[key] = value + rng.randint(-2, 2)
                preview.append(clone)
        return {"mode": "local-synthetic", "seed": seed, "rows": preview, "training_consent": False}

    def semantic(self, foundation: Any) -> dict[str, Any]:
        fields: list[str] = []
        for row in foundation.canonical_data[:20] if isinstance(foundation.canonical_data, list) else []:
            if isinstance(row, dict):
                fields.extend(str(k) for k in row.keys())
        unique = sorted(set(fields))
        score = min(1.0, 0.55 + min(len(unique), 10) * 0.035) if unique else 0.20
        return {"agent_readability_score": round(score, 3), "semantic_tags": unique[:12], "active_metadata": True}

    def schema_patch(self, foundation: Any) -> dict[str, Any]:
        keys: set[str] = set()
        for row in foundation.canonical_data[:50] if isinstance(foundation.canonical_data, list) else []:
            if isinstance(row, dict):
                keys.update(str(k) for k in row.keys())
        return {
            "drift_detected": len(keys) == 0 and bool(foundation.candidates),
            "old_schema": sorted(keys),
            "new_schema": sorted(keys),
            "patch_strategy": "declarative-map-and-validate",
            "rollback": True,
        }

    def vector_readiness(self, foundation: Any) -> dict[str, Any]:
        return {
            "stage": "embedding-ready-representation",
            "text": bool(foundation.canonical_data),
            "image": False,
            "audio": False,
            "matrix_preview": [[0.0, 0.0, 0.0] for _ in range(min(3, len(foundation.candidates)))],
            "lakehouse": "deferred-by-S5-scope",
        }

    def edd_gate(self, foundation: Any) -> dict[str, Any]:
        readiness = self.readiness(foundation)
        checks = {
            "completeness": readiness.completeness >= 0.70,
            "schema_alignment": readiness.schema_alignment >= 0.70,
            "anomaly_review": readiness.anomaly_score < 0.30,
            "provenance": bool(foundation.sources),
            "confirmation": foundation.confirmation_status.value in {"user-confirmed", "user-corrected"},
        }
        passed = sum(checks.values())
        return {"status": "PASS" if passed == len(checks) else "REVIEW", "checks": checks, "passed": passed, "total": len(checks), "action": "handoff" if passed == len(checks) else "re-normalize"}
