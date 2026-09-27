"""Upstream-facing S8 intake contract.

This is the bridge used by the synthetic Criterivox world and future real
component adapters. It deliberately preserves member identity, provenance,
context, and synthetic status instead of pretending arbitrary text is truth.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Mapping


CONTRACT = "criterivox.internal.s8.intake.v1"


@dataclass(frozen=True)
class CriterivoxMessage:
    message_id: str
    sender: str
    message_type: str
    task: str
    context: Mapping[str, Any]
    materials: tuple[Mapping[str, Any], ...] = ()
    provenance: Mapping[str, Any] = None
    synthetic: bool = False

    def __post_init__(self) -> None:
        if not self.message_id.strip() or not self.sender.strip():
            raise ValueError("message_id and sender are required")
        if not self.task.strip():
            raise ValueError("task is required")
        if self.provenance is None:
            object.__setattr__(self, "provenance", {})
        if not isinstance(self.context, Mapping):
            raise ValueError("context must be a mapping")


class S8Intake:
    """Validate internal-language messages without computing their claims."""

    def parse(self, envelope: Mapping[str, Any]) -> CriterivoxMessage:
        if envelope.get("contract") != CONTRACT:
            raise ValueError(f"Unsupported S8 intake contract: {envelope.get('contract')!r}")
        required = ("message_id", "sender", "message_type", "task", "context")
        missing = [key for key in required if key not in envelope]
        if missing:
            raise ValueError(f"S8 intake envelope missing fields: {missing}")
        materials = envelope.get("materials", ())
        if not isinstance(materials, (list, tuple)) or not all(isinstance(item, Mapping) for item in materials):
            raise ValueError("materials must be a list of mappings")
        provenance = envelope.get("provenance", {})
        if not isinstance(provenance, Mapping):
            raise ValueError("provenance must be a mapping")
        return CriterivoxMessage(
            message_id=str(envelope["message_id"]),
            sender=str(envelope["sender"]),
            message_type=str(envelope["message_type"]),
            task=str(envelope["task"]),
            context=dict(envelope["context"]),
            materials=tuple(dict(item) for item in materials),
            provenance=dict(provenance),
            synthetic=bool(envelope.get("synthetic", False)),
        )

    def envelope(self, message: CriterivoxMessage) -> dict[str, Any]:
        return {
            "contract": CONTRACT,
            "message_id": message.message_id,
            "sender": message.sender,
            "message_type": message.message_type,
            "task": message.task,
            "context": dict(message.context),
            "materials": [dict(item) for item in message.materials],
            "provenance": dict(message.provenance),
            "synthetic": message.synthetic,
        }
