import logging

from criterivox.app import main


def test_application_entry_point(caplog):
    with caplog.at_level(logging.INFO, logger="criterivox.app"):
        main()

    assert "Criterivox application starting" in caplog.text