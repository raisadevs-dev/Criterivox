from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Mapping

@dataclass(frozen=True)
class WorkMaterial:
    material_id: str
    material_type: str
    title: str
    purpose: str
    status: str
    source_service: str
    content: Mapping[str, Any] = field(default_factory=dict)
    structured_data: Mapping[str, Any] = field(default_factory=dict)
    evidence_refs: tuple[str,...] = ()
    provenance_refs: tuple[str,...] = ()
    assumptions: tuple[str,...] = ()
    uncertainty: tuple[str,...] = ()
    limitations: tuple[str,...] = ()
    editable_elements: tuple[str,...] = ()
    challengeable_elements: tuple[str,...] = ()
    dependencies: tuple[str,...] = ()
    version: int = 1
    history: tuple[Mapping[str,Any],...] = ()
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
