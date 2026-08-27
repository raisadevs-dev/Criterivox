from criterivox.infrastructure.mock_provider import MockProvider


class NavigationService:
    def __init__(self, provider: MockProvider):
        self.provider = provider

    def get_navigation_context(self) -> dict:
        return self.provider.get_navigation_context()

    def get_primary_capabilities(self) -> list[str]:
        context = self.provider.get_navigation_context()
        return context["capabilities"]

    def get_contextual_options(self, capability: str) -> list[str]:
        return self.provider.get_contextual_options(capability)