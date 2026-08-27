from criterivox.application.services.navigation_service import NavigationService
from criterivox.infrastructure.mock_provider import MockProvider


def test_navigation_service_uses_provider():
    provider = MockProvider()
    service = NavigationService(provider)

    capabilities = service.get_primary_capabilities()

    assert "Analyze" in capabilities
    assert "Explain" in capabilities


def test_contextual_options():
    provider = MockProvider()
    service = NavigationService(provider)

    options = service.get_contextual_options("Analyze")

    assert "Performance" in options