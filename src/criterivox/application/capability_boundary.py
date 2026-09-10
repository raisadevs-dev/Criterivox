from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Callable, Mapping


@dataclass(frozen=True, slots=True)
class CapabilityRequest:
    request_id: str
    capability: str
    input: Mapping[str, Any]
    authorization: str = "local-user-runtime"


@dataclass(frozen=True, slots=True)
class CapabilityResponse:
    request_id: str
    status: str
    output: Mapping[str, Any]
    provenance: tuple[str, ...] = ()


class InternalCapabilityBoundary:
    """Protocol-neutral capability seam. MCP can be an adapter, not a dependency."""

    def __init__(self) -> None:
        self._handlers: dict[str, Callable[[Mapping[str, Any]], Mapping[str, Any]]] = {}

    def register(self, name: str, handler: Callable[[Mapping[str, Any]], Mapping[str, Any]]) -> None:
        if not name.strip():
            raise ValueError("Capability name must not be empty.")
        self._handlers[name] = handler

    def request(self, request: CapabilityRequest) -> CapabilityResponse:
        handler = self._handlers.get(request.capability)
        if handler is None:
            return CapabilityResponse(request.request_id, "UNSUPPORTED", {"error": "Capability is not registered."})
        result = handler(request.input)
        return CapabilityResponse(request.request_id, "OK", dict(result), provenance=(request.capability,))


__all__ = ["CapabilityRequest", "CapabilityResponse", "InternalCapabilityBoundary"]
