from __future__ import annotations

from dataclasses import replace
from typing import Any

from .data_foundation import DataFoundationService
from criterivox.domain.data_foundation import DataFoundation, Provenance, SourceRecord, SourceType


def ingest_sources(payload: dict[str, Any]) -> DataFoundation:
    """Build one foundation from mixed local/text/reference sources while retaining parent links."""
    sources = payload.get("sources")
    if not isinstance(sources, list) or not sources or len(sources) > 50:
        raise ValueError("Intake requires between 1 and 50 sources.")
    service = DataFoundationService()
    foundation = DataFoundation.create()
    records: list[SourceRecord] = []
    raw_rows: list[dict[str, Any]] = []
    candidates = []
    transformations = []
    normalized = []
    for index, item in enumerate(sources):
        if not isinstance(item, dict):
            raise ValueError("Invalid source entry.")
        name = item.get("name")
        if not isinstance(name, str) or not name.strip():
            raise ValueError("Each source needs a name.")
        source_type = SourceType(str(item.get("source_type", "file")).lower())
        child = service.ingest(name=name, channel=str(item.get("channel", "file")), source_type=source_type,
            raw_content=item.get("content") if isinstance(item.get("content"), str) else None,
            location=item.get("location"), parent_source_id=str(item.get("parent_source_id") or payload.get("collection_id") or ""))
        source = replace(child.sources[0], source_id=f"SRC-{foundation.foundation_id[3:]}-{index + 1:02d}")
        provenance = replace(source.provenance, source_id=source.source_id) if source.provenance else Provenance(source.source_id, source.source_type, source.name, source.parent_source_id)
        source = replace(source, provenance=provenance)
        records.append(source)
        raw_rows.extend(child.raw_data)
        candidates.extend(replace(c, source_id=source.source_id, candidate_id=f"CAND-{source.source_id}-{i+1}", provenance=provenance) for i, c in enumerate(child.candidates))
        transformations.extend(child.transformations)
        normalized.extend(child.normalized_data)
    profile = service.profile(normalized, sources=tuple(records))
    anomalies = tuple(a for r in records for a in service.detect_anomalies(normalized, r.source_id))
    from criterivox.domain.data_foundation import QualityMetadata, ConfirmationStatus
    quality = QualityMetadata(anomaly_count=len(anomalies), missing_count=sum(profile.missingness.values()), duplicate_count=profile.duplicate_candidates)
    return replace(foundation, sources=tuple(records), candidates=tuple(candidates), supplied_context=dict(payload.get("supplied_context") or {}),
        raw_data=tuple(raw_rows), normalized_data=tuple(normalized), canonical_data=tuple(dict(r) for r in normalized), profile=profile,
        quality=quality, anomalies=anomalies, transformations=tuple(transformations),
        confirmation_status=ConfirmationStatus.SYSTEM_EXTRACTED if candidates else ConfirmationStatus.UNCERTAIN)
