from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class HumorRecord:
    """Record of previously selected contextual humor."""

    character_id: str
    situation: str
    characteristics: str


class HumorRepetitionController:
    """Prevents the same humor selection from repeating consecutively."""

    def __init__(self) -> None:
        self._last_record: HumorRecord | None = None

    def allow(
        self,
        record: HumorRecord,
    ) -> bool:
        """Return whether this humor record may be used."""

        if not isinstance(record, HumorRecord):
            raise TypeError("Record must be a HumorRecord.")

        if self._last_record == record:
            return False

        return True

    def record(self, record: HumorRecord) -> None:
        """Store the most recently used humor record."""

        if not isinstance(record, HumorRecord):
            raise TypeError("Record must be a HumorRecord.")

        self._last_record = record

    def reset(self) -> None:
        """Clear repetition history."""

        self._last_record = None

    @property
    def last_record(self) -> HumorRecord | None:
        """Return the most recently recorded humor selection."""

        return self._last_record