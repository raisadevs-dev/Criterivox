"""Criterivox application entry point."""

import asyncio
import logging

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from .config import settings
from .domain.characters import CharacterState
from .application.data_foundation_store import data_foundations
from .infrastructure.runtime import dharen_runtime, handle_application_request, handle_chat_message, parse_analysis_request, runtime_connections
from .logging_config import configure_logging
from .presentation.contract import PresentationContract
from .ui.routes import router

logger = logging.getLogger(__name__)
app = FastAPI(title="Criterivox")
app.mount("/static", StaticFiles(directory="src/criterivox/ui/static"), name="static")

@app.get("/health")
def health() -> JSONResponse:
    return JSONResponse({"service": "criterivox", "status": "ready", "runtime": "python"})

app.include_router(router)

async def _safe_request(handler, payload: dict) -> None:
    try:
        await handler(payload)
    except Exception as exc:
        logger.exception("Runtime request failed.")
        await runtime_connections.publish(PresentationContract.from_state("Dharen", CharacterState.WARNING, active=True, prominence=.85, message=f"Runtime could not complete that request: {exc}", event="RUNTIME_ERROR"))

async def _safe_data_intake(payload: dict) -> None:
    try:
        foundation = data_foundations.ingest(payload)
        common = dict(foundation_id=foundation.foundation_id, foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates), foundation_confirmation=foundation.confirmation_status.value)
        await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.RECEIVE, active=True, prominence=.9, message=f"Received {len(foundation.sources)} source(s). Preserving the originals before extraction.", event="MATERIAL_RECEIVED", **common))
        await asyncio.sleep(.12)
        await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.WORK, active=True, prominence=.9, message=f"Extracted {len(foundation.candidates)} candidate item(s) with source lineage preserved.", event="EXTRACTION_COMPLETED", **common))
        await asyncio.sleep(.12)
        await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.COMMUNICATE, active=True, prominence=.9, message=f"Review required before handoff. {foundation.quality.anomaly_count} anomaly flag(s), {foundation.quality.missing_count} missingness flag(s), and {foundation.quality.duplicate_count} duplicate candidate(s) detected.", event="USER_CONFIRMATION_REQUIRED", **common))
    except Exception as exc:
        logger.exception("S5 data intake failed.")
        await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.WARNING, active=True, prominence=.9, message=f"Data intake could not be completed: {exc}", event="EXTRACTION_FAILED"))

async def _safe_data_action(payload: dict) -> None:
    try:
        foundation_id = payload.get("foundation_id")
        action = payload.get("action")
        common = lambda f: dict(foundation_id=f.foundation_id, foundation_source_count=len(f.sources), foundation_candidate_count=len(f.candidates), foundation_confirmation=f.confirmation_status.value)
        if action in {"confirm", "correct", "exclude", "add", "irrelevant", "clarify"}:
            foundation = data_foundations.confirm(str(foundation_id), action, tuple(payload.get("candidate_ids", ())))
            await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.COMMUNICATE, active=True, prominence=.9, message=f"Recorded user review as {foundation.confirmation_status.value}. The source remains preserved.", event=f"USER_INFORMATION_{action.upper()}", **common(foundation)))
            return
        if action == "handoff":
            handoff = data_foundations.handoff(str(foundation_id), str(payload.get("recipient", "dharen")))
            await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.HANDOFF, active=True, prominence=.9, message=f"Safeguarded foundation {handoff.foundation_id} is ready for {handoff.recipient}.", event="SANDRE_HANDOFF_READY", foundation_id=handoff.foundation_id, foundation_source_count=len(handoff.source_ids), foundation_candidate_count=len(handoff.canonical_data), foundation_confirmation=handoff.confirmation_status.value))
            await asyncio.sleep(.15)
            await runtime_connections.publish(PresentationContract.from_state("Dharen", CharacterState.RECEIVE, active=True, prominence=.9, message="Dharen received the curated S5 foundation. No unsupported information was added.", event="DHAREN_HANDOFF_READY", foundation_id=handoff.foundation_id, foundation_source_count=len(handoff.source_ids), foundation_candidate_count=len(handoff.canonical_data), foundation_confirmation=handoff.confirmation_status.value))
            return
        raise ValueError("Unsupported S5 data action.")
    except Exception as exc:
        logger.exception("S5 data action failed.")
        await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.WARNING, active=True, prominence=.9, message=f"Sandre could not complete that stewardship action: {exc}", event="DATA_ACTION_FAILED"))

@app.websocket("/runtime/characters")
async def character_runtime(websocket: WebSocket) -> None:
    await runtime_connections.connect(websocket)
    try:
        while True:
            payload = await websocket.receive_json()
            if isinstance(payload, dict) and payload.get("type") == "chat_message":
                asyncio.create_task(_safe_request(handle_chat_message, payload))
            elif isinstance(payload, dict) and payload.get("type") == "data_intake":
                asyncio.create_task(_safe_data_intake(payload))
            elif isinstance(payload, dict) and payload.get("type") == "data_action":
                asyncio.create_task(_safe_data_action(payload))
            elif isinstance(payload, dict) and "intent" in payload:
                asyncio.create_task(_safe_request(handle_application_request, payload))
            else:
                request = parse_analysis_request(payload)
                asyncio.create_task(dharen_runtime.run_analysis(request))
    except WebSocketDisconnect:
        runtime_connections.disconnect(websocket)
    except (ValueError, TypeError):
        await websocket.close(code=1003, reason="Invalid runtime payload")
        runtime_connections.disconnect(websocket)
    except Exception:
        logger.exception("Character runtime connection failed.")
        runtime_connections.disconnect(websocket)

def main() -> None:
    configure_logging()
    logger.info("Criterivox application starting in %s mode.", settings.environment)

if __name__ == "__main__":
    main()
