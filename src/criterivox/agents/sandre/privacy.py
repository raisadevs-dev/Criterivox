"""Optional privacy-safe masking for Sandre previews.

Raw source material remains authoritative and untouched. Masking is an
explicit presentation/transformation step for selected sensitive fields.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Iterable

@dataclass(frozen=True, slots=True)
class MaskingResult:
    rows: tuple[dict[str, Any], ...]
    masked_fields: tuple[str, ...]
    source_preserved: bool = True

class PrivacyMasker:
    DEFAULT_FIELD_HINTS = frozenset({"email", "phone", "mobile", "address", "ssn", "aadhaar", "pan", "passport", "dob"})

    def mask(self, rows: Iterable[dict[str, Any]], *, fields: Iterable[str] = (), replacement: str = "[MASKED]") -> MaskingResult:
        requested = {str(v).strip().lower() for v in fields if str(v).strip()}
        masked: set[str] = set()
        output=[]
        for row in rows:
            clean=dict(row)
            for key in list(clean):
                if key.lower() in requested or key.lower() in self.DEFAULT_FIELD_HINTS and requested:
                    clean[key]=replacement
                    masked.add(key)
            output.append(clean)
        return MaskingResult(tuple(output), tuple(sorted(masked)))

    def detect_sensitive_fields(self, rows: Iterable[dict[str, Any]]) -> tuple[str, ...]:
        fields={str(k) for row in rows for k in row}
        return tuple(sorted(k for k in fields if k.lower() in self.DEFAULT_FIELD_HINTS))

__all__=["MaskingResult","PrivacyMasker"]
