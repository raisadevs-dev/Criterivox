from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from typing import Any


@dataclass(frozen=True, slots=True)
class ScratchpadEntry:
    key: str
    value: Any
    created_at: datetime


@dataclass
class KaelenScratchpad:
    """Kaelen-owned facade over temporary build/experimentation state."""

    ttl: timedelta = timedelta(hours=24)
    _entries: dict[str, ScratchpadEntry] = field(default_factory=dict)

    def write(self, key: str, value: Any) -> None:
        key = key.strip()
        if not key:
            raise ValueError("Scratchpad key must not be empty.")
        self._entries[key] = ScratchpadEntry(key, value, datetime.now(timezone.utc))

    def cleanup(self, *, signed_off: bool = False) -> tuple[str, ...]:
        now = datetime.now(timezone.utc)
        removed = []
        for key, entry in list(self._entries.items()):
            if signed_off or now - entry.created_at >= self.ttl:
                removed.append(key)
                del self._entries[key]
        return tuple(sorted(removed))

    def snapshot(self) -> dict[str, Any]:
        self.cleanup()
        return {
            key: {
                "value": entry.value,
                "created_at": entry.created_at.isoformat(),
            }
            for key, entry in self._entries.items()
        }

    def sign_off(self) -> tuple[str, ...]:
        return self.cleanup(signed_off=True)
