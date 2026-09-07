from __future__ import annotations
import asyncio, base64, binascii, json
from dataclasses import dataclass, field
from typing import Any
from pydantic import BaseModel, ConfigDict, Field, ValidationError, model_validator
from criterivox.application.analysis_tasks import analysis_tasks
from criterivox.application.contracts import ApplicationRequest
from criterivox.application.conversation import interpret_message
from criterivox.application.service import UnsupportedCapabilityError
from criterivox.domain.analysis import AnalysisReference, AnalysisTask, AnalysisTaskSource, AnalysisTaskState
from criterivox.domain.characters import CharacterActivityManager, CharacterState, CHARACTER_REGISTRY
from criterivox.presentation.contract import PresentationContract
MAX_REFERENCE_BYTES=4*1024*1024; MAX_REFERENCE_COUNT=50; MAX_REFERENCE_BATCH_BYTES=8*1024*1024; ALLOWED_CHAT_CHARACTERS={"syvax","dharen"}
class AnalysisRequest(BaseModel):
 model_config=ConfigDict(extra="forbid"); data:dict[str,Any]=Field(default_factory=dict); context:dict[str,Any]=Field(default_factory=dict); task:str=Field(min_length=1,max_length=500)
 @model_validator(mode="after")
 def validate_payload_size(self):
  if len(self.data)>1000 or len(self.context)>1000: raise ValueError("Runtime payload contains too many top-level fields.")
  if len(json.dumps(self.model_dump(),default=str))>32000: raise ValueError("Runtime payload is too large.")
  return self
@dataclass
class RuntimeConnectionManager:
 clients:set[Any]=field(default_factory=set); latest:PresentationContract=field(default_factory=lambda:PresentationContract.from_state("Dharen",CharacterState.IDLE,active=False,prominence=.25))
 async def connect(self,websocket): await websocket.accept(); self.clients.add(websocket); await websocket.send_text(json.dumps(self.latest.to_dict()))
 def disconnect(self,websocket): self.clients.discard(websocket)
 async def publish(self,contract):
  self.latest=contract; message=json.dumps(contract.to_dict()); disconnected=[]
  for client in tuple(self.clients):
   try: await client.send_text(message)
   except Exception: disconnected.append(client)
  for client in disconnected:self.disconnect(client)
class DharenRuntime:
 _CHARACTER_STATES={AnalysisTaskState.CREATED:CharacterState.IDLE,AnalysisTaskState.RECEIVED:CharacterState.RECEIVE,AnalysisTaskState.VALIDATING:CharacterState.WORK,AnalysisTaskState.PROCESSING:CharacterState.WORK,AnalysisTaskState.ANALYZING:CharacterState.WORK,AnalysisTaskState.RESULT_READY:CharacterState.COMMUNICATE,AnalysisTaskState.COMPLETED:CharacterState.COMPLETE,AnalysisTaskState.WAITING:CharacterState.WARNING,AnalysisTaskState.FAILED:CharacterState.WARNING,AnalysisTaskState.CANCELLED:CharacterState.IDLE}
 def __init__(self,connection_manager): self._connections=connection_manager; self._activity=CharacterActivityManager(CHARACTER_REGISTRY.get_all()); self._legacy_lock=asyncio.Lock()
 async def publish_task(self,task,*,message=None,event=None):
  character_state=self._CHARACTER_STATES[task.state]; active=character_state is not CharacterState.IDLE or task.state is AnalysisTaskState.COMPLETED; activity=self._activity.set_state("Dharen",character_state); result=task.result
  await self._connections.publish(PresentationContract.from_state(activity.character_id,activity.state,active=active,prominence=.9 if active else .25,message=message or self._task_message(task),event=event or f"TASK_{task.state.value}",task_id=task.task_id,task_state=task.state.value,task_source=task.source.value,task=task.task,task_data_fields=len(task.data),task_context_fields=len(task.context),task_created_at=task.created_at.isoformat(),task_updated_at=task.updated_at.isoformat(),observations=tuple({"id":o.identifier,"text":o.text,"significance":o.significance} for o in (result.observations if result else ())),findings=tuple({"id":f.identifier,"statement":f.statement,"confidence":f.confidence} for f in (result.findings if result else ())),evidence=tuple({"id":e.identifier,"label":e.label,"source":e.source,"detail":e.detail} for e in (result.evidence if result else ())),activity=tuple(task.activity[-12:]),error=task.error))
  if task.state is AnalysisTaskState.COMPLETED: await asyncio.sleep(.3); await self._publish_idle(task)
 async def _publish_idle(self,task):
  activity=self._activity.set_state("Dharen",CharacterState.IDLE); result=task.result
  await self._connections.publish(PresentationContract.from_state(activity.character_id,activity.state,active=False,prominence=.25,message="Dharen is idle. The completed analysis remains available in this workspace.",event="CHARACTER_IDLE",task_id=task.task_id,task_state=task.state.value,task_source=task.source.value,task=task.task,task_data_fields=len(task.data),task_context_fields=len(task.context),task_created_at=task.created_at.isoformat(),task_updated_at=task.updated_at.isoformat(),observations=tuple({"id":o.identifier,"text":o.text,"significance":o.significance} for o in (result.observations if result else ())),findings=tuple({"id":f.identifier,"statement":f.statement,"confidence":f.confidence} for f in (result.findings if result else ())),evidence=tuple({"id":e.identifier,"label":e.label,"source":e.source,"detail":e.detail} for e in (result.evidence if result else ())),activity=tuple(task.activity[-12:]),error=task.error))
 def _task_message(self,task): return {AnalysisTaskState.CREATED:"Analysis task created.",AnalysisTaskState.RECEIVED:"Dharen received the analysis task.",AnalysisTaskState.VALIDATING:"Validating the supplied data, context, and references.",AnalysisTaskState.PROCESSING:"Preparing the supplied information for analysis.",AnalysisTaskState.ANALYZING:"Dharen is analyzing the supplied information and establishing contextual findings.",AnalysisTaskState.RESULT_READY:"The analysis result is ready for communication.",AnalysisTaskState.COMPLETED:"Dharen completed the analysis.",AnalysisTaskState.WAITING:"The analysis is waiting for required information.",AnalysisTaskState.FAILED:task.error or "The analysis failed.",AnalysisTaskState.CANCELLED:"The analysis task was cancelled."}[task.state]
 async def run_analysis(self,request,*,result=None):
  async with self._legacy_lock:
   await self._transition(CharacterState.RECEIVE,event="ANALYSIS_REQUESTED",message="Dharen received the analysis request."); await asyncio.sleep(.25); await self._transition(CharacterState.WORK,event="ANALYSIS_STARTED",message="Dharen is analyzing the supplied data in context."); result=result or self._perform_synthetic_analysis(request); await asyncio.sleep(.75); await self._transition(CharacterState.COMMUNICATE,event="ANALYSIS_COMPLETED",message=f"Analysis completed: {result['data_items']} data items across {result['data_fields']} fields; {result['context_fields']} context fields considered."); await asyncio.sleep(.35); await self._transition(CharacterState.COMPLETE,event="ANALYSIS_COMPLETED",message="Dharen completed the requested analysis."); await asyncio.sleep(.35); await self._transition(CharacterState.IDLE,active=False,prominence=.25,event=None,message=None)
 @staticmethod
 def _perform_synthetic_analysis(request): return {"data_items":len(request.data),"data_fields":sum(len(x) if isinstance(x,dict) else 1 for x in request.data.values()),"context_fields":len(request.context)}
 async def _transition(self,state,*,active=True,prominence=.75,event=None,message=None): activity=self._activity.set_state("Dharen",state); await self._connections.publish(PresentationContract.from_state(activity.character_id,activity.state,active=active,prominence=prominence,message=message,event=event))
runtime_connections=RuntimeConnectionManager(); dharen_runtime=DharenRuntime(runtime_connections)
async def _publish_task(task): await dharen_runtime.publish_task(task)
analysis_tasks.publish=_publish_task
def parse_analysis_request(payload):
 try:return AnalysisRequest.model_validate(payload)
 except ValidationError as exc:raise ValueError("Invalid analysis request.") from exc
def parse_application_request(payload):
 try:return ApplicationRequest.model_validate(payload)
 except ValidationError as exc:raise ValueError("Invalid application request.") from exc
def _task_source(source):
 normalized=source.lower(); normalized="chat" if normalized=="syvax" else normalized
 try:return AnalysisTaskSource(normalized)
 except ValueError as exc:raise ValueError("Invalid analysis task source.") from exc
def _parse_chat_references(raw):
 if raw is None:return (),()
 if not isinstance(raw,list) or len(raw)>MAX_REFERENCE_COUNT:raise ValueError("Invalid reference list.")
 names=[]; details=[]; total=0
 for index,item in enumerate(raw):
  if isinstance(item,str):
   name=item.strip()
   if not name or len(name)>500:raise ValueError("Invalid reference.")
   names.append(name);details.append(AnalysisReference(f"ref-{index+1}",name,"link",url=name));continue
  if not isinstance(item,dict):raise ValueError("Invalid reference payload.")
  name=item.get("name");kind=item.get("kind","file");size=item.get("size_bytes",0);encoded=item.get("content_base64")
  if not isinstance(name,str) or not name.strip() or len(name)>500:raise ValueError("Reference name is invalid.")
  if not isinstance(kind,str) or kind not in {"document","dataset","image","file"}:raise ValueError("Reference kind is invalid.")
  if not isinstance(size,int) or size<0 or size>MAX_REFERENCE_BYTES:raise ValueError("Reference size is invalid.")
  if not isinstance(encoded,str) or not encoded:raise ValueError("Attached file content is missing.")
  try:decoded=base64.b64decode(encoded,validate=True)
  except (ValueError,binascii.Error) as exc:raise ValueError("Attached reference content is not valid base64.") from exc
  if len(decoded)!=size or len(decoded)>MAX_REFERENCE_BYTES:raise ValueError("Attached reference size does not match its payload.")
  total+=len(decoded)
  if total>MAX_REFERENCE_BATCH_BYTES:raise ValueError("Attached references exceed the 8 MB chat batch limit.")
  names.append(name.strip());details.append(AnalysisReference(f"ref-{index+1}",name.strip(),kind,size,encoded))
 return tuple(names),tuple(details)
async def handle_application_request(payload):
 request=parse_application_request(payload)
 if request.intent.value!="analyze":raise UnsupportedCapabilityError(f"Capability '{request.intent.value}' is reserved for a future sprint.")
 if request.task_id:
  task=analysis_tasks.get_task(request.task_id)
  await dharen_runtime.publish_task(task,message="The existing analysis task was reopened from another surface.",event="ANALYSIS_TASK_REOPENED")
  if not task.is_terminal:asyncio.create_task(analysis_tasks.execute(task.task_id))
  return
 task=analysis_tasks.create_task(task=request.task,data=request.data,context=request.context,source=_task_source(request.source),references=request.references)
 await dharen_runtime.publish_task(task,message="Analysis task created. Dharen is ready to receive it.",event="ANALYSIS_TASK_CREATED");asyncio.create_task(analysis_tasks.execute(task.task_id))
async def handle_chat_message(payload):
 if not isinstance(payload,dict):raise ValueError("Malformed chat message.")
 target=str(payload.get("target_character","syvax")).strip().lower()
 if target not in ALLOWED_CHAT_CHARACTERS:raise ValueError("Unknown chat character.")
 task_id=payload.get("task_id");message=payload.get("message")
 if not isinstance(message,str) or not message.strip() or len(message)>2000:raise ValueError("Chat message is invalid.")
 interpretation=interpret_message(message);refs,details=_parse_chat_references(payload.get("references",[]));speaker="Dharen" if target=="dharen" else "Syvax";route_note="Dharen is receiving this request directly." if target=="dharen" else "Syvax received this request and is routing analysis work to Dharen."
 if task_id is None:
  data=payload.get("data") if isinstance(payload.get("data"),dict) else {};context=payload.get("context") if isinstance(payload.get("context"),dict) else {};task=analysis_tasks.create_task(task=interpretation.normalized_text,data=data,context=context,source=AnalysisTaskSource.CHAT,references=refs,reference_details=details);await dharen_runtime.publish_task(task,message=f"{speaker} received your request. {route_note}",event="CHAT_ANALYSIS_REQUESTED");asyncio.create_task(analysis_tasks.execute(task.task_id));return
 try:task=analysis_tasks.get_task(str(task_id))
 except Exception as exc:raise ValueError("Unknown analysis task.") from exc
 if details:task.references=tuple(dict.fromkeys((*task.references,*refs)));task.reference_details=(*task.reference_details,*details);task.add_activity(f"Attached {len(details)} additional reference(s) to the task.")
 task.add_activity(f"User asked {speaker}: {interpretation.normalized_text}")
 if interpretation.intent=="status":await dharen_runtime.publish_task(task,message=f"{speaker} reports the authoritative analysis state: {task.state.value}.",event="TASK_STATUS_REQUESTED")
 elif interpretation.intent=="continue":await dharen_runtime.publish_task(task,message=f"{speaker} confirms the current analysis remains active. The same task state and evidence are preserved.",event="TASK_CONTINUE_REQUESTED")
 else:await dharen_runtime.publish_task(task,message=f"{speaker} received the follow-up. The task remains grounded in its recorded data, context, and references.",event="TASK_FOLLOWUP_RECEIVED")
__all__=["AnalysisRequest","DharenRuntime","RuntimeConnectionManager","dharen_runtime","handle_application_request","handle_chat_message","parse_analysis_request","parse_application_request","runtime_connections","UnsupportedCapabilityError"]
