import logging

from criterivox.logging_config import configure_logging


def test_logging_configuration():
    configure_logging()

    logger = logging.getLogger("criterivox.test")

    assert logger.getEffectiveLevel() == logging.INFO