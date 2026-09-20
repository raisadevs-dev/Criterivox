from __future__ import annotations
from dataclasses import dataclass
from .loader import load_capability_registry

@dataclass(frozen=True, slots=True)
class CapabilityMatch:
    capability_id:str
    owner_character:str
    status:str
    reason:str

_INTENT_CAPABILITIES={
 "QUERY_PAST_STATE":"query_current_task_state","QUERY_CURRENT_STATE":"query_current_task_state","QUERY_NEXT_STATE":"query_current_task_state",
 "EXPLAIN":"trace_provenance","SHOW_PROVENANCE":"trace_provenance","VERIFY":"verify_claim","CHALLENGE":"record_human_challenge",
 "RECOMMEND":"produce_recommendation","SHOW_OPTIONS":"build_plan","PREPARE_ACTION":"prepare_action","EXECUTE":"prepare_action","KNOWLEDGE":"synthesize_knowledge",
 "HANDOFF":"transfer_artifact","CHANGE_REQUIREMENT":"adapt_context","CAPABILITY_DISCOVERY":"query_current_task_state",
}
def discover(intent:str, character_id:str|None=None)->tuple[CapabilityMatch,...]:
 reg=load_capability_registry(); cid=_INTENT_CAPABILITIES.get(intent)
 result=[]
 for c in reg.capabilities:
  if cid and c.capability_id!=cid: continue
  if character_id and c.owner_character!=character_id: continue
  result.append(CapabilityMatch(c.capability_id,c.owner_character,c.implementation_status.value,"registry contract"))
 return tuple(result)
