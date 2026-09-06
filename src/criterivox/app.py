"""Criterivox application entry point."""

import asyncio
import logging

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from .config import settings
from .infrastructure.runtime import (
    dharen_runtime,
    handle_application_request,
    handle_chat_message,
    parse_analysis_request,
    runtime_connections,
)
from .logging_config import configure_logging
from .ui.routes import router

logger = logging.getLogger(__name__)
app = FastAPI(title="Criterivox")
app.mount("/static", StaticFiles(directory="src/criterivox/ui/static"), name="static")


@app.get("/health")
def health() -> JSONResponse:
    return JSONResponse({"service": "criterivox", "status": "ready", "runtime": "python"})


app.include_router(router)


@app.websocket("/runtime/characters")
async def character_runtime(websocket: WebSocket) -> None:
    """Permanent runtime boundary shared by S2, S3, and the S4 workspace/chat surfaces."""
    await runtime_connections.connect(websocket)
    try:
        while True:
            payload = await websocket.receive_json()
            if isinstance(payload, dict) and payload.get("type") == "chat_message":
                asyncio.create_task(handle_chat_message(payload))
            elif isinstance(payload, dict) and "intent" in payload:
                asyncio.create_task(handle_application_request(payload))
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
