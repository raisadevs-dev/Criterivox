"""Allow Criterivox to be executed with python -m criterivox."""

from .app import main
from .logging_config import configure_logging


if __name__ == "__main__":
    configure_logging()
    main()