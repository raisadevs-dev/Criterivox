from __future__ import annotations

import asyncio
import json
from dataclasses import dataclass, field
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, ValidationError, model_validator

from criterivox.application.contracts import ApplicationRequest
from criterivox.application.service import UnsupportedCapabilityError, application_service
from criterivox.domain.characters import (
    CHARACTER_REGISTRY,
    CharacterActivityManager,
    CharacterState,
)
from criterivox.presentation.contract import PresentationContract


class AnalysisRequest(BaseModel):
    """Legacy S2 request kept for runtime compatibility."""

    model_config = ConfigDict(extra="forbid")

    data: dict[str, Any] = Field(default_factory=dict)
    context: dict[str, Any] = Field(default_factory=dict)
    task: str = Field(min_length=1, max_length=500)

    @model_validator(mode="after")
    def validate_payload_size(self) -> "AnalysisRequest":
        if len(self.data) > 1000 or len(self.context) > 1000:
            raise ValueError("Runtime payload contains too many top-level fields.")
        if len(json.dumps(self.model_dump(), default=str)) > 32_000:
            raise ValueError("Runtime payload is too large.")
        return self


@dataclass
class RuntimeConnectionManager:
    """Permanent local WebSocket runtime boundary for Criterivox."""

    clients: set[Any] = field(default_factory=set)
    latest: PresentationContract = field(
        default_factory=lambda: PresentationContract.from_state(
            "Dharen", CharacterState.IDLE, active=False, prominence=0.25
        )
    )

    async def connect(self, websocket: Any) -> None:
        await websocket.accept()
        self.clients.add(websocket)
        await websocket.send_text(json.dumps(self.latest.to_dict()))

    def disconnect(self, websocket: Any) -> None:
        self.clients.discard(websocket)

    async def publish(self, contract: PresentationContract) -> None:
        self.latest = contract
        message = json.dumps(contract.to_dict())
        disconnected: list[Any] = []
        for client in tuple(self.clients):
            try:
                await client.send_text(message)
            except Exception:
                disconnected.append(client)
        for client in disconnected:
            self.disconnect(client)


class DharenRuntime:
    """Executes the permanent Python → presentation character slice."""

    def __init__(self, connection_manager: RuntimeConnectionManager) -> None:
        self._connections = connection_manager
        self._activity = CharacterActivityManager(CHARACTER_REGISTRY.get_all())
        self._lock = asyncio.Lock()

    async def run_analysis(
        self,
        request: AnalysisRequest,
        *,
        result: dict[str, Any] | None = None,
    ) -> None:
        async with self._lock:
            await self._transition(
                CharacterState.RECEIVE,
                event="ANALYSIS_REQUESTED",
                message="Dharen received the analysis request.",
            )
            await asyncio.sleep(0.25)

            await self._transition(
                CharacterState.WORK,
                event="ANALYSIS_STARTED",
                message="Dharen is analyzing the supplied data in context.",
            )
            if result is None:
                result = self._perform_synthetic_analysis(request)
            await asyncio.sleep(0.75)

            await self._transition(
                CharacterState.COMMUNICATE,
                event="ANALYSIS_COMPLETED",
                message=(
                    "Analysis completed: "
                    f"{result['data_items']} data items across "
                    f"{result['data_fields']} fields; "
                    f"{result['context_fields']} context fields considered."
                ),
            )
            await asyncio.sleep(0.35)
            await self._transition(
                CharacterState.COMPLETE,
                event="ANALYSIS_COMPLETED",
                message="Dharen completed the requested analysis.",
            )
            await asyncio.sleep(0.35)
            await self._transition(
                CharacterState.IDLE,
                active=False,
                prominence=0.25,
                event=None,
                message=None,
            )

    @staticmethod
    def _perform_synthetic_analysis(request: AnalysisRequest) -> dict[str, int]:
        data_items = len(request.data)
        data_fields = sum(
            len(item) if isinstance(item, dict) else 1
            for item in request.data.values()
        )
        return {
            "data_items": data_items,
            "data_fields": data_fields,
            "context_fields": len(request.context),
        }

    async def _transition(
        self,
        state: CharacterState,
        *,
        active: bool = True,
        prominence: float = 0.75,
        event: str | None,
        message: str | None,
    ) -> None:
        activity = self._activity.set_state("Dharen", state)
        contract = PresentationContract.from_state(
            activity.character_id,
            activity.state,
            active=active,
            prominence=prominence,
            message=message,
            event=event,
        )
        await self._connections.publish(contract)


runtime_connections = RuntimeConnectionManager()
dharen_runtime = DharenRuntime(runtime_connections)


def parse_analysis_request(payload: Any) -> AnalysisRequest:
    try:
        return AnalysisRequest.model_validate(payload)
    except ValidationError as exc:
        raise ValueError("Invalid analysis request.") from exc


def parse_application_request(payload: Any) -> ApplicationRequest:
    try:
        return ApplicationRequest.model_validate(payload)
    except ValidationError as exc:
        raise ValueError("Invalid application request.") from exc


async def handle_application_request(payload: Any) -> None:
    request = parse_application_request(payload)
    result = application_service.handle(request)
    analysis_request = AnalysisRequest(
        data=request.data,
        context=request.context,
        task=request.task,
    )
    await dharen_runtime.run_analysis(analysis_request, result=result.data)


__all__ = [
    "AnalysisRequest",
    "DharenRuntime",
    "RuntimeConnectionManager",
    "dharen_runtime",
    "handle_application_request",
    "parse_analysis_request",
    "parse_application_request",
    "runtime_connections",
    "UnsupportedCapabilityError",
]
