from __future__ import annotations

import asyncio
import json
from typing import Any

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse

from .orchestrator import ReasoningResearchBureau
from .mechanisms import mechanism_registry

router = APIRouter(prefix="/api/s7", tags=["s7-reasoning-research-bureau"])
bureau = ReasoningResearchBureau()


@router.get("/health")
def health():
    return {"bureau": "Reasoning Research Bureau", "status": "ready", "standalone": True, "websocket": True}


@router.get("/mechanisms")
def mechanisms():
    return {"mechanisms": [{"mechanism_id": m.mechanism_id, "name": m.name, "classification": m.classification, "purpose": m.purpose, "provenance": m.provenance, "limitations": m.limitations} for m in mechanism_registry()]}


@router.post("/sessions")
def create_session(payload: dict):
    try:
        session = bureau.start(str(payload.get("task", "")), payload.get("context") if isinstance(payload.get("context"), dict) else {})
        return bureau.snapshot(session.session_id)
    except ValueError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=400)


@router.get("/sessions/{session_id}")
def get_session(session_id: str):
    try:
        return bureau.snapshot(session_id)
    except ValueError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=404)


@router.post("/sessions/{session_id}/challenge")
def challenge(session_id: str, payload: dict):
    try:
        session = bureau.challenge(session_id, str(payload.get("artifact_id", "")), str(payload.get("challenge", "")))
        return bureau.snapshot(session.session_id)
    except ValueError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=400)


class S7WebSocketHub:
    """Small standalone S7 event bridge; computation remains owned by the bureau."""

    def __init__(self) -> None:
        self._connections: set[WebSocket] = set()

    async def connect(self, websocket: WebSocket) -> None:
        await websocket.accept()
        self._connections.add(websocket)

    def disconnect(self, websocket: WebSocket) -> None:
        self._connections.discard(websocket)

    async def publish(self, message: dict[str, Any]) -> None:
        dead: list[WebSocket] = []
        for connection in tuple(self._connections):
            try:
                await connection.send_json(message)
            except Exception:
                dead.append(connection)
        for connection in dead:
            self.disconnect(connection)


websocket_hub = S7WebSocketHub()


@router.websocket("/ws")
async def s7_websocket(websocket: WebSocket):
    """Standalone bidirectional S7 control/event channel.

    Supported messages:
      {"type":"subscribe","session_id":"..."}
      {"type":"snapshot","session_id":"..."}
      {"type":"challenge","session_id":"...","artifact_id":"...","challenge":"..."}
      {"type":"ping"}

    WebSocket is transport only. The bureau remains the source of computational truth.
    """
    await websocket_hub.connect(websocket)
    subscriptions: set[str] = set()
    try:
        await websocket.send_json({"type": "connected", "service": "reasoning-research-bureau"})
        while True:
            raw = await websocket.receive_text()
            message = json.loads(raw)
            message_type = str(message.get("type", ""))

            if message_type == "ping":
                await websocket.send_json({"type": "pong"})
                continue

            session_id = str(message.get("session_id", ""))
            if message_type == "subscribe":
                if not session_id:
                    await websocket.send_json({"type": "error", "error": "session_id is required"})
                    continue
                bureau.snapshot(session_id)
                subscriptions.add(session_id)
                await websocket.send_json({"type": "subscribed", "session_id": session_id, "snapshot": bureau.snapshot(session_id)})
                continue

            if message_type == "snapshot":
                await websocket.send_json({"type": "snapshot", "session": bureau.snapshot(session_id)})
                continue

            if message_type == "challenge":
                session = bureau.challenge(session_id, str(message.get("artifact_id", "")), str(message.get("challenge", "")))
                snapshot = bureau.snapshot(session.session_id)
                await websocket.send_json({"type": "session_updated", "session": snapshot})
                await websocket_hub.publish({"type": "s7_event", "session_id": session.session_id, "event": "HUMAN_CHALLENGE", "session": snapshot})
                continue

            await websocket.send_json({"type": "error", "error": f"Unsupported WebSocket message type: {message_type}"})
    except (WebSocketDisconnect, json.JSONDecodeError, ValueError):
        websocket_hub.disconnect(websocket)
    except Exception:
        websocket_hub.disconnect(websocket)
