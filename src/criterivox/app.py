"""Criterivox application entry point."""

import asyncio
import logging

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from .config import settings
from .domain.characters import CharacterState
from .application.data_foundation_store import data_foundations
from .infrastructure.runtime import (
    dharen_runtime,
    handle_application_request,
    handle_chat_message,
    parse_analysis_request,
    runtime_connections,
)
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
        await runtime_connections.publish(PresentationContract.from_state(
            "Dharen", CharacterState.WARNING, active=True, prominence=.85,
            message=f"Runtime could not complete that request: {exc}", event="RUNTIME_ERROR",
        ))


async def _safe_data_intake(payload: dict) -> None:
    """Run S5 intake and publish truthful Sandre stewardship state."""
    try:
        foundation = data_foundations.ingest(payload)
        await runtime_connections.publish(PresentationContract.from_state(
            "Sandre", CharacterState.RECEIVE, active=True, prominence=.9,
            message=f"Received {len(foundation.sources)} source(s). Preserving the originals before extraction.",
            event="MATERIAL_RECEIVED", foundation_id=foundation.foundation_id,
            foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates),
            foundation_confirmation=foundation.confirmation_status.value,
        ))
        await asyncio.sleep(.12)
        await runtime_connections.publish(PresentationContract.from_state(
            "Sandre", CharacterState.WORK, active=True, prominence=.9,
            message=f"Extracted {len(foundation.candidates)} candidate item(s) with source lineage preserved.",
            event="EXTRACTION_COMPLETED", foundation_id=foundation.foundation_id,
            foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates),
            foundation_confirmation=foundation.confirmation_status.value,
        ))
        await asyncio.sleep(.12)
        await runtime_connections.publish(PresentationContract.from_state(
            "Sandre", CharacterState.COMMUNICATE, active=True, prominence=.9,
            message=(f"Review required before handoff. {foundation.quality.anomaly_count} anomaly flag(s), "
                     f"{foundation.quality.missing_count} missingness flag(s), and {foundation.quality.duplicate_count} duplicate candidate(s) detected."),
            event="USER_CONFIRMATION_REQUIRED", foundation_id=foundation.foundation_id,
            foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates),
            foundation_confirmation=foundation.confirmation_status.value,
        ))
    except Exception as exc:
        logger.exception("S5 data intake failed.")
        await runtime_connections.publish(PresentationContract.from_state(
            "Sandre", CharacterState.WARNING, active=True, prominence=.9,
            message=f"Data intake could not be completed: {exc}", event="EXTRACTION_FAILED",
        ))


async def _safe_data_action(payload: dict) -> None:
    try:
        foundation_id = payload.get("foundation_id")
        action = payload.get("action")
        if action in {"confirm", "correct", "exclude", "add", "irrelevant", "clarify"}:
            foundation = data_foundations.confirm(str(foundation_id), action, tuple(payload.get("candidate_ids", ())))
            await runtime_connections.publish(PresentationContract.from_state(
                "Sandre", CharacterState.COMMUNICATE, active=True, prominence=.9,
                message=f"Recorded user review as {foundation.confirmation_status.value}. The source remains preserved.",
                event=f"USER_INFORMATION_{action.upper()}", foundation_id=foundation.foundation_id,
                foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates),
                foundation_confirmation=foundation.confirmation_status.value,
            ))
            return
        if action == "handoff":
            handoff = data_foundations.handoff(str(foundation_id), str(payload.get("recipient", "dharen")))
            await runtime_connections.publish(PresentationContract.from_state(
                "Sandre", CharacterState.HANDOFF, active=True, prominence=.9,
                message=f"Safeguarded foundation {handoff.foundation_id} is ready for {handoff.recipient}.",
                event="SANDRE_HANDOFF_READY", foundation_id=handoff.foundation_id,
                foundation_source_count=len(handoff.source_ids), foundation_candidate_count=len(handoff.canonical_data),
                foundation_confirmation=handoff.confirmation_status.value,
            ))
            await asyncio.sleep(.15)
            await runtime_connections.publish(PresentationContract.from_state(
                "Dharen", CharacterState.RECEIVE, active=True, prominence=.9,
                message="Dharen received the curated S5 foundation. No unsupported information was added.",
                event="DHAREN_HANDOFF_READY", foundation_id=handoff.foundation_id,
                foundation_source_count=len(handoff.source_ids), foundation_candidate_count=len(handoff.canonical_data),
                foundation_confirmation=handoff.confirmation_status.value,
            ))
            return
        raise ValueError("Unsupported S5 data action.")
    except Exception as exc:
        logger.exception("S5 data action failed.")
        await runtime_connections.publish(PresentationContract.from_state(
            "Sandre", CharacterState.WARNING, active=True, prominence=.9,
            message=f"Sandre could not complete that stewardship action: {exc}", event="DATA_ACTION_FAILED",
        ))


@app.websocket("/runtime/characters")
async def character_runtime(websocket: WebSocket) -> None:
    """Permanent runtime boundary shared by S2, S3, S4 and S5."""
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
