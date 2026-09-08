from __future__ import annotations

from dataclasses import replace
from typing import Any

from .data_foundation import DataFoundationService
from .folder_material_loader import collect_folder_sources
from criterivox.domain.data_foundation import DataFoundation, Provenance, SourceRecord, SourceType, ExtractionStatus


def ingest_sources(payload: dict[str, Any]) -> DataFoundation:
    sources = payload.get("sources")
    if not isinstance(sources, list) or not sources or len(sources) > 50:
        raise ValueError("Intake requires between 1 and 50 sources.")
    return _build_foundation(sources, payload)


def ingest_folder_path(payload: dict[str, Any]) -> DataFoundation:
    folder_path = payload.get("folder_path")
    collection_id = payload.get("collection_id")
    sources = collect_folder_sources(folder_path, collection_id=str(collection_id) if collection_id else None)
    return _build_foundation(sources, {**payload, "sources": sources, "collection_id": collection_id or folder_path})


def _build_foundation(sources: list[dict[str, Any]], payload: dict[str, Any]) -> DataFoundation:
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
        try:
            source_type = SourceType(str(item.get("source_type", "file")).lower())
        except ValueError as exc:
            raise ValueError("Unsupported source type.") from exc
        status = None
        if item.get("extraction_status") is not None:
            try:
                status = ExtractionStatus(str(item["extraction_status"]))
            except ValueError as exc:
                raise ValueError("Unsupported extraction status.") from exc
        child = service.ingest(
            name=name,
            channel=str(item.get("channel", "file")),
            source_type=source_type,
            raw_content=item.get("content") if isinstance(item.get("content"), str) else None,
            raw_content_base64=item.get("content_base64") if isinstance(item.get("content_base64"), str) else None,
            location=item.get("location") if isinstance(item.get("location"), str) else None,
            parent_source_id=str(item.get("parent_source_id") or payload.get("collection_id") or "") or None,
            extraction_status=status,
            processing_status=str(item.get("processing_status", "received")),
            error=item.get("error") if isinstance(item.get("error"), str) else None,
        )
        source = replace(child.sources[0], source_id=f"SRC-{foundation.foundation_id[3:]}-{index + 1:02d}")
        provenance = replace(source.provenance, source_id=source.source_id) if source.provenance else Provenance(source.source_id, source.source_type, source.name, source.parent_source_id)
        source = replace(source, provenance=provenance)
        records.append(source)
        raw_rows.extend(child.raw_data)
        candidates.extend(replace(c, source_id=source.source_id, candidate_id=f"CAND-{source.source_id}-{i+1}", provenance=provenance) for i, c in enumerate(child.candidates))
        transformations.extend(replace(t, provenance=provenance) for t in child.transformations)
        normalized.extend(child.normalized_data)
    profile = service.profile(normalized, sources=tuple(records))
    anomalies = tuple(a for r in records for a in service.detect_anomalies(normalized, r.source_id))
    from criterivox.domain.data_foundation import QualityMetadata, ConfirmationStatus
    quality = QualityMetadata(anomaly_count=len(anomalies), missing_count=sum(profile.missingness.values()), duplicate_count=profile.duplicate_candidates)
    return replace(
        foundation,
        sources=tuple(records), candidates=tuple(candidates),
        supplied_context=dict(payload.get("supplied_context") or {}), raw_data=tuple(raw_rows),
        normalized_data=tuple(normalized), canonical_data=tuple(dict(r) for r in normalized), profile=profile,
        quality=quality, anomalies=anomalies, transformations=tuple(transformations),
        confirmation_status=ConfirmationStatus.SYSTEM_EXTRACTED if candidates else ConfirmationStatus.UNCERTAIN,
    )


__all__ = ["ingest_sources", "ingest_folder_path"]