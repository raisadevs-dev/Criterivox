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
 machine:dict[str,Any]; human_text:str; language:LanguageResult; capabilities:tuple[CapabilityMatch,...]

def _localized(lang:str,key:str,**kw)->str:
 templates={
 "en":{"pause":"The task was paused through the runtime gate.","resume":"The task was resumed through the runtime gate.","unavailable":"That capability is not currently available through an implemented registry route.","owner":"{owner} is the registered owner of {cap}. The operation boundary is inspectable; no execution was performed."},
 "hi":{"pause":"कार्य को रनटाइम गेट के माध्यम से रोका गया।","resume":"कार्य को रनटाइम गेट के माध्यम से फिर शुरू किया गया।","unavailable":"यह क्षमता वर्तमान में लागू रजिस्ट्री मार्ग के माध्यम से उपलब्ध नहीं है।","owner":"{owner} इस क्षमता का पंजीकृत उत्तरदायी पात्र है। ऑपरेशन सीमा निरीक्षण योग्य है; कोई निष्पादन नहीं किया गया।"},
 "mr":{"pause":"कार्य रनटाइम गेटद्वारे थांबवले गेले.","resume":"कार्य रनटाइम गेटद्वारे पुन्हा सुरू केले गेले.","unavailable":"ही क्षमता सध्या लागू रजिस्ट्री मार्गातून उपलब्ध नाही.","owner":"{owner} हा {cap} क्षमतेचा नोंदणीकृत जबाबदार सदस्य आहे. ऑपरेशनची सीमा तपासता येते; कोणतीही अंमलबजावणी केली नाही."}}
 return (templates.get(lang) or templates["en"])[key].format(**kw)

class UnifiedCharacterRuntime:
 def __init__(self,set4=None): self.set4=set4 or Set4Runtime()
 def handle(self,message:str,*,task_id:str|None=None,character_id:str|None=None,journey_id:str|None=None)->RuntimeResponse:
  lang=interpret(message); caps=discover(lang.intent,character_id)
  if lang.ambiguous:
   return RuntimeResponse({"intent":lang.intent,"entities":lang.entities,"capability":None,"authorization":"NOT_REQUIRED","status":"CLARIFICATION_REQUIRED","state_source":"language_layer","detected_language":lang.detected_language,"response_language":lang.response_language},lang.clarification or "Please clarify the requested operation.",lang,caps)
  if lang.intent in {"QUERY_PAST_STATE","QUERY_CURRENT_STATE","QUERY_NEXT_STATE"} and task_id:
   mapping={"QUERY_PAST_STATE":"history","QUERY_CURRENT_STATE":"current","QUERY_NEXT_STATE":"next"}
   interp=ConversationInterpretation(intent=mapping[lang.intent],normalized_text=lang.normalized_text,entities=tuple(lang.entities.values()))
   text,data=respond_state_query(task_id,interp)
   return RuntimeResponse({"intent":lang.intent,"entities":lang.entities,"capability":"query_current_task_state","state_source":"runtime_checkpoint","authorization":"NOT_REQUIRED","workflow_outcome":"checkpoint_inspected","status":data.get("status"),"detected_language":lang.detected_language,"response_language":lang.response_language},text,lang,caps)
  if lang.intent in {"PAUSE","RESUME"} and task_id:
   result=state_runtime.pause(task_id) if lang.intent=="PAUSE" else state_runtime.resume(task_id)
   status="PAUSED" if lang.intent=="PAUSE" else "RESUMED"
   self.set4.event("TASK_"+status,journey_id or f"JRN-{task_id}",actor="human",task_id=task_id,outputs=result)
   return RuntimeResponse({"intent":lang.intent,"capability":"query_current_task_state","authorization":"NOT_REQUIRED","workflow_outcome":"state_changed","state_source":"runtime_checkpoint","status":status,"detected_language":lang.detected_language,"response_language":lang.response_language},_localized(lang.response_language,"pause" if status=="PAUSED" else "resume"),lang,caps)
  if not caps:
   return RuntimeResponse({"intent":lang.intent,"entities":lang.entities,"capability":None,"authorization":"NOT_SUPPORTED","workflow_outcome":"no_state_change","status":"CAPABILITY_UNAVAILABLE","detected_language":lang.detected_language,"response_language":lang.response_language},_localized(lang.response_language,"unavailable"),lang,caps)
  cap=caps[0]; owner=cap.owner_character.title()
  return RuntimeResponse({"intent":lang.intent,"entities":lang.entities,"capability":cap.capability_id,"responsible_character":cap.owner_character,"authorization":"REQUIRED" if lang.intent in {"EXECUTE","ACCEPT"} else "NOT_REQUIRED","workflow_outcome":"no_state_change","status":cap.status,"detected_language":lang.detected_language,"response_language":lang.response_language},_localized(lang.response_language,"owner",owner=owner,cap=cap.capability_id),lang,caps)
