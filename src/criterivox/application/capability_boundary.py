from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Callable, Mapping

from criterivox.capabilities.core import CapabilityDescriptor, CapabilityRegistry, CapabilityRequest as S9CapabilityRequest, CapabilityResult, PipelineContext


@dataclass(frozen=True, slots=True)
class CapabilityRequest:
    """Backward-compatible S6 request contract, now routed by the S9 registry."""
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


class _FunctionCapability:
    def __init__(self, name: str, handler: Callable[[Mapping[str, Any]], Mapping[str, Any]]):
        self.descriptor = CapabilityDescriptor(name, name, description="Legacy function capability adapter")
        self._handler = handler

    def execute(self, request: S9CapabilityRequest, context: PipelineContext) -> CapabilityResult:
        return CapabilityResult(request.request_id, request.capability_id, "OK", dict(self._handler(request.payload)))


class InternalCapabilityBoundary:
    """Protocol-neutral compatibility seam backed by the reusable S9 registry."""

    def __init__(self) -> None:
        self._registry = CapabilityRegistry()

    def register(self, name: str, handler: Callable[[Mapping[str, Any]], Mapping[str, Any]]) -> None:
        if not name.strip():
            raise ValueError("Capability name must not be empty.")
        self._registry.replace(_FunctionCapability(name, handler))

    def request(self, request: CapabilityRequest) -> CapabilityResponse:
        try:
            capability = self._registry.get(request.capability)
        except KeyError:
            return CapabilityResponse(request.request_id, "UNSUPPORTED", {"error": "Capability is not registered."})
        result = capability.execute(S9CapabilityRequest(request.request_id, request.capability, dict(request.input), request.authorization), PipelineContext(request.request_id, request.request_id))
        return CapabilityResponse(request.request_id, result.status, result.output, (request.capability,))


__all__ = ["CapabilityRequest", "CapabilityResponse", "InternalCapabilityBoundary"]
