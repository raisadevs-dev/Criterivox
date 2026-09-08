from __future__ import annotations

from dataclasses import dataclass, replace

from .data_foundation import DataFoundationService
from .data_intake import ingest_folder_path, ingest_sources
from criterivox.domain.data_foundation import DataFoundation


@dataclass
class DataFoundationStore:
    items: dict[str, DataFoundation] | None = None

    def __post_init__(self) -> None:
        if self.items is None:
            self.items = {}

    def ingest(self, payload: dict) -> DataFoundation:
        item = ingest_sources(payload)
        self.items[item.foundation_id] = item
        return item

    def ingest_folder(self, payload: dict) -> DataFoundation:
        item = ingest_folder_path(payload)
        self.items[item.foundation_id] = item
        return item

    def confirm(self, foundation_id: str, action: str, candidate_ids: tuple[str, ...] = ()) -> DataFoundation:
        item = self.get(foundation_id)
        item = DataFoundationService().confirm(item, action=action, candidate_ids=candidate_ids)
        self.items[foundation_id] = item
        return item

    def handoff(self, foundation_id: str, recipient: str = "dharen"):
        item = self.get(foundation_id)
        handoff = DataFoundationService().handoff(item, recipient)
        self.items[foundation_id] = replace(item, handoff_ready=True)
        return handoff

    def get(self, foundation_id: str) -> DataFoundation:
        if not isinstance(foundation_id, str) or foundation_id not in self.items:
            raise ValueError("Unknown data foundation.")
        return self.items[foundation_id]


data_foundations = DataFoundationStore()

__all__ = ["DataFoundationStore", "data_foundations"]