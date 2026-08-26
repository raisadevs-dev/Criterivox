from criterivox.config import settings


def test_default_environment():
    assert settings.environment == "development"