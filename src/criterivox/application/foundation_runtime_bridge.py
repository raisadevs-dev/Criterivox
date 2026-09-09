from __future__ import annotations

import asyncio
from dataclasses import replace
from typing import Any

from criterivox.application.s5_orchestration import (
    analysis_door,
    delivery_package,
    is_past_analysis_query,
    lineage_snapshot,
    past_analysis_summary,
    stewardship_door,
    summoned_members,
)
from criterivox.domain.characters import CharacterState
from criterivox.infrastructure import runtime as runtime_module
from criterivox.infrastructure.runtime import DharenRuntime, runtime_connections
from criterivox.presentation.contract import PresentationContract

_original_publish_task = DharenRuntime.publish_task
_original_chat_message = runtime_module.handle_chat_message

async def _publish_task_with_foundation(self: DharenRuntime, task: Any, *, message: str | None = None, event: str | None = None) -> None:
    foundation = getattr(task, 'data_foundation', None)
    if foundation is not None:
        snapshot = lineage_snapshot(foundation, intent_context=getattr(task, 'context', {}))
        task.data = {**task.data, 'lineage_snapshot': snapshot.to_dict()}
        task.context = {**task.context, 'lineage_snapshot': snapshot.to_dict()}
    await _original_publish_task(self, task, message=message, event=event)
    if foundation is None:
        return
    latest = runtime_connections.latest
    enriched = replace(
        latest,
        foundation_id=foundation.foundation_id,
        foundation_material_set_id=foundation.foundation_id,
        foundation_source_count=len(foundation.sources),
        foundation_candidate_count=len(foundation.candidates),
        foundation_confirmation=foundation.confirmation_status.value,
    )
    await runtime_connections.publish(enriched)

async def _orchestrated_chat(payload: dict[str, Any]) -> None:
    message = str(payload.get('message', '')).strip()
    task_id = payload.get('task_id')

    # Syvax can query the authoritative task store for previous work.
    if is_past_analysis_query(message):
        rows = past_analysis_summary()
        if rows:
            parts = [f"{r['task_id']}: {r['summary']}" for r in rows[:5]]
            first = rows[0]['task_id']
            door = analysis_door(first)
            await runtime_connections.publish(PresentationContract.from_state(
                'Syvax', CharacterState.COMMUNICATE, active=True, prominence=.9,
                message='I queried Dharen\'s stored analysis tasks. ' + ' | '.join(parts),
                event='SYVAX_PAST_ANALYSIS_QUERIED', task_id=first,
                door_address=door.url,
            ))
        else:
            await runtime_connections.publish(PresentationContract.from_state(
                'Syvax', CharacterState.COMMUNICATE, active=True, prominence=.9,
                message='I queried Dharen\'s analysis task store, but there are no stored past analyses matching the current request.',
                event='SYVAX_PAST_ANALYSIS_QUERIED',
            ))
        return

    # Explicit multi-member summons create a bounded temporary coordination event.
    members = summoned_members(message)
    if len(members) >= 2:
        await runtime_connections.publish(PresentationContract.from_state(
            'Syvax', CharacterState.HANDOFF, active=True, prominence=.9,
            message=f"Temporary micro-channel opened for: {', '.join(m.title() for m in members)}. Shared task context remains authoritative in the application runtime.",
            event='SYVAX_MULTI_MEMBER_SUMMONED', task_id=str(task_id) if task_id else None,
        ))
        for member in members:
            await runtime_connections.publish(PresentationContract.from_state(
                member, CharacterState.RECEIVE, active=True, prominence=.8,
                message=f'{member.title()} joined the temporary coordination channel.',
                event='MEMBER_SUMMONED', task_id=str(task_id) if task_id else None,
            ))
        return

    # The existing handler already sends attached chat material into the shared
    # Sandre foundation before downstream work. Keep that behavior and surface
    # an explicit Sandre door address after the original handler has processed it.
    await _original_chat_message(payload)
    latest = runtime_connections.latest
    foundation_id = getattr(latest, 'foundation_id', None)
    if foundation_id:
        door = stewardship_door(foundation_id)
        if str(payload.get('target_character', 'syvax')).lower() == 'syvax':
            await runtime_connections.publish(replace(
                latest,
                message=(latest.message or '') + f" Open Sandre's Data Stewardship door: {door.url}",
                event='SYVAX_STEWARDSHIP_DOOR',
            ))

# Runtime imports this bridge during application startup, so replacing the
# handler here keeps the existing WebSocket boundary while adding S5 behavior.
runtime_module.handle_chat_message = _orchestrated_chat
DharenRuntime.publish_task = _publish_task_with_foundation

__all__ = ['delivery_package']
