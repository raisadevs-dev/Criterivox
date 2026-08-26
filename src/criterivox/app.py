"""Criterivox application entry point."""

import logging

from .config import settings
from .logging_config import configure_logging


logger = logging.getLogger(__name__)


def main() -> None:
    """Start the Criterivox application."""
    logger.info(
        "Criterivox application starting in %s mode.",
        settings.environment,
    )


if __name__ == "__main__":
    configure_logging()
    main()