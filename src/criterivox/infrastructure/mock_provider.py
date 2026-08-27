class MockProvider:
    def get_navigation_context(self) -> dict:
        return {
            "context": "home",
            "capabilities": [
                "Analyze",
                "Compare",
                "Explore",
                "Explain",
            ],
        }

    def get_contextual_options(self, capability: str) -> list[str]:
        options = {
            "Analyze": ["Performance", "Audience", "Content"],
            "Compare": ["Content", "Platforms", "Periods"],
            "Explore": ["Insights", "Patterns", "Observations"],
            "Explain": ["Reasoning", "Evidence", "Factors"],
        }

        return options.get(capability, [])