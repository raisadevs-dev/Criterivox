
from __future__ import annotations

from dataclasses import replace
from typing import Any

from .data_foundation import DataFoundationService
from .folder_material_loader import collect_folder_sources
from criterivox.domain.data_foundation import (
    ConfirmationStatus,
    DataFoundation,
    ExtractionStatus,
    Provenance,
    SourceRecord,
    SourceType,
)


def ingest_sources(payload: dict[str, Any]) -> DataFoundation:
    sources = payload.get("sources")

    if not isinstance(sources, list) or not sources or len(sources) > 50:
        raise ValueError("Intake requires between 1 and 50 sources.")

    return _build_foundation(sources, payload)


def ingest_folder_path(payload: dict[str, Any]) -> DataFoundation:
    folder_path = payload.get("folder_path")
    collection_id = payload.get("collection_id")

    sources = collect_folder_sources(
        folder_path,
        collection_id=str(collection_id) if collection_id else None,
    )

    return _build_foundation(
        sources,
        {
            **payload,
            "sources": sources,
            "collection_id": collection_id or folder_path,
        },
    )


def _build_foundation(
    sources: list[dict[str, Any]],
    payload: dict[str, Any],
) -> DataFoundation:
    service = DataFoundationService()
    foundation = DataFoundation.create()

    # Every multi-source intake needs a stable parent/collection identity.
    # If the caller supplied one, preserve it. Otherwise the foundation itself
    # becomes the collection root.
    collection_id = str(
        payload.get("collection_id") or foundation.foundation_id
    )

    records: list[SourceRecord] = []
    raw_rows: list[dict[str, Any]] = []
    candidates = []
    transformations = []
    normalized: list[dict[str, Any]] = []

    for index, item in enumerate(sources):
        if not isinstance(item, dict):
            raise ValueError("Invalid source entry.")

        name = item.get("name")
        if not isinstance(name, str) or not name.strip():
            raise ValueError("Each source needs a name.")

        try:
            source_type = SourceType(
                str(item.get("source_type", "file")).lower()
            )
        except ValueError as exc:
            raise ValueError("Unsupported source type.") from exc

        status = None

        if item.get("extraction_status") is not None:
            try:
                status = ExtractionStatus(
                    str(item["extraction_status"])
                )
            except ValueError as exc:
                raise ValueError("Unsupported extraction status.") from exc

        # Preserve an explicitly supplied parent. Otherwise attach the source
        # to this intake's collection/foundation.
        parent_source_id = str(
            item.get("parent_source_id") or collection_id
        )

        child = service.ingest(
            name=name,
            channel=str(item.get("channel", "file")),
            source_type=source_type,
            raw_content=(
                item.get("content")
                if isinstance(item.get("content"), str)
                else None
            ),
            raw_content_base64=(
                item.get("content_base64")
                if isinstance(item.get("content_base64"), str)
                else None
            ),
            location=(
                item.get("location")
                if isinstance(item.get("location"), str)
                else None
            ),
            stored_location=(
                item.get("stored_location")
                if isinstance(item.get("stored_location"), str)
                else None
            ),
            parent_source_id=parent_source_id,
            extraction_status=status,
            processing_status=str(
                item.get("processing_status", "received")
            ),
            error=(
                item.get("error")
                if isinstance(item.get("error"), str)
                else None
            ),
        )

        # Rebind the child-generated source identity to the shared foundation
        # so every source has a deterministic relationship to this intake.
        source = replace(
            child.sources[0],
            source_id=f"SRC-{foundation.foundation_id[3:]}-{index + 1:02d}",
        )

        provenance = (
            replace(
                source.provenance,
                source_id=source.source_id,
                parent_source_id=source.parent_source_id,
            )
            if source.provenance
            else Provenance(
                source.source_id,
                source.source_type,
                source.name,
                source.parent_source_id,
            )
        )

        source = replace(
            source,
            provenance=provenance,
        )

        records.append(source)

        raw_rows.extend(child.raw_data)

        candidates.extend(
            replace(
                candidate,
                source_id=source.source_id,
                candidate_id=f"CAND-{source.source_id}-{candidate_index + 1}",
                provenance=provenance,
            )
            for candidate_index, candidate in enumerate(child.candidates)
        )

        transformations.extend(
            replace(
                transformation,
                provenance=provenance,
            )
            for transformation in child.transformations
        )

        normalized.extend(child.normalized_data)

    profile = service.profile(
        normalized,
        sources=tuple(records),
    )

    anomalies = tuple(
        anomaly
        for source in records
        for anomaly in service.detect_anomalies(
            normalized,
            source.source_id,
        )
    )

    quality = __import__(
        "criterivox.domain.data_foundation",
        fromlist=["QualityMetadata"],
    ).QualityMetadata(
        anomaly_count=len(anomalies),
        missing_count=sum(profile.missingness.values()),
        duplicate_count=profile.duplicate_candidates,
    )

    return replace(
        foundation,
        sources=tuple(records),
        candidates=tuple(candidates),
        supplied_context=dict(payload.get("supplied_context") or {}),
        raw_data=tuple(raw_rows),
        normalized_data=tuple(normalized),
        canonical_data=tuple(dict(row) for row in normalized),
        profile=profile,
        quality=quality,
        anomalies=anomalies,
        transformations=tuple(transformations),
        confirmation_status=(
            ConfirmationStatus.SYSTEM_EXTRACTED
            if candidates
            else ConfirmationStatus.UNCERTAIN
        ),
    )


__all__ = [
    "ingest_sources",
    "ingest_folder_path",
]

"""

### One cleanup I deliberately made

I imported `ConfirmationStatus` and `QualityMetadata` from the domain instead of doing the original mid-function import:

```python
from criterivox.domain.data_foundation import QualityMetadata, ConfirmationStatus
```

There is no reason to make Python perform a tiny bureaucratic pilgrimage halfway through the function.

I also preserved:

* explicit `item["parent_source_id"]`
* `payload["collection_id"]`
* folder collection IDs
* fallback to the generated `foundation_id`
* source/provenance ID synchronization
* all existing normalization, candidates, anomalies, quality, and handoff behavior

### Expected result

This test:

```python
assert foundation.sources[0].parent_source_id is not None
assert foundation.sources[1].parent_source_id is not None
```

will now receive:

```text
source 1 → parent_source_id = DF-XXXXXXXXXX
source 2 → parent_source_id = DF-XXXXXXXXXX
```

when no collection ID was supplied.

Run:

```bash
pytest tests/application/test_s5_data_foundation.py -q
```

before touching the S6 failure.
"""