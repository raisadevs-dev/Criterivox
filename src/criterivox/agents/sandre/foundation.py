from __future__ import annotations

from dataclasses import dataclass, replace
from typing import Any, Iterable

from criterivox.domain.data_foundation import (
    Anomaly,
    CandidateInformation,
    ConfirmationStatus,
    DataFoundation,
    DataProfile,
    DataHandoff,
    ExtractionStatus,
    Missingness,
    Provenance,
    QualityMetadata,
    SourceRecord,
    SourceType,
    Transformation,
)


MAX_SOURCES = 50
MAX_TEXT_BYTES = 4 * 1024 * 1024
MAX_BINARY_BYTES = 4 * 1024 * 1024


@dataclass
class DataFoundationService:
    def ingest(
        self,
        *,
        name: str,
        channel: str,
        source_type: SourceType = SourceType.FILE,
        raw_content: str | None = None,
        raw_content_base64: str | None = None,
        location: str | None = None,
        stored_location: str | None = None,
        parent_source_id: str | None = None,
        supplied_context: dict | None = None,
        extraction_status: ExtractionStatus | None = None,
        processing_status: str = "received",
        error: str | None = None,
    ) -> DataFoundation:
        source_name = name.strip()

        if not source_name or len(source_name) > 500:
            raise ValueError("Source name is invalid.")

        if (
            raw_content is not None
            and len(raw_content.encode("utf-8")) > MAX_TEXT_BYTES
        ):
            raise ValueError("Source exceeds the 4 MB text limit.")

        if (
            raw_content_base64 is not None
            and len(raw_content_base64) > MAX_BINARY_BYTES * 2
        ):
            raise ValueError("Encoded source exceeds the 4 MB binary limit.")

        foundation = DataFoundation.create()

        source_id = f"SRC-{foundation.foundation_id[3:]}"

        provenance = Provenance(
            source_id=source_id,
            source_type=source_type,
            source_name=source_name,
            parent_source_id=parent_source_id,
        )

        status = extraction_status or (
            ExtractionStatus.COMPLETED
            if raw_content is not None
            else (
                ExtractionStatus.UNSUPPORTED
                if raw_content_base64 is not None
                else ExtractionStatus.COMPLETED
            )
        )

        source = SourceRecord(
            source_id=source_id,
            name=source_name,
            source_type=source_type,
            channel=channel.strip() or "unknown",
            provided_at=provenance.created_at,
            location=location,
            parent_source_id=parent_source_id,
            raw_content=raw_content,
            raw_content_base64=raw_content_base64,
            stored_location=stored_location,
            extraction_status=status,
            processing_status=processing_status,
            error=error,
            provenance=provenance,
        )

        candidates = self._extract_candidates(source)

        # IMPORTANT:
        # raw_rows represents the supplied source and must never be replaced
        # by the normalized representation.
        raw_rows = self._rows_from_source(source)

        normalized, transformations = self.normalize(
            raw_rows,
            provenance,
        )

        profile = self.profile(
            normalized,
            sources=(source,),
        )

        missingness = self._missingness(normalized)

        anomalies = self.detect_anomalies(
            normalized,
            source_id,
        )

        quality = QualityMetadata(
            anomaly_count=len(anomalies),
            missing_count=sum(missingness.values()),
            duplicate_count=profile.duplicate_candidates,
        )

        canonical = tuple(dict(row) for row in normalized)

        return replace(
            foundation,
            sources=(source,),
            candidates=tuple(candidates),
            supplied_context=dict(supplied_context or {}),
            raw_data=tuple(dict(row) for row in raw_rows),
            normalized_data=tuple(dict(row) for row in normalized),
            canonical_data=canonical,
            profile=profile,
            quality=quality,
            missingness=missingness,
            anomalies=tuple(anomalies),
            transformations=tuple(transformations),
            confirmation_status=(
                ConfirmationStatus.SYSTEM_EXTRACTED
                if candidates
                else ConfirmationStatus.UNCERTAIN
            ),
            handoff_ready=False,
        )

    def confirm(
        self,
        foundation: DataFoundation,
        *,
        action: str,
        candidate_ids: Iterable = (),
    ) -> DataFoundation:
        allowed = {
            "confirm",
            "correct",
            "exclude",
            "add",
            "irrelevant",
            "clarify",
        }

        if action not in allowed:
            raise ValueError("Unsupported confirmation action.")

        wanted = set(candidate_ids)
        candidates = []

        for item in foundation.candidates:
            if wanted and item.candidate_id not in wanted:
                candidates.append(item)
                continue

            status = {
                "confirm": ConfirmationStatus.USER_CONFIRMED,
                "correct": ConfirmationStatus.USER_CORRECTED,
                "exclude": ConfirmationStatus.USER_EXCLUDED,
                "irrelevant": ConfirmationStatus.USER_EXCLUDED,
                "clarify": ConfirmationStatus.UNCERTAIN,
            }.get(
                action,
                ConfirmationStatus.USER_CORRECTED,
            )

            candidates.append(
                replace(
                    item,
                    confirmation_status=status,
                )
            )

        overall = {
            "confirm": ConfirmationStatus.USER_CONFIRMED,
            "correct": ConfirmationStatus.USER_CORRECTED,
            "exclude": ConfirmationStatus.USER_EXCLUDED,
            "irrelevant": ConfirmationStatus.USER_EXCLUDED,
            "clarify": ConfirmationStatus.UNCERTAIN,
            "add": ConfirmationStatus.USER_CORRECTED,
        }.get(
            action,
            ConfirmationStatus.USER_CORRECTED,
        )

        return replace(
            foundation,
            candidates=tuple(candidates),
            confirmation_status=overall,
            handoff_ready=overall
            in {
                ConfirmationStatus.USER_CONFIRMED,
                ConfirmationStatus.USER_CORRECTED,
            },
        )

    def profile(
        self,
        rows: Iterable,
        *,
        sources: tuple = (),
    ) -> DataProfile:
        rows = tuple(rows)

        fields = sorted(
            {
                key
                for row in rows
                for key in row
            }
        )

        field_types = {
            field: self._type_name(
                next(
                    (
                        row[field]
                        for row in rows
                        if field in row
                        and row[field] is not None
                    ),
                    None,
                )
            )
            for field in fields
        }

        missingness = {
            field: sum(
                field not in row or row[field] is None
                for row in rows
            )
            for field in fields
        }

        uniqueness = {
            field: len(
                {
                    repr(row.get(field))
                    for row in rows
                    if field in row
                    and row[field] is not None
                }
            )
            for field in fields
        }

        signatures = [
            repr(sorted(row.items()))
            for row in rows
        ]

        duplicate_candidates = (
            len(signatures) - len(set(signatures))
        )

        distributions = {}

        for field in fields:
            values = [
                row[field]
                for row in rows
                if isinstance(
                    row.get(field),
                    (int, float),
                )
                and not isinstance(
                    row.get(field),
                    bool,
                )
            ]

            if values:
                distributions[field] = {
                    "min": float(min(values)),
                    "max": float(max(values)),
                    "mean": float(sum(values) / len(values)),
                }

        coverage = {
            source.source_id: sum(
                1
                for _ in rows
            )
            for source in sources
        }

        return DataProfile(
            record_count=len(rows),
            field_count=len(fields),
            field_types=field_types,
            missingness=missingness,
            uniqueness=uniqueness,
            duplicate_candidates=duplicate_candidates,
            distributions=distributions,
            source_coverage=coverage,
        )

    def normalize(
        self,
        rows: Iterable,
        provenance: Provenance,
    ) -> tuple[
        tuple[dict[str, Any], ...],
        tuple[Transformation, ...],
    ]:
        result = []
        transformations = []

        for row_index, original_row in enumerate(rows):
            clean = {}

            for column_index, (key, value) in enumerate(
                original_row.items(),
                start=1,
            ):
                clean_key = (
                    key.strip()
                    if isinstance(key, str)
                    else str(key)
                )

                clean_value = (
                    value.strip()
                    if isinstance(value, str)
                    else value
                )

                if (
                    clean_key != key
                    or clean_value != value
                ):
                    transformation_id = (
                        f"TR-{row_index + 1}-"
                        f"{column_index}-{clean_key}"
                    )

                    transformations.append(
                        Transformation(
                            transformation_id,
                            value,
                            "trim_whitespace",
                            clean_value,
                            (
                                "Deterministic representation "
                                "cleanup; source value remains "
                                "recoverable in raw_data."
                            ),
                            provenance,
                        )
                    )

                clean[clean_key] = clean_value

            result.append(clean)

        return (
            tuple(result),
            tuple(transformations),
        )

    def detect_anomalies(
        self,
        rows: Iterable,
        source_id: str,
    ) -> tuple[Anomaly, ...]:
        rows = tuple(rows)
        anomalies = []

        fields = sorted(
            {
                key
                for row in rows
                for key in row
            }
        )

        for field in fields:
            values = [
                row.get(field)
                for row in rows
                if isinstance(
                    row.get(field),
                    (int, float),
                )
                and not isinstance(
                    row.get(field),
                    bool,
                )
            ]

            if len(values) < 4:
                continue

            mean = sum(values) / len(values)

            variance = (
                sum(
                    (value - mean) ** 2
                    for value in values
                )
                / len(values)
            )

            std = variance**0.5

            if std == 0:
                continue

            for index, row in enumerate(rows):
                value = row.get(field)

                if (
                    isinstance(value, (int, float))
                    and not isinstance(value, bool)
                    and abs(value - mean) > 3 * std
                ):
                    anomalies.append(
                        Anomaly(
                            f"AN-{index + 1}-{field}",
                            source_id,
                            field,
                            value,
                            "z_score",
                            (
                                "Statistical outlier candidate; "
                                "this flag does not establish "
                                "invalidity and the observation "
                                "is preserved."
                            ),
                        )
                    )

        return tuple(anomalies)

    def handoff(
        self,
        foundation: DataFoundation,
        recipient: str = "dharen",
    ) -> DataHandoff:
        if foundation.confirmation_status not in {
            ConfirmationStatus.USER_CONFIRMED,
            ConfirmationStatus.USER_CORRECTED,
        }:
            raise ValueError(
                "User confirmation or correction is required "
                "before handoff."
            )

        return DataHandoff.from_foundation(
            replace(
                foundation,
                handoff_ready=True,
            ),
            recipient,
        )

    @staticmethod
    def _rows_from_source(
        source: SourceRecord,
    ) -> tuple[dict[str, Any], ...]:
        if (
            source.raw_content_base64
            and not source.raw_content
        ):
            return (
                {
                    "source": source.name,
                    "content": Missingness.EXTRACTION_FAILED.value,
                },
            )

        if source.raw_content is None:
            return (
                {
                    "source": source.name,
                    "content": Missingness.NOT_PROVIDED.value,
                },
            )

        # Empty input is distinct from missing input.
        if source.raw_content == "":
            return (
                {
                    "source": source.name,
                    "content": Missingness.UNAVAILABLE.value,
                },
            )

        # Preserve the supplied source EXACTLY.
        # Normalization must happen only in normalized_data.
        return (
            {
                "source": source.name,
                "content": source.raw_content,
            },
        )

    @staticmethod
    def _extract_candidates(
        source: SourceRecord,
    ) -> tuple[CandidateInformation, ...]:
        if (
            not source.raw_content
            or source.extraction_status
            not in {
                ExtractionStatus.COMPLETED,
                ExtractionStatus.PARTIAL,
            }
        ):
            return ()

        lines = [
            line.strip()
            for line in source.raw_content.splitlines()
            if line.strip()
        ]

        return tuple(
            CandidateInformation(
                f"CAND-{source.source_id}-{index + 1}",
                line,
                source.source_id,
                "content",
                1.0,
                ConfirmationStatus.SYSTEM_EXTRACTED,
                provenance=source.provenance,
            )
            for index, line in enumerate(lines[:500])
        )

    @staticmethod
    def _missingness(
        rows: Iterable,
    ) -> dict[str, Missingness]:
        rows = tuple(rows)

        fields = sorted(
            {
                key
                for row in rows
                for key in row
            }
        )

        return {
            field: Missingness.NOT_PROVIDED
            for field in fields
            if any(
                field not in row
                or row[field] is None
                for row in rows
            )
        }

    @staticmethod
    def _type_name(
        value: Any,
    ) -> str:
        return (
            "unknown"
            if value is None
            else type(value).__name__
        )


__all__ = ["DataFoundationService"]
