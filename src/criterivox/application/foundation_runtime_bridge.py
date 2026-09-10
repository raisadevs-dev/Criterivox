from __future__ import annotations

import asyncio
from dataclasses import replace
from typing import Any

from criterivox.application.s5_orchestration import analysis_door, delivery_package, is_past_analysis_query, lineage_snapshot, past_analysis_summary, stewardship_door, summoned_members
from criterivox.application.analysis_tasks import analysis_tasks
from criterivox.application.conversation import interpret_message
from criterivox.domain.characters import CharacterState
from criterivox.infrastructure import runtime as runtime_module
from criterivox.infrastructure.runtime import DharenRuntime, runtime_connections
from criterivox.presentation.contract import PresentationContract

_original_publish_task = DharenRuntime.publish_task
_original_chat_message = runtime_module.handle_chat_message

async def _publish_task_with_foundation(self: DharenRuntime, task: Any, *, message: str | None = None, event: str | None = None) -> None:
    foundation = getattr(task, 'data_foundation', None)
    snapshot = None
    if foundation is not None:
        snapshot = lineage_snapshot(foundation, intent_context=getattr(task, 'context', {}))
        task.data = {**task.data, 'lineage_snapshot': snapshot.to_dict()}
        task.context = {**task.context, 'lineage_snapshot': snapshot.to_dict()}
    await _original_publish_task(self, task, message=message, event=event)
    latest = runtime_connections.latest
    updates = {}
    if foundation is not None:
        updates.update(foundation_id=foundation.foundation_id, foundation_material_set_id=foundation.foundation_id, foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates), foundation_confirmation=foundation.confirmation_status.value, lineage_snapshot=snapshot.to_dict() if snapshot else None)
    if task.result is not None and task.is_terminal:
        package = delivery_package(task)
        updates.update(delivery_id=package['delivery_id'], delivery_recipient='viveda', delivery_status='READY_FOR_INSPECTION', door_address=analysis_door(task.task_id).url)
    if updates:
        await runtime_connections.publish(replace(latest, **updates))

async def _orchestrated_chat(payload: dict[str, Any]) -> None:
    message = str(payload.get('message', '')).strip()
    task_id = payload.get('task_id')
    target = str(payload.get('target_character', 'syvax')).lower()
    if target == 'sandre':
        await runtime_connections.publish(PresentationContract.from_state('Sandre', CharacterState.RECEIVE, active=True, prominence=.9, message='Sandre received the stewardship conversation. The current foundation remains the authoritative data context.', event='SANDRE_CHAT_RECEIVED', foundation_id=runtime_connections.latest.foundation_id, door_address=stewardship_door(runtime_connections.latest.foundation_id).url if runtime_connections.latest.foundation_id else None, task_id=str(task_id) if task_id else None))
        if message:
            await runtime_connections.publish(PresentationContract.from_state('Sandre', CharacterState.COMMUNICATE, active=True, prominence=.9, message='Sandre is keeping the conversation tied to the current Data Stewardship foundation and its provenance.', event='SANDRE_CHAT_CONTEXTUALIZED', foundation_id=runtime_connections.latest.foundation_id, door_address=stewardship_door(runtime_connections.latest.foundation_id).url if runtime_connections.latest.foundation_id else None, task_id=str(task_id) if task_id else None))
        return
    if is_past_analysis_query(message):
        rows = past_analysis_summary()
        if rows:
            parts = [f"{r['task_id']}: {r['summary']}" for r in rows[:5]]
            first = rows[0]['task_id']
            await runtime_connections.publish(PresentationContract.from_state('Syvax', CharacterState.COMMUNICATE, active=True, prominence=.9, message='I queried Dharen\'s stored analysis tasks. ' + ' | '.join(parts), event='SYVAX_PAST_ANALYSIS_QUERIED', task_id=first, door_address=analysis_door(first).url))
        else:
            await runtime_connections.publish(PresentationContract.from_state('Syvax', CharacterState.COMMUNICATE, active=True, prominence=.9, message='I queried Dharen\'s analysis task store, but there are no stored past analyses matching the current request.', event='SYVAX_PAST_ANALYSIS_QUERIED'))
        return
    members = summoned_members(message)
    if len(members) >= 2:
        coordination_id = f"coord-{id(payload)}"
        await runtime_connections.publish(PresentationContract.from_state('Syvax', CharacterState.HANDOFF, active=True, prominence=.9, message=f"Temporary micro-channel opened for: {', '.join(m.title() for m in members)}. Shared task context remains authoritative in the application runtime.", event='SYVAX_MULTI_MEMBER_SUMMONED', task_id=str(task_id) if task_id else None, coordination_id=coordination_id, coordination_members=members))
        for member in members:
            await runtime_connections.publish(PresentationContract.from_state(member.title(), CharacterState.RECEIVE, active=True, prominence=.8, message=f'{member.title()} joined the temporary coordination channel.', event='MEMBER_SUMMONED', task_id=str(task_id) if task_id else None, coordination_id=coordination_id, coordination_members=members))
        return
    await _original_chat_message(payload)
    latest = runtime_connections.latest
    if latest.foundation_id:
        await runtime_connections.publish(replace(latest, message=(latest.message or '') + f" Open Sandre's Data Stewardship door: {stewardship_door(latest.foundation_id).url}", event='SYVAX_STEWARDSHIP_DOOR', door_address=stewardship_door(latest.foundation_id).url))
    if target == 'syvax' and interpret_message(message).intent == 'analyze' and latest.task_id:
        task = analysis_tasks.get_task(latest.task_id)
        await runtime_connections.publish(PresentationContract.from_state('Syvax', CharacterState.HANDOFF, active=True, prominence=.9, message='Syvax assigned the analysis task to Dharen and passed the current task context automatically.', event='SYVAX_AUTO_ASSIGN_DHAREN', task_id=task.task_id, door_address=analysis_door(task.task_id).url))
        await runtime_connections.publish(PresentationContract.from_state('Dharen', CharacterState.RECEIVE, active=True, prominence=.9, message='Dharen received the task from Syvax.', event='SYVAX_HANDOFF_COMPLETED', task_id=task.task_id, door_address=analysis_door(task.task_id).url))
        if not task.is_terminal:
            asyncio.create_task(analysis_tasks.execute(task.task_id))

runtime_module.handle_chat_message = _orchestrated_chat
DharenRuntime.publish_task = _publish_task_with_foundation
__all__ = ['delivery_package']
