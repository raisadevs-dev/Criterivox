from __future__ import annotations

from dataclasses import replace
from typing import Any

from criterivox.infrastructure.runtime import DharenRuntime, runtime_connections

_original_publish_task = DharenRuntime.publish_task


async def _publish_task_with_foundation(self: DharenRuntime, task: Any, *, message: str | None = None, event: str | None = None) -> None:
    await _original_publish_task(self, task, message=message, event=event)
    foundation = getattr(task, 'data_foundation', None)
    if foundation is None:
        return
    latest = runtime_connections.latest
    enriched = replace(
        latest,
        foundation_id=foundation.foundation_id,
        foundation_source_count=len(foundation.sources),
        foundation_candidate_count=len(foundation.candidates),
        foundation_confirmation=foundation.confirmation_status.value,
    )
    await runtime_connections.publish(enriched)


DharenRuntime.publish_task = _publish_task_with_foundation
