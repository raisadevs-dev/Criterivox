from __future__ import annotations

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse

from .orchestrator import ReasoningResearchBureau
from .mechanisms import mechanism_registry

router = APIRouter(prefix="/api/s7", tags=["s7-reasoning-research-bureau"])
bureau = ReasoningResearchBureau()


@router.get("/health")
def health():
    return {"bureau": "Reasoning Research Bureau", "status": "ready", "standalone": True}


@router.get("/mechanisms")
def mechanisms():
    return {
        "mechanisms": [
            {
                "mechanism_id": m.mechanism_id,
                "name": m.name,
                "classification": m.classification,
                "purpose": m.purpose,
                "provenance": m.provenance,
                "limitations": m.limitations,
            }
            for m in mechanism_registry()
        ]
    }


@router.post("/sessions")
def create_session(payload: dict):
    try:
        session = bureau.start(
            str(payload.get("task", "")),
            payload.get("context") if isinstance(payload.get("context"), dict) else {},
        )
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
        session = bureau.challenge(
            session_id,
            str(payload.get("artifact_id", "")),
            str(payload.get("challenge", "")),
        )
        return bureau.snapshot(session.session_id)
    except ValueError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=400)


@router.websocket("/ws")
async def control_websocket(websocket: WebSocket):
    """Runtime preflight/control channel; S7 state remains in the bureau."""
    await websocket.accept()
    try:
        while True:
            message = await websocket.receive_json()
            message_type = str(message.get("type", "")).lower()
            if message_type == "ping":
                await websocket.send_json({"type": "pong", "bureau": "Reasoning Research Bureau"})
            else:
                await websocket.send_json({
                    "type": "control_ack",
                    "accepted": False,
                    "reason": "Unsupported control message",
                })
    except WebSocketDisconnect:
        return
