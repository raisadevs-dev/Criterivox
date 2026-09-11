from __future__ import annotations

from dataclasses import dataclass, replace
from datetime import datetime, timezone
from typing import Any

from .data_foundation import DataFoundationService
from .data_intake import ingest_folder_path, ingest_sources
from criterivox.domain.data_foundation import DataFoundation


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
        """Return a complete JSON-safe foundation envelope for browser persistence."""
        foundation = self.get(foundation_id)
        return {
            "schema_version": 1,
            "foundation_id": foundation.foundation_id,
            "revision": self.revision(foundation_id),
            "serialized_at": datetime.now(timezone.utc).isoformat(),
            "foundation": foundation.model_dump(mode="json") if hasattr(foundation, "model_dump") else _dataclass_json(foundation),
        }

    def restore_replace(self, envelope: dict[str, Any], *, authoritative: bool = True) -> DataFoundation:
        """Restore a browser-recovered foundation and make it the active server copy.

        The incoming revision must not be older than the server revision. Equal
        revisions are accepted idempotently only when the foundation is equivalent.
        """
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
        if current is not None and incoming_revision == current_revision and current != foundation:
            raise ValueError("Foundation revision conflict: equal revisions contain different material.")
        if not authoritative and current is not None:
            return current
        self.items[foundation_id] = foundation
        self.revisions[foundation_id] = incoming_revision
        return foundation


def _dataclass_json(value: Any) -> dict[str, Any]:
    from dataclasses import asdict
    return asdict(value)


def _foundation_from_dict(raw: dict[str, Any]) -> DataFoundation:
    """Rehydrate the Pydantic domain model without silently dropping fields."""
    if hasattr(DataFoundation, "model_validate"):
        try:
            return DataFoundation.model_validate(raw)
        except Exception as exc:
            raise ValueError("Serialized DataFoundation failed domain validation.") from exc
    raise ValueError("DataFoundation domain model does not support restoration.")


data_foundations = DataFoundationStore()

__all__ = ["DataFoundationStore", "data_foundations"]
