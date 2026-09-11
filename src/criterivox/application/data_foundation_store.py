from __future__ import annotations

from dataclasses import asdict, dataclass, replace
from datetime import datetime, timezone
from typing import Any

from .data_foundation import DataFoundationService
from .data_intake import ingest_folder_path, ingest_sources
from criterivox.domain.data_foundation import (
    Anomaly,
    CandidateInformation,
    ConfirmationStatus,
    DataFoundation,
    DataProfile,
    ExtractionStatus,
    Missingness,
    Provenance,
    QualityMetadata,
    SourceRecord,
    SourceType,
    Transformation,
)


@dataclass
class DataFoundationStore:
    items: dict[str, DataFoundation] | None = None
    revisions: dict[str, int] | None = None

    def __post_init__(self) -> None:
        if self.items is None:
            self.items = {}
        if self.revisions is None:
            self.revisions = {}

    def ingest(self, payload: dict) -> DataFoundation:
        item = ingest_sources(payload)
        self.items[item.foundation_id] = item
        self.revisions[item.foundation_id] = 1
        return item

    def ingest_folder(self, payload: dict) -> DataFoundation:
        item = ingest_folder_path(payload)
        self.items[item.foundation_id] = item
        self.revisions[item.foundation_id] = 1
        return item

    def confirm(self, foundation_id: str, action: str, candidate_ids: tuple[str, ...] = ()) -> DataFoundation:
        item = self.get(foundation_id)
        item = DataFoundationService().confirm(item, action=action, candidate_ids=candidate_ids)
        self.items[foundation_id] = item
        self.revisions[foundation_id] = self.revisions.get(foundation_id, 1) + 1
        return item

    def handoff(self, foundation_id: str, recipient: str = "dharen"):
        item = self.get(foundation_id)
        handoff = DataFoundationService().handoff(item, recipient)
        self.items[foundation_id] = replace(item, handoff_ready=True)
        self.revisions[foundation_id] = self.revisions.get(foundation_id, 1) + 1
        return handoff

    def get(self, foundation_id: str) -> DataFoundation:
        if not isinstance(foundation_id, str) or foundation_id not in self.items:
            raise ValueError("Unknown data foundation.")
        return self.items[foundation_id]

    def revision(self, foundation_id: str) -> int:
        self.get(foundation_id)
        return self.revisions.get(foundation_id, 1)

    def serialize(self, foundation_id: str) -> dict[str, Any]:
        foundation = self.get(foundation_id)
        return {
            "schema_version": 1,
            "foundation_id": foundation.foundation_id,
            "revision": self.revision(foundation_id),
            "serialized_at": datetime.now(timezone.utc).isoformat(),
            "foundation": foundation.to_dict(),
        }

    def restore_replace(self, envelope: dict[str, Any], *, authoritative: bool = True) -> DataFoundation:
        """Restore a browser copy and, when authorised, replace the server copy."""
        if not isinstance(envelope, dict):
            raise ValueError("Foundation synchronization envelope must be an object.")
        raw = envelope.get("foundation")
        if not isinstance(raw, dict):
            raise ValueError("Foundation synchronization requires a serialized foundation object.")
        foundation = _foundation_from_dict(raw)
        foundation_id = foundation.foundation_id
        incoming_revision = int(envelope.get("revision", 1))
        if incoming_revision < 1:
            raise ValueError("Foundation revision must be positive.")
        current = self.items.get(foundation_id)
        current_revision = self.revisions.get(foundation_id, 0)
        if current is not None and incoming_revision < current_revision:
            raise ValueError(f"Stale foundation revision {incoming_revision}; server has {current_revision}.")
        if current is not None and incoming_revision == current_revision:
            if current.to_dict() != foundation.to_dict():
                raise ValueError("Foundation revision conflict: equal revisions contain different material.")
            return current
        if not authoritative and current is not None:
            return current
        self.items[foundation_id] = foundation
        self.revisions[foundation_id] = incoming_revision
        return foundation


def _foundation_from_dict(raw: dict[str, Any]) -> DataFoundation:
    def provenance(value: dict[str, Any] | None) -> Provenance | None:
        if value is None:
            return None
        return Provenance(**{**value, "source_type": SourceType(value["source_type"])})

    def source(value: dict[str, Any]) -> SourceRecord:
        data = dict(value)
        data["source_type"] = SourceType(data["source_type"])
        data["extraction_status"] = ExtractionStatus(data["extraction_status"])
        data["provenance"] = provenance(data.get("provenance"))
        return SourceRecord(**data)

    def candidate(value: dict[str, Any]) -> CandidateInformation:
        data = dict(value)
        data["confirmation_status"] = ConfirmationStatus(data["confirmation_status"])
        data["provenance"] = provenance(data.get("provenance"))
        return CandidateInformation(**data)

    def transformation(value: dict[str, Any]) -> Transformation:
        data = dict(value)
        data["provenance"] = provenance(data.get("provenance"))
        return Transformation(**data)

    def anomaly(value: dict[str, Any]) -> Anomaly:
        return Anomaly(**value)

    def profile(value: dict[str, Any] | None) -> DataProfile | None:
        return DataProfile(**value) if value is not None else None

    def quality(value: dict[str, Any] | None) -> QualityMetadata:
        return QualityMetadata(**(value or {}))

    data = dict(raw)
    data["sources"] = tuple(source(item) for item in data.get("sources", ()))
    data["candidates"] = tuple(candidate(item) for item in data.get("candidates", ()))
    data["profile"] = profile(data.get("profile"))
    data["quality"] = quality(data.get("quality"))
    data["missingness"] = {str(key): Missingness(value) for key, value in data.get("missingness", {}).items()}
    data["anomalies"] = tuple(anomaly(item) for item in data.get("anomalies", ()))
    data["transformations"] = tuple(transformation(item) for item in data.get("transformations", ()))
    data["confirmation_status"] = ConfirmationStatus(data.get("confirmation_status", ConfirmationStatus.UNCERTAIN.value))
    data.pop("revision", None)
    data.pop("serialized_at", None)
    data.pop("schema_version", None)
    return DataFoundation(**data)


data_foundations = DataFoundationStore()

__all__ = ["DataFoundationStore", "data_foundations"]
