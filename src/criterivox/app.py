"""Criterivox application entry point."""

import logging
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from .config import settings
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

def main() -> None:
    """Start the Criterivox application."""
    logger.info(
        "Criterivox application starting in %s mode.",
        settings.environment,
    )


if __name__ == "__main__":
    configure_logging()
    main()