from __future__ import annotations

import asyncio
import json
from dataclasses import dataclass, field
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, ValidationError

from criterivox.domain.characters import (
    CHARACTER_REGISTRY,
    CharacterActivityManager,
    CharacterState,
)
from criterivox.presentation.contract import PresentationContract


class AnalysisRequest(BaseModel):
    """Validated user input crossing the Flutter → Python boundary."""

    model_config = ConfigDict(extra="forbid")

    data: dict[str, Any] = Field(default_factory=dict)
    context: dict[str, Any] = Field(default_factory=dict)
    task: str = Field(min_length=1, max_length=500)


@dataclass
class RuntimeConnectionManager:
    """Small in-process WebSocket broadcaster for the local S2 runtime."""

    clients: set[Any] = field(default_factory=set)
    latest: PresentationContract = field(
        default_factory=lambda: PresentationContract.from_state(
            "Dharen",
            CharacterState.IDLE,
            active=False,
            prominence=0.25,
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
    """Executes the first real Python → presentation character slice."""

    def __init__(self, connection_manager: RuntimeConnectionManager) -> None:
        self._connections = connection_manager
        self._activity = CharacterActivityManager(CHARACTER_REGISTRY.get_all())
        self._lock = asyncio.Lock()

    async def run_analysis(self, request: AnalysisRequest) -> None:
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

    def _perform_synthetic_analysis(
        self,
        request: AnalysisRequest,
    ) -> dict[str, int]:
        """Perform real deterministic work without claiming intelligence."""
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
