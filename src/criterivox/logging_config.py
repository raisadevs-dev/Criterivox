"""Logging configuration for Criterivox."""

import logging


def configure_logging(level: int = logging.INFO) -> None:
    """Configure application-wide logging."""
    root_logger = logging.getLogger()

    root_logger.setLevel(level)

    if not root_logger.handlers:
        logging.basicConfig(
            level=level,
            format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
        )