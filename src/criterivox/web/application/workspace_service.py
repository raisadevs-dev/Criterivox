from criterivox.web.providers.synthetic import SyntheticProvider


class WorkspaceService:
    """Application-level operations used by the Criterivox UI."""

    def __init__(self, provider: SyntheticProvider) -> None:
        self._provider = provider

    def get_workspace_overview(self) -> dict:
        return self._provider.get_workspace_overview()