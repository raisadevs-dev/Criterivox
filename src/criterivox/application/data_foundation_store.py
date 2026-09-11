from __future__ import annotations

from dataclasses import dataclass, replace
from datetime import datetime, timezone
from typing import Any

from .data_foundation import DataFoundationService
from .data_intake import ingest_folder_path, ingest_sources
from criterivox.domain.data_foundation import Anomaly, CandidateInformation, ConfirmationStatus, DataFoundation, DataProfile, ExtractionStatus, Missingness, Provenance, QualityMetadata, SourceRecord, SourceType, Transformation


@dataclass
class DataFoundationStore:
    items: dict[str, DataFoundation] | None = None
    revisions: dict[str, int] | None = None

    def __post_init__(self) -> None:
        self.items = self.items or {}
        self.revisions = self.revisions or {}

    def ingest(self, payload: dict) -> DataFoundation:
        item = ingest_sources(payload); self.items[item.foundation_id] = item; self.revisions[item.foundation_id] = self.revisions.get(item.foundation_id, 0) + 1; return item

    def ingest_folder(self, payload: dict) -> DataFoundation:
        item = ingest_folder_path(payload); self.items[item.foundation_id] = item; self.revisions[item.foundation_id] = self.revisions.get(item.foundation_id, 0) + 1; return item

    def confirm(self, foundation_id: str, action: str, candidate_ids: tuple[str, ...] = ()) -> DataFoundation:
        item = DataFoundationService().confirm(self.get(foundation_id), action=action, candidate_ids=candidate_ids); self.items[foundation_id] = item; self.revisions[foundation_id] = self.revision(foundation_id) + 1; return item

    def handoff(self, foundation_id: str, recipient: str = "dharen"):
        item = self.get(foundation_id); handoff = DataFoundationService().handoff(item, recipient); self.items[foundation_id] = replace(item, handoff_ready=True); self.revisions[foundation_id] = self.revision(foundation_id) + 1; return handoff

    def get(self, foundation_id: str) -> DataFoundation:
        if not isinstance(foundation_id, str) or foundation_id not in self.items: raise ValueError("Unknown data foundation.")
        return self.items[foundation_id]

    def revision(self, foundation_id: str) -> int:
        self.get(foundation_id); return self.revisions.get(foundation_id, 1)

    def serialize(self, foundation_id: str) -> dict[str, Any]:
        return {"schema_version": 1, "foundation_id": foundation_id, "revision": self.revision(foundation_id), "serialized_at": datetime.now(timezone.utc).isoformat(), "foundation": self.get(foundation_id).to_dict()}

    def restore_replace(self, envelope: dict[str, Any], *, authoritative: bool = True) -> DataFoundation:
        raw = envelope.get("foundation") if isinstance(envelope, dict) else None
        if not isinstance(raw, dict): raise ValueError("Foundation synchronization requires a serialized foundation object.")
        foundation = _foundation_from_dict(raw); incoming = int(envelope.get("revision", 1)); current = self.items.get(foundation.foundation_id); current_revision = self.revisions.get(foundation.foundation_id, 0)
        if current is not None and incoming < current_revision: raise ValueError(f"Stale foundation revision {incoming}; server has {current_revision}.")
        if current is not None and incoming == current_revision:
            if current.to_dict() != foundation.to_dict(): raise ValueError("Foundation revision conflict: equal revisions contain different material.")
            return current
        if current is not None and not authoritative: return current
        self.items[foundation.foundation_id] = foundation; self.revisions[foundation.foundation_id] = incoming; return foundation


def _foundation_from_dict(raw: dict[str, Any]) -> DataFoundation:
    def provenance(v):
        if v is None: return None
        d = dict(v); d["source_type"] = SourceType(d["source_type"]); return Provenance(**d)
    def source(v):
        d = dict(v); d["source_type"] = SourceType(d["source_type"]); d["extraction_status"] = ExtractionStatus(d["extraction_status"]); d["provenance"] = provenance(d.get("provenance")); return SourceRecord(**d)
    def candidate(v):
        d = dict(v); d["confirmation_status"] = ConfirmationStatus(d["confirmation_status"]); d["provenance"] = provenance(d.get("provenance")); return CandidateInformation(**d)
    def transformation(v):
        d = dict(v); d["provenance"] = provenance(d.get("provenance")); return Transformation(**d)
    d = dict(raw); d["sources"] = tuple(source(v) for v in d.get("sources", ())); d["candidates"] = tuple(candidate(v) for v in d.get("candidates", ())); d["profile"] = DataProfile(**d["profile"]) if d.get("profile") else None; d["quality"] = QualityMetadata(**(d.get("quality") or {})); d["missingness"] = {str(k): Missingness(v) for k, v in d.get("missingness", {}).items()}; d["anomalies"] = tuple(Anomaly(**v) for v in d.get("anomalies", ())); d["transformations"] = tuple(transformation(v) for v in d.get("transformations", ())); d["confirmation_status"] = ConfirmationStatus(d.get("confirmation_status", ConfirmationStatus.UNCERTAIN.value)); return DataFoundation(**d)


data_foundations = DataFoundationStore()
__all__ = ["DataFoundationStore", "data_foundations"]
