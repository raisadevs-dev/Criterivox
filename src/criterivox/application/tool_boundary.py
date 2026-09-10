from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Mapping, Protocol


@dataclass(frozen=True, slots=True)
class ToolRequest:
    capability: str
    action: str
    arguments: Mapping[str, Any]
    context_id: str | None = None
    evidence_ids: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class ToolResponse:
    capability: str
    action: str
    status: str
    result: Mapping[str, Any]
    evidence_ids: tuple[str, ...] = ()
    provenance_id: str | None = None


class CapabilityHandler(Protocol):
    def __call__(self, request: ToolRequest) -> ToolResponse: ...


class ToolBoundary:
    """MCP-ready internal capability boundary without an MCP dependency.

    The application talks to capabilities through explicit requests and
    responses. A future MCP adapter can translate this contract to MCP tools
    without coupling the domain to a transport protocol.
    """

    def __init__(self) -> None:
        self._handlers: dict[str, CapabilityHandler] = {}

    def register(self, capability: str, handler: CapabilityHandler) -> None:
        key = capability.strip()
        if not key:
            raise ValueError("Capability name must not be empty.")
        if key in self._handlers:
            raise ValueError(f"Capability already registered: {key}")
        self._handlers[key] = handler

    def invoke(self, request: ToolRequest) -> ToolResponse:
        handler = self._handlers.get(request.capability)
        if handler is None:
            return ToolResponse(
                capability=request.capability,
                action=request.action,
                status="UNKNOWN_CAPABILITY",
                result={"error": "Capability is not registered."},
            )
        return handler(request)


__all__ = ["CapabilityHandler", "ToolBoundary", "ToolRequest", "ToolResponse"]
