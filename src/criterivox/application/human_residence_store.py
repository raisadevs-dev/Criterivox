"""Local-first Human Residence persistence for the S6 presentation boundary."""
from __future__ import annotations

import json
import threading
from pathlib import Path
from typing import Any


class HumanResidenceStore:
    """Safe residence metadata mirror.

    This intentionally stores no password, authentication token, or secret.
    The browser IndexedDB copy remains the local recovery boundary; Python
    keeps the latest connected runtime mirror so a process restart can reload
    the most recent residence envelope supplied by the browser.
    """

    def __init__(self, path: str | Path = "data/runtime/human_residences.json") -> None:
        self.path = Path(path)
        self._lock = threading.RLock()
        self._records: dict[str, dict[str, Any]] = {}
        self._load()

    def _load(self) -> None:
        with self._lock:
            if not self.path.exists():
                return
            try:
                raw = json.loads(self.path.read_text(encoding="utf-8"))
                self._records = {str(k): dict(v) for k, v in raw.get("records", {}).items()}
            except (OSError, ValueError, TypeError):
                self._records = {}

    @staticmethod
    def _safe(record: dict[str, Any]) -> dict[str, Any]:
        allowed = {"residence_id", "owner_id", "display_name", "email", "residence_type", "created_at", "members", "metadata", "updated_at"}
        clean = {k: record[k] for k in allowed if k in record}
        clean["members"] = list(clean.get("members", []))
        clean["metadata"] = dict(clean.get("metadata", {}))
        clean.pop("password", None)
        clean.pop("password_hash", None)
        clean.pop("token", None)
        clean.pop("access_token", None)
        clean.pop("refresh_token", None)
        return clean

    def upsert(self, record: dict[str, Any]) -> dict[str, Any]:
        clean = self._safe(record)
        residence_id = str(clean.get("residence_id", "")).strip()
        owner_id = str(clean.get("owner_id", "")).strip()
        if not residence_id or not owner_id:
            raise ValueError("residence_id and owner_id are required")
        if clean.get("residence_type") not in {"private", "club"}:
            raise ValueError("residence_type must be private or club")
        with self._lock:
            self._records[residence_id] = clean
            self.path.parent.mkdir(parents=True, exist_ok=True)
            self.path.write_text(json.dumps({"version": 1, "records": self._records}, indent=2, sort_keys=True, default=str), encoding="utf-8")
            return dict(clean)

    def get(self, residence_id: str) -> dict[str, Any] | None:
        with self._lock:
            value = self._records.get(str(residence_id))
            return dict(value) if value else None

    def by_owner(self, owner_id: str) -> list[dict[str, Any]]:
        with self._lock:
            return [dict(v) for v in self._records.values() if v.get("owner_id") == str(owner_id)]


human_residences = HumanResidenceStore()
