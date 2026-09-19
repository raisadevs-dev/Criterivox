from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
import hashlib
import json
from typing import Any

from .s5_advanced_runtime import (
    EvaluationGate,
    FoundationSynchronizer,
    KaelenPipeline,
    ProvenanceLedger,
    SchemaDriftHealer,
    SemanticTagger,
    SyntheticDataEngine,
)
from .s5_ml_stack import LocalMLStack
from .s5_sklearn_backend import SklearnAnomalyBackend


@dataclass(frozen=True)
class ReadinessSnapshot:
    completeness: float
    schema_alignment: float
    anomaly_score: float
    readiness: float
    decision: str


class S5FeatureRuntime:
    """
    Application-layer runtime for the S5 feature stack.

    The runtime deliberately accepts lightweight foundation-like objects.
    This is important because S5 tests and adapters may provide partial
    DataFoundation representations rather than requiring one concrete class.

    Runtime state remains derived from the supplied foundation. The runtime
    does not silently invent provenance, confirmation, training consent,
    or execution evidence.
    """

    provisional_alert_threshold = 0.85

    def __init__(self) -> None:
        self.ledger = ProvenanceLedger()
        self.sync = FoundationSynchronizer()
        self.pipeline = KaelenPipeline()
        self.healer = SchemaDriftHealer()
        self.synthetic = SyntheticDataEngine()
        self.tagger = SemanticTagger()
        self.evaluator = EvaluationGate()
        self.ml = LocalMLStack()
        self.sklearn = SklearnAnomalyBackend()

    # ------------------------------------------------------------------
    # Foundation compatibility helpers
    # ------------------------------------------------------------------

    def _rows(self, foundation: Any) -> list[dict[str, Any]]:
        """
        Extract canonical/normalized/raw rows without assuming that every
        foundation implementation exposes every representation.

        Only mapping-like rows are admitted into the feature runtime.
        """

        data = (
            getattr(foundation, "canonical_data", None)
            or getattr(foundation, "normalized_data", None)
            or getattr(foundation, "raw_data", None)
            or ()
        )

        rows: list[dict[str, Any]] = []

        for row in data:
            if isinstance(row, dict):
                rows.append(dict(row))

        return rows

    def _foundation_payload(self, foundation: Any) -> dict[str, Any]:
        """
        Build a serializable foundation payload.

        A complete DataFoundation may expose to_dict(), while lightweight
        fixtures may only expose individual fields. Both forms are supported.
        """

        to_dict = getattr(foundation, "to_dict", None)

        if callable(to_dict):
            payload = to_dict()

            if isinstance(payload, dict):
                return payload

        return {
            "foundation_id": getattr(
                foundation,
                "foundation_id",
                None,
            ),
            "sources": [
                getattr(source, "source_id", None)
                for source in (
                    getattr(foundation, "sources", ()) or ()
                )
            ],
            "raw_data": list(
                getattr(foundation, "raw_data", ()) or ()
            ),
            "canonical_data": list(
                getattr(foundation, "canonical_data", ()) or ()
            ),
            "normalized_data": list(
                getattr(foundation, "normalized_data", ()) or ()
            ),
            "transformations": list(
                getattr(foundation, "transformations", ()) or ()
            ),
            "anomalies": list(
                getattr(foundation, "anomalies", ()) or ()
            ),
            "candidates": list(
                getattr(foundation, "candidates", ()) or ()
            ),
        }

    def _foundation_id(self, foundation: Any) -> str:
        """
        Resolve the authoritative foundation identifier.

        If a lightweight fixture has no explicit ID, derive a stable
        deterministic identifier from its serialized payload.
        """

        foundation_id = getattr(
            foundation,
            "foundation_id",
            None,
        )

        if foundation_id:
            return str(foundation_id)

        payload = self._foundation_payload(foundation)

        serialized = json.dumps(
            payload,
            sort_keys=True,
            default=str,
        ).encode("utf-8")

        digest = hashlib.sha256(serialized).hexdigest()

        return f"FOUNDATION-{digest[:16]}"

    def _profile_record_count(self, profile: Any) -> int | None:
        """
        Resolve record count from the profile without assuming one schema.

        S5 fixtures have historically represented this value either as
        record_count or through equivalent metadata.
        """

        if profile is None:
            return None

        value = getattr(
            profile,
            "record_count",
            None,
        )

        if value is not None:
            try:
                return max(0, int(value))
            except (TypeError, ValueError):
                pass

        for attribute in (
            "records",
            "items_seen",
            "row_count",
            "count",
        ):
            value = getattr(profile, attribute, None)

            if value is not None:
                try:
                    return max(0, int(value))
                except (TypeError, ValueError):
                    continue

        return None

    def _profile_field_count(self, profile: Any) -> int | None:
        """
        Resolve the number of profiled fields.
        """

        if profile is None:
            return None

        value = getattr(
            profile,
            "field_count",
            None,
        )

        if value is not None:
            try:
                return max(0, int(value))
            except (TypeError, ValueError):
                pass

        fields = getattr(
            profile,
            "fields",
            None,
        )

        if isinstance(fields, dict):
            return len(fields)

        if isinstance(fields, (list, tuple, set)):
            return len(fields)

        return None

    def _profile_missingness(
        self,
        profile: Any,
    ) -> dict[str, Any]:
        """
        Return missingness information when available.
        """

        if profile is None:
            return {}

        missingness = getattr(
            profile,
            "missingness",
            None,
        )

        if isinstance(missingness, dict):
            return missingness

        return {}

    def _confirmation_value(
        self,
        foundation: Any,
    ) -> str | None:
        """
        Resolve confirmation status safely.

        Supports enum-like values exposing .value as well as plain strings.
        """

        status = getattr(
            foundation,
            "confirmation_status",
            None,
        )

        if status is None:
            return None

        value = getattr(
            status,
            "value",
            status,
        )

        if value is None:
            return None

        return str(value)

    # ------------------------------------------------------------------
    # Readiness
    # ------------------------------------------------------------------

    def readiness(
        self,
        foundation: Any,
    ) -> ReadinessSnapshot:
        rows = self._rows(foundation)
        profile = getattr(
            foundation,
            "profile",
            None,
        )

        # --------------------------------------------------------------
        # Completeness
        # --------------------------------------------------------------

        if profile is None:
            completeness = 1.0 if rows else 0.0

        else:
            missingness_rate = getattr(
                profile,
                "missingness_rate",
                None,
            )

            if missingness_rate is not None:
                try:
                    completeness = 1.0 - float(
                        missingness_rate
                    )
                except (TypeError, ValueError):
                    completeness = 1.0 if rows else 0.0

            else:
                missingness = self._profile_missingness(
                    profile
                )

                record_count = self._profile_record_count(
                    profile
                )

                field_count = self._profile_field_count(
                    profile
                )

                if (
                    record_count is not None
                    and field_count is not None
                ):
                    total = max(
                        1,
                        record_count * max(
                            1,
                            field_count,
                        ),
                    )

                    numeric_missing = 0.0

                    for value in missingness.values():
                        try:
                            numeric_missing += float(value)
                        except (TypeError, ValueError):
                            continue

                    completeness = (
                        1.0
                        - (
                            numeric_missing
                            / total
                        )
                    )

                elif rows:
                    completeness = 1.0

                else:
                    completeness = 0.0

        completeness = max(
            0.0,
            min(
                1.0,
                completeness,
            ),
        )

        # --------------------------------------------------------------
        # Schema alignment
        # --------------------------------------------------------------

        schema_alignment = 1.0 if rows else 0.0

        # --------------------------------------------------------------
        # Anomaly score
        # --------------------------------------------------------------

        anomalies = (
            getattr(
                foundation,
                "anomalies",
                (),
            )
            or ()
        )

        candidates = (
            getattr(
                foundation,
                "candidates",
                (),
            )
            or ()
        )

        anomaly_score = max(
            0.0,
            min(
                1.0,
                len(anomalies)
                / max(
                    1,
                    len(candidates),
                ),
            ),
        )

        # --------------------------------------------------------------
        # Composite readiness
        # --------------------------------------------------------------

        readiness = max(
            0.0,
            min(
                1.0,
                (
                    completeness * 0.45
                    + schema_alignment * 0.35
                    + (1.0 - anomaly_score) * 0.20
                ),
            ),
        )

        return ReadinessSnapshot(
            completeness=round(
                completeness,
                4,
            ),
            schema_alignment=round(
                schema_alignment,
                4,
            ),
            anomaly_score=round(
                anomaly_score,
                4,
            ),
            readiness=round(
                readiness,
                4,
            ),
            decision=(
                "READY"
                if readiness
                >= self.provisional_alert_threshold
                else "REVIEW"
            ),
        )

    # ------------------------------------------------------------------
    # Provenance
    # ------------------------------------------------------------------

    def provenance(
        self,
        foundation: Any,
        revision: int | None = None,
    ) -> dict[str, Any]:
        foundation_id = self._foundation_id(
            foundation
        )

        payload = self._foundation_payload(
            foundation
        )

        entry = self.ledger.append(
            foundation_id,
            "FOUNDATION_SNAPSHOT",
            payload,
        )

        raw_data = (
            getattr(
                foundation,
                "raw_data",
                (),
            )
            or ()
        )

        sources = (
            getattr(
                foundation,
                "sources",
                (),
            )
            or ()
        )

        transformations = (
            getattr(
                foundation,
                "transformations",
                (),
            )
            or ()
        )

        payload_hash = hashlib.sha256(
            json.dumps(
                list(raw_data),
                sort_keys=True,
                default=str,
            ).encode("utf-8")
        ).hexdigest()

        result: dict[str, Any] = {
            "payload_hash": payload_hash,
            "captured_at": datetime.now(
                timezone.utc
            ).isoformat(),
            "source_count": len(sources),
            "transformation_count": len(
                transformations
            ),
            "revision": entry.revision,
            "timeline_supported": True,
        }

        if revision is not None:
            result["rewind"] = asdict(
                self.ledger.rewind(
                    foundation_id,
                    revision,
                )
            )

        return result

    def rewind(
        self,
        foundation: Any,
        revision: int,
    ) -> dict[str, Any]:
        return asdict(
            self.ledger.rewind(
                self._foundation_id(foundation),
                revision,
            )
        )

    # ------------------------------------------------------------------
    # Synthetic data
    # ------------------------------------------------------------------

    def synthetic_preview(
        self,
        foundation: Any,
        seed: int = 17,
    ) -> dict[str, Any]:
        preview = self.synthetic.preview(
            self._rows(foundation),
            seed,
        )

        if not isinstance(preview, dict):
            preview = {
                "preview": preview,
            }

        return {
            **preview,
            "mode": "local-synthetic",
            "training_consent": False,
        }

    # ------------------------------------------------------------------
    # Semantic interpretation
    # ------------------------------------------------------------------

    def semantic(
        self,
        foundation: Any,
    ) -> dict[str, Any]:
        context = getattr(
            foundation,
            "supplied_context",
            {},
        ) or {}

        result = self.tagger.tag(
            self._rows(foundation),
            context,
        )

        if not isinstance(result, dict):
            result = {
                "tags": result,
            }

        return {
            **result,
            "active_metadata": True,
        }

    # ------------------------------------------------------------------
    # Schema drift
    # ------------------------------------------------------------------

    def schema_patch(
        self,
        foundation: Any,
    ) -> dict[str, Any]:
        rows = self._rows(
            foundation
        )

        old = sorted(
            {
                key
                for row in rows
                for key in row
            }
        )

        context = getattr(
            foundation,
            "supplied_context",
            {},
        ) or {}

        expected_schema = context.get(
            "expected_schema",
            old,
        )

        if expected_schema is None:
            expected_schema = old

        new = [
            str(key)
            for key in expected_schema
        ]

        aliases = context.get(
            "schema_aliases",
            {},
        )

        normalized_aliases = (
            {
                str(key): str(value)
                for key, value in aliases.items()
            }
            if isinstance(
                aliases,
                dict,
            )
            else {}
        )

        return self.healer.patch(
            rows,
            old,
            new,
            normalized_aliases,
        )

    # ------------------------------------------------------------------
    # Pipeline
    # ------------------------------------------------------------------

    def pipeline_result(
        self,
        foundation: Any,
    ) -> dict[str, Any]:
        return self.pipeline.execute(
            self._rows(foundation)
        )

    # ------------------------------------------------------------------
    # Synchronization
    # ------------------------------------------------------------------

    def sync_envelope(
        self,
        foundation: Any,
        revision: int = 1,
    ) -> dict[str, Any]:
        return asdict(
            self.sync.prepare(
                self._foundation_id(
                    foundation
                ),
                revision,
                self._foundation_payload(
                    foundation
                ),
            )
        )

    def accept_sync(
        self,
        envelope: dict[str, Any],
    ) -> dict[str, Any]:
        from .s5_advanced_runtime import SyncEnvelope

        return self.sync.accept(
            SyncEnvelope(
                str(
                    envelope[
                        "foundation_id"
                    ]
                ),
                int(
                    envelope[
                        "revision"
                    ]
                ),
                str(
                    envelope[
                        "payload_hash"
                    ]
                ),
                str(
                    envelope.get(
                        "operation",
                        "upsert",
                    )
                ),
                dict(
                    envelope[
                        "payload"
                    ]
                ),
            )
        )

    # ------------------------------------------------------------------
    # Local ML
    # ------------------------------------------------------------------

    def ml_train_and_score(
        self,
        foundation: Any,
    ) -> dict[str, Any]:
        rows = self._rows(
            foundation
        )

        baseline = (
            self.ml.train_anomaly_baseline(
                rows
            )
        )

        result: dict[str, Any] = {
            "baseline": baseline,
            "agent": "sandre",
            "execution": "local",
        }

        if len(rows) >= 4:
            try:
                model = self.sklearn.train(
                    rows
                )

                result["sklearn"] = (
                    self.sklearn.score(
                        model,
                        rows[:100],
                    )
                )

            except ValueError as exc:
                result["sklearn"] = {
                    "status": "not_ready",
                    "reason": str(exc),
                }

        return result

    # ------------------------------------------------------------------
    # Agent runtime
    # ------------------------------------------------------------------

    def agent_runtime(
        self,
        foundation: Any,
        agent: str,
    ) -> dict[str, Any]:
        normalized_agent = (
            str(agent).lower()
        )

        if normalized_agent == "sandre":
            result = (
                self.ml_train_and_score(
                    foundation
                )
            )
        else:
            result = (
                self.pipeline_result(
                    foundation
                )
            )

        return {
            "agent": normalized_agent,
            "runtime": "local-executable",
            "foundation_id": self._foundation_id(
                foundation
            ),
            "result": result,
        }

    # ------------------------------------------------------------------
    # Vector readiness
    # ------------------------------------------------------------------

    def vector_readiness(
        self,
        foundation: Any,
    ) -> dict[str, Any]:
        return {
            "stage": (
                "embedding-ready-representation"
            ),
            "text": bool(
                self._rows(foundation)
            ),
            "image": False,
            "audio": False,
            "lakehouse": (
                "deferred-by-S5-scope"
            ),
        }

    # ------------------------------------------------------------------
    # EDD gate
    # ------------------------------------------------------------------

    def edd_gate(
        self,
        foundation: Any,
    ) -> dict[str, Any]:
        readiness = self.readiness(
            foundation
        )

        ml = self.ml_train_and_score(
            foundation
        )

        context = getattr(
            foundation,
            "supplied_context",
            {},
        ) or {}

        datasets = context.get(
            "evaluation_datasets",
            [],
        )

        confirmation_value = (
            self._confirmation_value(
                foundation
            )
        )

        confirmation_ok = (
            confirmation_value
            in {
                "user-confirmed",
                "user-corrected",
            }
        )

        sources = (
            getattr(
                foundation,
                "sources",
                (),
            )
            or ()
        )

        readiness_ok = (
            readiness.readiness
            >= self.provisional_alert_threshold
        )

        provenance_ok = bool(
            sources
        )

        ml_baseline = ml.get(
            "baseline",
            {},
        )

        ml_execution_ok = bool(
            isinstance(
                ml_baseline,
                dict,
            )
            and ml_baseline.get(
                "trained"
            )
        )

        return {
            "status": (
                "PASS"
                if (
                    readiness_ok
                    and provenance_ok
                    and confirmation_ok
                )
                else "REVIEW"
            ),
            "checks": {
                "readiness": readiness_ok,
                "provenance": provenance_ok,
                "confirmation": confirmation_ok,
                "ml_execution": ml_execution_ok,
            },
            "metrics": {
                "readiness": readiness.readiness,
            },
            "evaluation_datasets": datasets,
            "threshold": (
                self.provisional_alert_threshold
            ),
            "threshold_status": "provisional",
            "training_policy": (
                "local-only-with-explicit-consent"
            ),
        }