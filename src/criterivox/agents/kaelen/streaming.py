from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
import json
from typing import Any, Iterable, Iterator

from .pipeline import KaelenPipeline


@dataclass(frozen=True, slots=True)
class StreamEvent:
    sequence: int
    payload: dict[str, Any]


@dataclass(frozen=True, slots=True)
class StreamCheckpoint:
    sequence: int
    accepted: int
    rejected: int


class StreamIngestor:
    """Bounded in-process streaming ingestion with explicit checkpoints."""

    def __init__(self, start_sequence: int = 0) -> None:
        self._checkpoint = StreamCheckpoint(start_sequence, 0, 0)

    @property
    def checkpoint(self) -> StreamCheckpoint:
        return self._checkpoint

    def ingest(
        self,
        events: Iterable[dict[str, Any] | StreamEvent],
    ) -> Iterator[StreamEvent]:
        for raw in events:
            if isinstance(raw, StreamEvent):
                event = raw
            elif isinstance(raw, dict):
                sequence = int(raw.get("_sequence", self._checkpoint.sequence + 1))
                payload = {k: v for k, v in raw.items() if k != "_sequence"}
                event = StreamEvent(sequence, payload)
            else:
                self._checkpoint = StreamCheckpoint(
                    self._checkpoint.sequence,
                    self._checkpoint.accepted,
                    self._checkpoint.rejected + 1,
                )
                continue

            if event.sequence <= self._checkpoint.sequence:
                self._checkpoint = StreamCheckpoint(
                    self._checkpoint.sequence,
                    self._checkpoint.accepted,
                    self._checkpoint.rejected + 1,
                )
                continue

            self._checkpoint = StreamCheckpoint(
                event.sequence, self._checkpoint.accepted + 1, self._checkpoint.rejected
            )
            yield event

    def reset(self, sequence: int = 0) -> None:
        self._checkpoint = StreamCheckpoint(sequence, 0, 0)


class StreamDAG:
    """Event-by-event DAG execution with inspectable stage outputs."""

    def __init__(self, pipeline: KaelenPipeline | None = None) -> None:
        self.pipeline = pipeline or KaelenPipeline()
        self.nodes = ("ingest", "transform", "handoff")

    def execute(
        self,
        events: Iterable[dict[str, Any] | StreamEvent],
        *,
        expected_schema: list[str] | None = None,
        aliases: dict[str, str] | None = None,
        casts: dict[str, str] | None = None,
    ) -> dict[str, Any]:
        ingestor = StreamIngestor()
        accepted = []
        for event in ingestor.ingest(events):
            result = self.pipeline.execute(
                [event.payload],
                expected_schema=expected_schema,
                aliases=aliases,
                casts=casts,
            )
            accepted.append(
                {
                    "sequence": event.sequence,
                    "data": result["canonical_data"][0] if result["canonical_data"] else {},
                    "schema_patch": result["schema_patch"],
                }
            )
        return {
            "status": "ready",
            "nodes": list(self.nodes),
            "edges": [["ingest", "transform"], ["transform", "handoff"]],
            "events": accepted,
            "checkpoint": {
                "sequence": ingestor.checkpoint.sequence,
                "accepted": ingestor.checkpoint.accepted,
                "rejected": ingestor.checkpoint.rejected,
            },
        }


def event_fingerprint(event: StreamEvent) -> str:
    return sha256(
        json.dumps(event.payload, sort_keys=True, default=str).encode("utf-8")
    ).hexdigest()
