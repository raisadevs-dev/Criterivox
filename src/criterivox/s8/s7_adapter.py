"""Contract-only S7 ↔ S8 boundary.

No S7 internals are imported here. The adapter accepts a documented artifact
exchange envelope so S8 can remain a peer subsystem until the concrete S7
contract is finalized in the repository.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Mapping


@dataclass(frozen=True)
class S7ArtifactEnvelope:
    artifact_id: str
    kind: str
    payload: Mapping[str, Any]
    source_ids: tuple[str, ...] = ()
    context_id: str | None = None


class S7Adapter:
    """Validate and normalize only the fields S8 is contractually allowed to consume."""

    REQUIRED = frozenset({"artifact_id", "kind", "payload"})

    def ingest(self, envelope: Mapping[str, Any]) -> S7ArtifactEnvelope:
        missing = self.REQUIRED.difference(envelope.keys())
        if missing:
            raise ValueError(f"S7 exchange envelope missing fields: {sorted(missing)}")
        payload = envelope["payload"]
        if not isinstance(payload, Mapping):
            raise ValueError("S7 exchange payload must be a mapping.")
        sources = envelope.get("source_ids", ())
        if not isinstance(sources, (list, tuple)):
            raise ValueError("S7 source_ids must be a list or tuple.")
        return S7ArtifactEnvelope(
            artifact_id=str(envelope["artifact_id"]),
            kind=str(envelope["kind"]),
            payload=dict(payload),
            source_ids=tuple(str(item) for item in sources),
            context_id=str(envelope["context_id"]) if envelope.get("context_id") is not None else None,
        )

    def export(self, artifact_id: str, kind: str, payload: Mapping[str, Any], *, source_ids: tuple[str, ...] = (), context_id: str | None = None) -> dict[str, Any]:
        return {
            "contract": "criterivox.s7.s8.artifact-exchange.v1",
            "artifact_id": artifact_id,
            "kind": kind,
            "payload": dict(payload),
            "source_ids": source_ids,
            "context_id": context_id,
        }
