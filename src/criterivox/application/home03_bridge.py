from __future__ import annotations
import asyncio
from typing import Any
from .home03_store import home03_store
from .home03_runtime import home03_runtime

SILENCE={
 'ANALYSIS_REQUESTED':'Dharen received the task and is beginning contextual work.',
 'ANALYSIS_STARTED':'Dharen is actively processing the request.',
 'ANALYSIS_COMPLETED':'Dharen completed the current analysis stage.',
 'CONTEXT_BUILD_RECEIVED':'Dharen received the curated foundation for context construction.',
 'CONTEXT_BUILD_WORKING':'Dharen is structuring context and preserving lineage.',
 'CONTEXT_BUILD_COMPLETE':'Dharen completed contextual structuring.',
 'FOUNDATION_SYNC_ACCEPTED':'Sandre restored the browser foundation as authoritative.',
 'MATERIAL_RECEIVED':'Sandre received new material for stewardship.',
 'EXTRACTION_COMPLETED':'Sandre completed initial material extraction.',
 'HANDOFF_COMPLETED':'A cross-home handoff completed successfully.',
 'RUNTIME_ERROR':'A runtime stage needs attention.'
}

_installed=False

def install(runtime_connections):
 global _installed
 if _installed:return
 original=runtime_connections.publish
 async def publish(contract):
  result=await original(contract)
  try:
   d=contract.to_dict(); event_type=d.get('event') or 'CHARACTER_STATE'; task_id=d.get('task_id') or 'runtime'
   source=d.get('character_id') or d.get('character') or 'runtime'; target=d.get('recipient') or 'Bloom'
   payload={'message':d.get('message'),'state':d.get('state'),'event':event_type,'foundation_id':d.get('foundation_id'),'context_id':d.get('context_id'),'activity':d.get('activity')}
   event=home03_runtime.emit('RUNTIME_HANDOFF',str(task_id),source=source,target=target,payload=payload,confidence=d.get('context_uncertainty') and max(0.0,1.0-float(d.get('context_uncertainty'))) or None,semantic_message=SILENCE.get(event_type,d.get('message') or f'{source} is active.'))
   home03_store.event(event_type,str(task_id),payload);home03_store.pollen(str(task_id),str(source),str(target),payload,event.get('confidence'))
  except Exception:
   pass
  return result
 runtime_connections.publish=publish
 _installed=True
