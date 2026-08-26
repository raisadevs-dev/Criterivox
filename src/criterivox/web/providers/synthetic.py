class SyntheticProvider:
    """Controlled S1 data provider.

    This provider exists only to supply deterministic synthetic data
    while the real domain and persistence layers are deferred.
    """

    def get_workspace_overview(self) -> dict:
        return {
            "project": {
                "name": "Criterivox Research Workspace",
                "status": "Active",
            },
            "context": {
                "name": "Cross-platform content study",
                "status": "Configured",
            },
            "dataset": {
                "name": "Synthetic Content Dataset",
                "items": 128,
            },
            "intelligence": {
                "status": "Demonstration",
                "finding_count": 4,
            },
            "explanation": {
                "status": "Available",
                "evidence_count": 7,
            },
        }