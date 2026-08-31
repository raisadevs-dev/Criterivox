"""Criterivox application entry point."""

import asyncio
import logging

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.staticfiles import StaticFiles

from .config import settings
from .infrastructure.runtime import (
    dharen_runtime,
    parse_analysis_request,
    runtime_connections,
)
from .logging_config import configure_logging
from .ui.routes import router


logger = logging.getLogger(__name__)

app = FastAPI(title="Criterivox")
app.mount(
    "/static",
    StaticFiles(directory="src/criterivox/ui/static"),
    name="static",
)
app.include_router(router)


@app.websocket("/runtime/characters")
async def character_runtime(websocket: WebSocket) -> None:
    """Bridge validated user actions and Python character state to Flutter."""
    await runtime_connections.connect(websocket)
    try:
        while True:
            payload = await websocket.receive_json()
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
    """Start the Criterivox application."""
    logger.info(
        "Criterivox application starting in %s mode.",
        settings.environment,
    )


if __name__ == "__main__":
    configure_logging()
    main()
