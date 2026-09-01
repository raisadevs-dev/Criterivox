from __future__ import annotations

from typing import Any, Protocol


class AnalysisProvider(Protocol):
    """Provider boundary for deterministic or future intelligence analysis."""

    def analyze(
        self,
        *,
        data: dict[str, Any],
        context: dict[str, Any],
        task: str,
    ) -> dict[str, Any]: ...


class DeterministicAnalysisProvider:
    """Current synthetic provider. No intelligence claim is made."""

    def analyze(
        self,
        *,
        data: dict[str, Any],
        context: dict[str, Any],
        task: str,
    ) -> dict[str, Any]:
        del task
        data_items = len(data)
        data_fields = sum(
            len(item) if isinstance(item, dict) else 1
            for item in data.values()
        )
        return {
            "data_items": data_items,
            "data_fields": data_fields,
            "context_fields": len(context),
        }


__all__ = ["AnalysisProvider", "DeterministicAnalysisProvider"]
