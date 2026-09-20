from __future__ import annotations
from dataclasses import dataclass
from typing import Any
from .language import interpret, LanguageResult
from .capability_discovery import discover, CapabilityMatch
from criterivox.application.state_runtime import state_runtime
from criterivox.application.state_chat import respond_state_query
from criterivox.application.conversation import ConversationInterpretation
from .set4 import Set4Runtime

@dataclass(frozen=True, slots=True)
class RuntimeResponse:
 machine:dict[str,Any]
 human_text:str
 language:LanguageResult
 capabilities:tuple[CapabilityMatch,...]

class UnifiedCharacterRuntime:
 def __init__(self,set4=None): self.set4=set4 or Set4Runtime()
 def handle(self,message:str,*,task_id:str|None=None,character_id:str|None=None,journey_id:str|None=None)->RuntimeResponse:
  lang=interpret(message)
  caps=discover(lang.intent,character_id)
  if lang.ambiguous:
   return RuntimeResponse({"intent":lang.intent,"entities":lang.entities,"capability":None,"authorization":"NOT_REQUIRED","status":"CLARIFICATION_REQUIRED","state_source":"language_layer"},lang.clarification or "Please clarify the requested operation.",lang,caps)
  if lang.intent in {"QUERY_PAST_STATE","QUERY_CURRENT_STATE","QUERY_NEXT_STATE"} and task_id:
   mapping={"QUERY_PAST_STATE":"history","QUERY_CURRENT_STATE":"current","QUERY_NEXT_STATE":"next"}
   interp=ConversationInterpretation(intent=mapping[lang.intent],normalized_text=lang.normalized_text,entities=tuple(lang.entities.values()))
   text,data=respond_state_query(task_id,interp)
   return RuntimeResponse({"intent":lang.intent,"entities":lang.entities,"capability":"query_current_task_state","state_source":"runtime_checkpoint","authorization":"NOT_REQUIRED","workflow_outcome":"checkpoint_inspected","status":data.get("status")},text,lang,caps)
  if lang.intent in {"PAUSE","RESUME"} and task_id:
   result=state_runtime.pause(task_id) if lang.intent=="PAUSE" else state_runtime.resume(task_id)
   status="PAUSED" if lang.intent=="PAUSE" else "RESUMED"
   self.set4.event("TASK_"+status,journey_id or f"JRN-{task_id}",actor="human",task_id=task_id,outputs=result)
   return RuntimeResponse({"intent":lang.intent,"capability":"query_current_task_state","authorization":"NOT_REQUIRED","workflow_outcome":"state_changed","state_source":"runtime_checkpoint","status":status},f"The task was {status.lower()} through the runtime gate.",lang,caps)
  if not caps:
   return RuntimeResponse({"intent":lang.intent,"entities":lang.entities,"capability":None,"authorization":"NOT_SUPPORTED","workflow_outcome":"no_state_change","status":"CAPABILITY_UNAVAILABLE"},"That capability is not currently available through an implemented registry route.",lang,caps)
  cap=caps[0]
  return RuntimeResponse({"intent":lang.intent,"entities":lang.entities,"capability":cap.capability_id,"responsible_character":cap.owner_character,"authorization":"REQUIRED" if lang.intent in {"EXECUTE","ACCEPT"} else "NOT_REQUIRED","workflow_outcome":"no_state_change","status":cap.status},f"{cap.owner_character.title()} is the registered owner of {cap.capability_id}. The operation boundary is inspectable; no execution was performed.",lang,caps)
