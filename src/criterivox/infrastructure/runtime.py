from __future__ import annotations
import asyncio,base64,binascii,json
from datetime import datetime, timedelta, timezone
from uuid import uuid4
from dataclasses import dataclass,field
from typing import Any
from pydantic import BaseModel,ConfigDict,Field,ValidationError,model_validator
from criterivox.application.analysis_tasks import analysis_tasks
from criterivox.application.contracts import ApplicationRequest
from criterivox.application.conversation import interpret_message
from criterivox.application.language_intake import detect_language_profile, interpretation_summary
from criterivox.application.language_service import language_service
from criterivox.application.data_foundation_store import data_foundations
from criterivox.application.service import UnsupportedCapabilityError
from criterivox.domain.analysis import AnalysisReference,AnalysisTask,AnalysisTaskSource,AnalysisTaskState
from criterivox.domain.characters import CharacterActivityManager,CharacterState,CHARACTER_REGISTRY
from criterivox.presentation.contract import PresentationContract
from criterivox.application.state_runtime import state_runtime
from criterivox.application.state_chat import respond_state_query
MAX_REFERENCE_BYTES=4*1024*1024;
CHAT_CONFIRMATION_TIMEOUT_SECONDS=60;
_pending_chat_confirmations:dict[str,dict[str,Any]]={};
_task_language_profiles:dict[str,Any]={};MAX_REFERENCE_COUNT=50;MAX_REFERENCE_BATCH_BYTES=8*1024*1024;ALLOWED_CHAT_CHARACTERS={'syvax','dharen','sandre','kaelen','anuka','vivren','tarkis','pramon','bodhex','medrus','epistre','veridat','manis','viveda','anukor'}
class AnalysisRequest(BaseModel):
 model_config=ConfigDict(extra='forbid');data:dict[str,Any]=Field(default_factory=dict);context:dict[str,Any]=Field(default_factory=dict);task:str=Field(min_length=1,max_length=500)
 @model_validator(mode='after')
 def validate_payload_size(self):
  if len(self.data)>1000 or len(self.context)>1000:raise ValueError('Runtime payload contains too many top-level fields.')
  if len(json.dumps(self.model_dump(),default=str))>32000:raise ValueError('Runtime payload is too large.')
  return self
@dataclass
class RuntimeConnectionManager:
 clients:set[Any]=field(default_factory=set);latest:PresentationContract=field(default_factory=lambda:PresentationContract.from_state('Dharen',CharacterState.IDLE,active=False,prominence=.25));latest_foundation:dict[str,Any]=field(default_factory=dict)
 async def connect(self,websocket):await websocket.accept();self.clients.add(websocket);await websocket.send_text(json.dumps(self._with_foundation(self.latest).to_dict()))
 def disconnect(self,websocket):self.clients.discard(websocket)
 def _with_foundation(self,contract):
  if not self.latest_foundation:return contract
  values={key:value for key,value in self.latest_foundation.items() if getattr(contract,key,None) in (None,(),[])}
  return PresentationContract(**{**contract.to_dict(),**values})
 async def publish(self,contract):
  foundation_fields={key:value for key,value in contract.to_dict().items() if key.startswith('foundation_') and value not in (None,(),[])}
  if foundation_fields:self.latest_foundation=foundation_fields
  contract=self._with_foundation(contract);self.latest=contract;message=json.dumps(contract.to_dict());dead=[]
  for client in tuple(self.clients):
   try:await client.send_text(message)
   except Exception:dead.append(client)
  for client in dead:self.disconnect(client)
class DharenRuntime:
 _CHARACTER_STATES={AnalysisTaskState.CREATED:CharacterState.IDLE,AnalysisTaskState.RECEIVED:CharacterState.RECEIVE,AnalysisTaskState.VALIDATING:CharacterState.WORK,AnalysisTaskState.PROCESSING:CharacterState.WORK,AnalysisTaskState.ANALYZING:CharacterState.WORK,AnalysisTaskState.RESULT_READY:CharacterState.COMMUNICATE,AnalysisTaskState.COMPLETED:CharacterState.COMPLETE,AnalysisTaskState.WAITING:CharacterState.WARNING,AnalysisTaskState.FAILED:CharacterState.WARNING,AnalysisTaskState.CANCELLED:CharacterState.IDLE}
 def __init__(self,connection_manager):self._connections=connection_manager;self._activity=CharacterActivityManager(CHARACTER_REGISTRY.get_all());self._legacy_lock=asyncio.Lock()
 async def publish_task(self,task,*,message=None,event=None):
  cs=self._CHARACTER_STATES[task.state];active=cs is not CharacterState.IDLE or task.state is AnalysisTaskState.COMPLETED;activity=self._activity.set_state('Dharen',cs);result=task.result;refs=tuple(r.name for r in task.reference_details) or tuple(task.references)
  profile=_task_language_profiles.get(task.task_id)
  rendered_message=await language_service.to_user_language(message or self._task_message(task),profile) if profile else (message or self._task_message(task))
  await self._connections.publish(PresentationContract.from_state(activity.character_id,activity.state,active=active,prominence=.9 if active else .25,message=rendered_message,event=event or f'TASK_{task.state.value}',task_id=task.task_id,task_state=task.state.value,task_source=task.source.value,task=task.task,task_data_fields=len(task.data),task_context_fields=len(task.context),task_created_at=task.created_at.isoformat(),task_updated_at=task.updated_at.isoformat(),task_references=refs,observations=tuple({'id':o.identifier,'text':o.text,'significance':o.significance} for o in (result.observations if result else ())),findings=tuple({'id':f.identifier,'statement':f.statement,'confidence':f.confidence} for f in (result.findings if result else ())),evidence=tuple({'id':e.identifier,'label':e.label,'source':e.source,'detail':e.detail} for e in (result.evidence if result else ())),activity=tuple(task.activity[-12:]),error=task.error))
  if task.state is AnalysisTaskState.COMPLETED:await asyncio.sleep(.3);await self._publish_idle(task)
 async def _publish_idle(self,task):
  a=self._activity.set_state('Dharen',CharacterState.IDLE);result=task.result;refs=tuple(r.name for r in task.reference_details) or tuple(task.references)
  await self._connections.publish(PresentationContract.from_state(a.character_id,a.state,active=False,prominence=.25,message='Dharen is idle. The completed analysis remains available in this workspace.',event='CHARACTER_IDLE',task_id=task.task_id,task_state=task.state.value,task_source=task.source.value,task=task.task,task_data_fields=len(task.data),task_context_fields=len(task.context),task_created_at=task.created_at.isoformat(),task_updated_at=task.updated_at.isoformat(),task_references=refs,observations=tuple({'id':o.identifier,'text':o.text,'significance':o.significance} for o in (result.observations if result else ())),findings=tuple({'id':f.identifier,'statement':f.statement,'confidence':f.confidence} for f in (result.findings if result else ())),evidence=tuple({'id':e.identifier,'label':e.label,'source':e.source,'detail':e.detail} for e in (result.evidence if result else ())),activity=tuple(task.activity[-12:]),error=task.error))
 def _task_message(self,task):return {AnalysisTaskState.CREATED:'Analysis task created.',AnalysisTaskState.RECEIVED:'Dharen received the analysis task.',AnalysisTaskState.VALIDATING:'Validating the supplied data, context, and references.',AnalysisTaskState.PROCESSING:'Preparing the supplied information for analysis.',AnalysisTaskState.ANALYZING:'Dharen is analyzing the supplied information and establishing contextual findings.',AnalysisTaskState.RESULT_READY:'The analysis result is ready for communication.',AnalysisTaskState.COMPLETED:'Dharen completed the analysis.',AnalysisTaskState.WAITING:'The analysis is waiting for required information.',AnalysisTaskState.FAILED:task.error or 'The analysis failed.',AnalysisTaskState.CANCELLED:'The analysis task was cancelled.'}[task.state]
 async def run_analysis(self,request,*,result=None):
  async with self._legacy_lock:
   await self._transition(CharacterState.RECEIVE,event='ANALYSIS_REQUESTED',message='Dharen received the analysis request.');await asyncio.sleep(.25);await self._transition(CharacterState.WORK,event='ANALYSIS_STARTED',message='Dharen is analyzing the supplied data in context.');result=result or self._perform_synthetic_analysis(request);await asyncio.sleep(.75);await self._transition(CharacterState.COMMUNICATE,event='ANALYSIS_COMPLETED',message=f"Analysis completed: {result['data_items']} data items across {result['data_fields']} fields; {result['context_fields']} context fields considered.");await asyncio.sleep(.35);await self._transition(CharacterState.COMPLETE,event='ANALYSIS_COMPLETED',message='Dharen completed the requested analysis.');await asyncio.sleep(.35);await self._transition(CharacterState.IDLE,active=False,prominence=.25,event=None,message=None)
 @staticmethod
 def _perform_synthetic_analysis(request):return {'data_items':len(request.data),'data_fields':sum(len(x) if isinstance(x,dict) else 1 for x in request.data.values()),'context_fields':len(request.context)}
 async def _transition(self,state,*,active=True,prominence=.75,event=None,message=None):a=self._activity.set_state('Dharen',state);await self._connections.publish(PresentationContract.from_state(a.character_id,a.state,active=active,prominence=prominence,message=message,event=event))
runtime_connections=RuntimeConnectionManager();dharen_runtime=DharenRuntime(runtime_connections)
async def _publish_task(task):await dharen_runtime.publish_task(task)
analysis_tasks.publish=_publish_task
def parse_analysis_request(payload):
 try:return AnalysisRequest.model_validate(payload)
 except ValidationError as exc:raise ValueError('Invalid analysis request.') from exc
def parse_application_request(payload):
 try:return ApplicationRequest.model_validate(payload)
 except ValidationError as exc:raise ValueError('Invalid application request.') from exc
def _task_source(source):
 n=source.lower();n='chat' if n=='syvax' else n
 try:return AnalysisTaskSource(n)
 except ValueError as exc:raise ValueError('Invalid analysis task source.') from exc
def _parse_chat_references(raw):
 if raw is None:return (),()
 if not isinstance(raw,list) or len(raw)>MAX_REFERENCE_COUNT:raise ValueError('Invalid reference list.')
 names=[];details=[];total=0
 for i,item in enumerate(raw):
  if isinstance(item,str):name=item.strip()
  else:
   if not isinstance(item,dict):raise ValueError('Invalid reference payload.')
   name=item.get('name');kind=item.get('kind','file');size=item.get('size_bytes',0);encoded=item.get('content_base64')
   if not isinstance(name,str) or not name.strip() or len(name)>500:raise ValueError('Reference name is invalid.')
   if not isinstance(kind,str) or kind not in {'document','dataset','image','file'}:raise ValueError('Reference kind is invalid.')
   if not isinstance(size,int) or size<0 or size>MAX_REFERENCE_BYTES:raise ValueError('Reference size is invalid.')
   if not isinstance(encoded,str) or not encoded:raise ValueError('Attached file content is missing.')
   try:decoded=base64.b64decode(encoded,validate=True)
   except (ValueError,binascii.Error) as exc:raise ValueError('Attached reference content is not valid base64.') from exc
   if len(decoded)!=size or len(decoded)>MAX_REFERENCE_BYTES:raise ValueError('Attached reference size does not match its payload.')
   total+=len(decoded)
   if total>MAX_REFERENCE_BATCH_BYTES:raise ValueError('Attached references exceed the 8 MB chat batch limit.')
   name=name.strip();details.append(AnalysisReference(f'ref-{i+1}',name,kind,size,encoded))
  if not name or len(name)>500:raise ValueError('Invalid reference.')
  names.append(name)
  if len(details)<len(names):details.append(AnalysisReference(f'ref-{i+1}',name,'link',url=name))
 return tuple(names),tuple(details)
def _foundation_payload(refs,details,message,task_id):
 sources=[]
 for name,detail in zip(refs,details):
  decoded=None
  try:
   raw=base64.b64decode(detail.content_base64,validate=True)
   decoded=raw.decode('utf-8')
  except (UnicodeDecodeError,ValueError,binascii.Error):
   pass
  item={'name':name,'source_type':'file','channel':'chat','collection_id':task_id}
  if decoded is not None:item['content']=decoded
  else:item['content_base64']=detail.content_base64
  sources.append(item)
 return {'sources':sources,'collection_id':task_id or f'chat-{id(message)}','supplied_context':{'entered_through':'Syvax Chatbox','chat_message':message[:500],'task_id':task_id,'material_origin':'chat_reference'}}
async def _sync_chat_material(refs,details,message,task_id):
 if not details:return None
 foundation=data_foundations.ingest(_foundation_payload(refs,details,message,task_id))
 fields={'foundation_id':foundation.foundation_id,'foundation_material_set_id':foundation.foundation_id,'foundation_source_count':len(foundation.sources),'foundation_candidate_count':len(foundation.candidates),'foundation_confirmation':foundation.confirmation_status.value,'foundation_preview_question':'Is this what you intended to submit?','foundation_recipient':'syvax'}
 await runtime_connections.publish(PresentationContract.from_state('Sandre',CharacterState.RECEIVE,active=True,prominence=.9,message=f'Sandre received {len(foundation.sources)} chat material source(s). Extraction is now available in Data Stewardship.',event='MATERIAL_RECEIVED',**fields));await asyncio.sleep(.05);await runtime_connections.publish(PresentationContract.from_state('Sandre',CharacterState.WORK,active=True,prominence=.9,message='Sandre completed the initial chat-material extraction and profiling. The same foundation is now visible to the stewardship workspace.',event='EXTRACTION_COMPLETED',**fields));return foundation
async def _publish_chat_interpretation(character:str, *, confirmation_id:str, original:str, interpretation, status:str, deadline:str|None=None, task_id:str|None=None) -> None:
 profile = interpretation.language_profile.to_dict() if interpretation.language_profile else {}
 await runtime_connections.publish(
  PresentationContract.from_state(
   character, CharacterState.COMMUNICATE, active=True, prominence=.9,
   message=await language_service.to_user_language(
    ("I interpreted your request. Review the interpretation before continuing."
    if status == "PENDING"
    else "Interpretation confirmed. Criterivox is continuing the work."
    if status == "CONFIRMED"
    else "No confirmation arrived within 1 minute. Criterivox continued with the recorded interpretation and marked it unconfirmed."
    if status == "UNCONFIRMED_TIMEOUT"
    else "The interpretation was corrected by the human."),
    interpretation.language_profile,
   ),
   event="CHAT_INTERPRETATION_CONFIRMATION",
   task_id=task_id,
   input_original=original,
   input_language_profile=profile,
   input_interpretation=interpretation.normalized_text,
   input_semantic_summary=await language_service.to_user_language(interpretation.semantic_summary or interpretation_summary(interpretation.intent, interpretation.route_target), interpretation.language_profile),
   input_confirmation_status=status,
   input_confirmation_deadline=deadline,
   input_confirmation_id=confirmation_id,
  )
 )

async def _continue_confirmed_chat(item:dict[str,Any], *, status:str) -> None:
 interpretation=item["interpretation"]; task=item["task"]
 await _publish_chat_interpretation(
  item["character"], confirmation_id=item["confirmation_id"], original=item["original"],
  interpretation=interpretation, status=status, deadline=item["deadline"], task_id=task.task_id
 )
 if status == "CONFIRMED":
  item["confirmation_status"]="CONFIRMED"
 if status == "UNCONFIRMED_TIMEOUT":
  item["confirmation_status"]="UNCONFIRMED_TIMEOUT"
 if interpretation.intent in {"analyze","handoff","unknown","change_request","continue"} and not task.is_terminal:
  await dharen_runtime.publish_task(task,message="Criterivox is continuing the task from the recorded human interpretation.",event="INTERPRETATION_ACCEPTED_CONTINUATION")
  asyncio.create_task(analysis_tasks.execute(task.task_id))

async def _expire_chat_confirmation(confirmation_id:str) -> None:
 await asyncio.sleep(CHAT_CONFIRMATION_TIMEOUT_SECONDS)
 item=_pending_chat_confirmations.get(confirmation_id)
 if item is None or item.get("confirmation_status") != "PENDING":
  return
 await _continue_confirmed_chat(item,status="UNCONFIRMED_TIMEOUT")
 _pending_chat_confirmations.pop(confirmation_id,None)

async def _queue_chat_confirmation(*, character:str, original:str, interpretation, task:AnalysisTask) -> str:
 confirmation_id=f"IC-{uuid4().hex[:12]}"
 deadline=(datetime.now(timezone.utc)+timedelta(seconds=CHAT_CONFIRMATION_TIMEOUT_SECONDS)).isoformat()
 item={"confirmation_id":confirmation_id,"character":character,"original":original,"interpretation":interpretation,"task":task,"deadline":deadline,"confirmation_status":"PENDING"}
 _pending_chat_confirmations[confirmation_id]=item
 await _publish_chat_interpretation(character,confirmation_id=confirmation_id,original=original,interpretation=interpretation,status="PENDING",deadline=deadline,task_id=task.task_id)
 asyncio.create_task(_expire_chat_confirmation(confirmation_id))
 return confirmation_id

async def handle_chat_interpretation_confirmation(payload:dict[str,Any]) -> None:
 confirmation_id=str(payload.get("confirmation_id","")).strip()
 item=_pending_chat_confirmations.get(confirmation_id)
 if item is None:
  return
 if item.get("confirmation_status") != "PENDING":
  return
 accepted=bool(payload.get("accepted",False))
 if not accepted:
  item["confirmation_status"]="REJECTED"
  await _publish_chat_interpretation(item["character"],confirmation_id=confirmation_id,original=item["original"],interpretation=item["interpretation"],status="CORRECTED",deadline=item["deadline"],task_id=item["task"].task_id)
  _pending_chat_confirmations.pop(confirmation_id,None)
  return
 await _continue_confirmed_chat(item,status="CONFIRMED")
 _pending_chat_confirmations.pop(confirmation_id,None)

async def handle_application_request(payload):
 request=parse_application_request(payload)
 if request.intent.value!='analyze':raise UnsupportedCapabilityError(f"Capability '{request.intent.value}' is reserved for a future sprint.")
 if request.task_id:
  task=analysis_tasks.get_task(request.task_id);await dharen_runtime.publish_task(task,message='The existing analysis task was reopened from another surface.',event='ANALYSIS_TASK_REOPENED');
  if not task.is_terminal:asyncio.create_task(analysis_tasks.execute(task.task_id))
  return
 task=analysis_tasks.create_task(task=request.task,data=request.data,context=request.context,source=_task_source(request.source),references=request.references);await dharen_runtime.publish_task(task,message='Analysis task created. Dharen is ready to receive it.',event='ANALYSIS_TASK_CREATED');asyncio.create_task(analysis_tasks.execute(task.task_id))
async def handle_chat_message(payload):
 if not isinstance(payload,dict):raise ValueError('Malformed chat message.')
 target=str(payload.get('target_character','syvax')).strip().lower()
 if target not in ALLOWED_CHAT_CHARACTERS:raise ValueError('Unknown chat character.')
 task_id=payload.get('task_id');message=payload.get('message')
 if not isinstance(message,str) or not message.strip() or len(message)>2000:raise ValueError('Chat message is invalid.')
 profile=detect_language_profile(message);normalized=await language_service.to_reasoning_language(message,profile);interpretation=interpret_message(normalized);object.__setattr__(interpretation,'language_profile',profile);refs,details=_parse_chat_references(payload.get('references',[]));await _sync_chat_material(refs,details,message,task_id)
 if interpretation.intent in {"analyze","handoff","unknown","change_request","continue"}:
  task=analysis_tasks.get_task(str(task_id)) if task_id is not None else analysis_tasks.create_task(task=interpretation.normalized_text,data=payload.get('data') if isinstance(payload.get('data'),dict) else {},context=payload.get('context') if isinstance(payload.get('context'),dict) else {},source=AnalysisTaskSource.CHAT,references=refs,reference_details=details)
  _task_language_profiles[task.task_id]=profile
  await _queue_chat_confirmation(character=target,original=message,interpretation=interpretation,task=task)
  return
 if target not in {'syvax','dharen'}:
  await _safe_character_chat(payload)
  return
 if target=='syvax':
  if interpretation.intent in {'history','current','next','status'}:
   if task_id is None:
    await _publish_character('Syvax',CharacterState.WARNING,message='No task is bound to this conversation, so there is no authoritative state record to inspect.',event='STATE_QUERY_NO_TASK'); return
   tid=str(task_id)
   try:
    message_out,structured=respond_state_query(tid,interpretation)
   except Exception:
    message_out,structured='No authoritative runtime record exists for that state.',{'status':'NO_AUTHORITATIVE_RECORD'}
   await _publish_character('Syvax',CharacterState.COMMUNICATE,message=message_out,event='STATE_AWARE_RESPONSE',task=analysis_tasks.get_task(tid) if tid in analysis_tasks.store.tasks else None)
   return
  if interpretation.intent in {'pause','resume','cancel','change_request'}:
   if task_id is None:
    await _publish_character('Syvax',CharacterState.WARNING,message='No task is bound to this conversation, so no workflow interruption was performed.',event='INTERRUPTION_NO_TASK'); return
   tid=str(task_id); task=analysis_tasks.get_task(tid)
   if interpretation.intent=='pause':
    from criterivox.application.home03_runtime import home03_runtime
    if task.is_terminal:
     await _publish_character('Syvax',CharacterState.WARNING,message='The task is already terminal; no pause was performed.',event='PAUSE_UNSUPPORTED',task=task); return
    state_runtime.pause(tid); await _publish_character('Syvax',CharacterState.COMMUNICATE,message='The task has been paused through the runtime gate.',event='TASK_PAUSED',task=task); return
   if interpretation.intent=='resume':
    state_runtime.resume(tid); await _publish_character('Syvax',CharacterState.COMMUNICATE,message='The task has been resumed through the runtime gate.',event='TASK_RESUMED',task=task); return
   if interpretation.intent=='cancel':
    await _publish_character('Syvax',CharacterState.WARNING,message='Cancellation is not supported by the current safe character-chat boundary.',event='CANCEL_UNSUPPORTED',task=task); return
   state_runtime.record_event(tid,'CHANGE_REQUESTED',actor='human',provenance={'request':message})
   await _publish_character('Syvax',CharacterState.COMMUNICATE,message='The requested change was recorded. Downstream state was not silently modified.',event='CHANGE_REQUESTED',task=task); return
  if interpretation.intent=='handoff':
   if task_id is None:task=analysis_tasks.create_task(task=interpretation.normalized_text,data={},context={},source=AnalysisTaskSource.CHAT,references=refs,reference_details=details);task_id=task.task_id
   else:task=analysis_tasks.get_task(str(task_id))
   await _publish_character('Syvax',CharacterState.RECEIVE,message='Syvax received your handoff instruction.',event='SYVAX_RECEIVED',task=task);await asyncio.sleep(.12);await _publish_character('Syvax',CharacterState.WORK,message='Syvax is preparing the handoff context for Dharen.',event='HANDOFF_PREPARING',task=task);await asyncio.sleep(.12);await _publish_character('Syvax',CharacterState.HANDOFF,message='Syvax can hand this task to Dharen. The current task, data, context, and references will remain attached.',event='HANDOFF_ACCEPTED',task=task);await asyncio.sleep(.12);await _publish_character('Dharen',CharacterState.RECEIVE,message='Dharen received the task from Syvax.',event='HANDOFF_COMPLETED',task=task)
   if not task.is_terminal:asyncio.create_task(analysis_tasks.execute(task.task_id))
   return
  if interpretation.intent=='user_continue':
   if task_id is None:await _publish_character('Syvax',CharacterState.RECEIVE,message='Syvax received your choice to continue yourself.',event='SYVAX_RECEIVED')
   else:task=analysis_tasks.get_task(str(task_id));await _publish_character('Syvax',CharacterState.COMMUNICATE,message='Syvax will keep the current task with you. No handoff was performed.',event='USER_CONTINUES',task=task)
   return
  if interpretation.intent=='analyze':
   if task_id is None:task=analysis_tasks.create_task(task=interpretation.normalized_text,data=payload.get('data') if isinstance(payload.get('data'),dict) else {},context=payload.get('context') if isinstance(payload.get('context'),dict) else {},source=AnalysisTaskSource.CHAT,references=refs,reference_details=details);task_id=task.task_id
   else:task=analysis_tasks.get_task(str(task_id))
   await _publish_character('Syvax',CharacterState.RECEIVE,message='Syvax received your analysis request.',event='SYVAX_RECEIVED',task=task);await asyncio.sleep(.12);await _publish_character('Syvax',CharacterState.COMMUNICATE,message='This is an analysis task. Syvax recommends Dharen for the structural analysis. You can hand it over to Dharen or continue yourself.',event='HANDOFF_PROPOSED',task=task);return
  if task_id is None:task=analysis_tasks.create_task(task=interpretation.normalized_text,data=payload.get('data') if isinstance(payload.get('data'),dict) else {},context=payload.get('context') if isinstance(payload.get('context'),dict) else {},source=AnalysisTaskSource.CHAT,references=refs,reference_details=details);task_id=task.task_id
  else:task=analysis_tasks.get_task(str(task_id))
  await _publish_character('Syvax',CharacterState.RECEIVE,message='Syvax received your request and is interpreting what you need.',event='SYVAX_RECEIVED',task=task);await asyncio.sleep(.12);await _publish_character('Syvax',CharacterState.COMMUNICATE,message='I can route analysis work to Dharen, or you can continue the task yourself. Tell me which you prefer.',event='HANDOFF_PROPOSED',task=task);return
 task=analysis_tasks.get_task(str(task_id)) if task_id is not None else None
 if task is None:
  data=payload.get('data') if isinstance(payload.get('data'),dict) else {};context=payload.get('context') if isinstance(payload.get('context'),dict) else {};task=analysis_tasks.create_task(task=interpretation.normalized_text,data=data,context=context,source=AnalysisTaskSource.CHAT,references=refs,reference_details=details);await dharen_runtime.publish_task(task,message='Dharen received your request directly.',event='CHAT_ANALYSIS_REQUESTED');asyncio.create_task(analysis_tasks.execute(task.task_id));return
 if details:task.references=tuple(dict.fromkeys((*task.references,*refs)));task.reference_details=(*task.reference_details,*details);task.add_activity(f'Attached {len(details)} additional reference(s) to the task.')
 task.add_activity(f'User asked Dharen: {interpretation.normalized_text}')
 if interpretation.intent=='status':await dharen_runtime.publish_task(task,message=f'Dharen reports the authoritative analysis state: {task.state.value}.',event='TASK_STATUS_REQUESTED')
 elif interpretation.intent=='continue':await dharen_runtime.publish_task(task,message='Dharen confirms the current analysis remains active. The same task state and evidence are preserved.',event='TASK_CONTINUE_REQUESTED')
 else:await dharen_runtime.publish_task(task,message='Dharen received the follow-up. The task remains grounded in its recorded data, context, and references.',event='TASK_FOLLOWUP_RECEIVED')
async def _publish_character(character_id,state,*,message,event,task=None,active=True,prominence=.85):
 activity_manager=dharen_runtime._activity;activity=activity_manager.set_state(character_id,state);fields={}
 if task is not None:
  result=task.result;refs=tuple(r.name for r in task.reference_details) or tuple(task.references);fields=dict(task_id=task.task_id,task_state=task.state.value,task_source=task.source.value,task=task.task,task_data_fields=len(task.data),task_context_fields=len(task.context),task_created_at=task.created_at.isoformat(),task_updated_at=task.updated_at.isoformat(),task_references=refs,observations=tuple({'id':o.identifier,'text':o.text,'significance':o.significance} for o in (result.observations if result else ())),findings=tuple({'id':f.identifier,'statement':f.statement,'confidence':f.confidence} for f in (result.findings if result else ())),evidence=tuple({'id':e.identifier,'label':e.label,'source':e.source,'detail':e.detail} for e in (result.evidence if result else ())),activity=tuple(task.activity[-12:]),error=task.error)
 await runtime_connections.publish(PresentationContract.from_state(character_id,activity.state,active=active,prominence=prominence,message=message,event=event,**fields))
__all__=['AnalysisRequest','DharenRuntime','RuntimeConnectionManager','dharen_runtime','handle_application_request','handle_chat_message','parse_analysis_request','parse_application_request','runtime_connections','UnsupportedCapabilityError']
