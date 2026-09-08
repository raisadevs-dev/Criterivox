from __future__ import annotations

from dataclasses import dataclass, replace
from typing import Any, Iterable

from criterivox.domain.data_foundation import (
    Anomaly, CandidateInformation, ConfirmationStatus, DataFoundation,
    DataProfile, ExtractionStatus, Missingness, Provenance, QualityMetadata,
    SourceRecord, SourceType, Transformation,
)


MAX_SOURCES = 50
MAX_TEXT_BYTES = 4 * 1024 * 1024
MAX_BINARY_BYTES = 4 * 1024 * 1024


@dataclass
class DataFoundationService:
    """Deterministic, input-neutral S5 foundation pipeline."""

    def ingest(
        self,
        *,
        name: str,
        channel: str,
        source_type: SourceType = SourceType.FILE,
        raw_content: str | None = None,
        raw_content_base64: str | None = None,
        location: str | None = None,
        parent_source_id: str | None = None,
        supplied_context: dict[str, Any] | None = None,
        extraction_status: ExtractionStatus | None = None,
        processing_status: str = "received",
        error: str | None = None,
    ) -> DataFoundation:
        if not name.strip() or len(name) > 500:
            raise ValueError("Source name is invalid.")
        if raw_content is not None and len(raw_content.encode("utf-8")) > MAX_TEXT_BYTES:
            raise ValueError("Source exceeds the 4 MB text limit.")
        if raw_content_base64 is not None and len(raw_content_base64) > MAX_BINARY_BYTES * 2:
            raise ValueError("Encoded source exceeds the 4 MB binary limit.")
        foundation = DataFoundation.create()
        source_id = f"SRC-{foundation.foundation_id[3:]}"
        provenance = Provenance(source_id, source_type, name.strip(), parent_source_id)
        status = extraction_status or (ExtractionStatus.COMPLETED if raw_content else ExtractionStatus.UNSUPPORTED if raw_content_base64 else ExtractionStatus.COMPLETED)
        source = SourceRecord(
            source_id=source_id, name=name.strip(), source_type=source_type,
            channel=channel.strip() or "unknown", provided_at=provenance.created_at,
            location=location, parent_source_id=parent_source_id,
            raw_content=raw_content, raw_content_base64=raw_content_base64,
            extraction_status=status, processing_status=processing_status,
            error=error, provenance=provenance,
        )
        candidates = self._extract_candidates(source)
        raw_rows = self._rows_from_source(source)
        normalized, transformations = self.normalize(raw_rows, provenance)
        profile = self.profile(normalized, sources=(source,))
        missingness = self._missingness(normalized)
        anomalies = self.detect_anomalies(normalized, source_id)
        quality = QualityMetadata(
            anomaly_count=len(anomalies),
            missing_count=sum(missingness.values()),
            duplicate_count=profile.duplicate_candidates,
        )
        canonical = tuple(dict(row) for row in normalized)
        return replace(
            foundation,
            sources=(source,), candidates=tuple(candidates),
            supplied_context=dict(supplied_context or {}), raw_data=tuple(raw_rows),
            normalized_data=tuple(normalized), canonical_data=canonical,
            profile=profile, quality=quality, missingness=missingness,
            anomalies=tuple(anomalies), transformations=tuple(transformations),
            confirmation_status=(ConfirmationStatus.SYSTEM_EXTRACTED if candidates else ConfirmationStatus.UNCERTAIN),
            handoff_ready=False,
        )

    def confirm(self, foundation: DataFoundation, *, action: str, candidate_ids: Iterable[str] = ()) -> DataFoundation:
        allowed = {"confirm", "correct", "exclude", "add", "irrelevant", "clarify"}
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
            }.get(action, ConfirmationStatus.USER_CORRECTED)
            candidates.append(replace(item, confirmation_status=status))
        return replace(foundation, candidates=tuple(candidates), confirmation_status=ConfirmationStatus.USER_CONFIRMED if action == "confirm" else ConfirmationStatus.USER_CORRECTED)

    def profile(self, rows: Iterable[dict[str, Any]], *, sources: tuple[SourceRecord, ...] = ()) -> DataProfile:
        rows = tuple(rows)
        fields = sorted({key for row in rows for key in row})
        field_types = {field: self._type_name(next((row[field] for row in rows if field in row and row[field] is not None), None)) for field in fields}
        missingness = {field: sum(field not in row or row[field] is None for row in rows) for field in fields}
        uniqueness = {field: len({repr(row.get(field)) for row in rows if field in row and row[field] is not None}) for field in fields}
        signatures = [repr(sorted(row.items())) for row in rows]
        duplicate_candidates = len(signatures) - len(set(signatures))
        distributions: dict[str, dict[str, float]] = {}
        for field in fields:
            values = [row[field] for row in rows if isinstance(row.get(field), (int, float)) and not isinstance(row.get(field), bool)]
            if values:
                distributions[field] = {"min": float(min(values)), "max": float(max(values)), "mean": float(sum(values) / len(values))}
        coverage = {s.source_id: sum(1 for _ in rows) for s in sources}
        return DataProfile(len(rows), len(fields), field_types, missingness, uniqueness, duplicate_candidates, distributions, source_coverage=coverage)

    def normalize(self, rows: Iterable[dict[str, Any]], provenance: Provenance) -> tuple[tuple[dict[str, Any], ...], tuple[Transformation, ...]]:
        result = []
        transformations = []
        for row_index, original_row in enumerate(rows):
            clean = {}
            for key, value in original_row.items():
                clean_key = key.strip() if isinstance(key, str) else str(key)
                clean_value = value.strip() if isinstance(value, str) else value
                if clean_key != key or clean_value != value:
                    transformations.append(Transformation(f"TR-{row_index+1}-{clean_key}", value, "trim_whitespace", clean_value, "Normalize representation without changing meaning.", provenance))
                clean[clean_key] = clean_value
            result.append(clean)
        return tuple(result), tuple(transformations)

    def detect_anomalies(self, rows: Iterable[dict[str, Any]], source_id: str) -> tuple[Anomaly, ...]:
        rows = tuple(rows)
        anomalies: list[Anomaly] = []
        for field in sorted({k for row in rows for k in row}):
            values = [row.get(field) for row in rows if isinstance(row.get(field), (int, float)) and not isinstance(row.get(field), bool)]
            if len(values) < 4:
                continue
            mean = sum(values) / len(values)
            variance = sum((v - mean) ** 2 for v in values) / len(values)
            std = variance ** 0.5
            if std == 0:
                continue
            for index, row in enumerate(rows):
                value = row.get(field)
                if isinstance(value, (int, float)) and abs(value - mean) > 3 * std:
                    anomalies.append(Anomaly(f"AN-{index+1}-{field}", source_id, field, value, "z_score", "Absolute z-score exceeds deterministic 3-sigma threshold; observation is preserved."))
        return tuple(anomalies)

    def handoff(self, foundation: DataFoundation, recipient: str = "dharen"):
        from criterivox.domain.data_foundation import DataHandoff
        if foundation.confirmation_status not in {ConfirmationStatus.USER_CONFIRMED, ConfirmationStatus.USER_CORRECTED}:
            raise ValueError("User confirmation is required before handoff.")
        return DataHandoff.from_foundation(replace(foundation, handoff_ready=True), recipient)

    @staticmethod
    def _rows_from_source(source: SourceRecord) -> tuple[dict[str, Any], ...]:
        if source.raw_content_base64 and not source.raw_content:
            return ({"source": source.name, "content": Missingness.EXTRACTION_FAILED.value},)
        if not source.raw_content:
            return ({"source": source.name, "content": Missingness.NOT_PROVIDED.value},)
        lines = [line.strip() for line in source.raw_content.splitlines() if line.strip()]
        if not lines:
            return ({"source": source.name, "content": Missingness.UNAVAILABLE.value},)
        return tuple({"source": source.name, "content": line} for line in lines)

    @staticmethod
    def _extract_candidates(source: SourceRecord) -> tuple[CandidateInformation, ...]:
        if not source.raw_content or source.extraction_status not in {ExtractionStatus.COMPLETED, ExtractionStatus.PARTIAL}:
            return ()
        lines = [line.strip() for line in source.raw_content.splitlines() if line.strip()]
        return tuple(CandidateInformation(f"CAND-{source.source_id}-{i+1}", line, source.source_id, "content", 1.0, ConfirmationStatus.SYSTEM_EXTRACTED, provenance=source.provenance) for i, line in enumerate(lines[:500]))

    @staticmethod
    def _missingness(rows: Iterable[dict[str, Any]]) -> dict[str, Missingness]:
        fields = sorted({k for row in rows for k in row})
        result: dict[str, Missingness] = {}
        for field in fields:
            if any(field not in row or row[field] is None for row in rows):
                result[field] = Missingness.NOT_PROVIDED
        return result

    @staticmethod
    def _type_name(value: Any) -> str:
        if value is None:
            return "unknown"
        return type(value).__name__


__all__ = ["DataFoundationService"]