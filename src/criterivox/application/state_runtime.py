from __future__ import annotations
from datetime import datetime, timezone
from uuid import uuid4
from typing import Any
from criterivox.application.home03_store import home03_store
from criterivox.domain.state_awareness import Checkpoint,ExecutionEvent,Journey,SituationAwarenessResponse,SituationLevel,TruthClass,NextType

def now()->str:return datetime.now(timezone.utc).isoformat()

class StateRuntime:
    def __init__(self,store=home03_store):self.store=store

    def ensure_journey(self,task_id:str,goal:str,conversation_id:str|None=None)->Journey:
        existing=self.store.get_state_journey_by_task(task_id)
        if existing:return Journey(**existing)
        jid=f"J-{uuid4().hex[:10].upper()}"; cid=conversation_id or f"C-{uuid4().hex[:10].upper()}"
        row={"journey_id":jid,"conversation_id":cid,"task_id":task_id,"goal":goal,"status":"CREATED","created_at":now(),"updated_at":now(),"context_reference":None}
        self.store.state_journey(row);return Journey(**row)

    def update_journey(self,task_id:str,**fields):
        self.store.update_state_journey(task_id,fields)

    def record_event(self,task_id:str,event_type:str,actor:str="system",capability:str|None=None,
                     previous_state:str|None=None,new_state:str|None=None,caused_by:str|None=None,
                     parent_event:str|None=None,input_refs=(),output_refs=(),status="RECORDED",provenance=None):
        j=self.ensure_journey(task_id,"")
        e={"event_id":f"EV-{uuid4().hex[:12].upper()}","journey_id":j.journey_id,"task_id":task_id,
           "timestamp":now(),"event_type":event_type,"actor":actor,"capability":capability,
           "input_refs":list(input_refs),"output_refs":list(output_refs),"previous_state":previous_state,
           "new_state":new_state,"caused_by":caused_by,"parent_event":parent_event,"status":status,
           "provenance":provenance or {}}
        self.store.state_event(e);self.store.update_state_journey(task_id,{"status":new_state or j.status,"updated_at":e["timestamp"]})
        return ExecutionEvent(**e)

    def checkpoint(self,task_id:str,current_step:str|None,active_step:str|None,completed_steps=(),remaining_steps=(),
                   active_character=None,active_capability=None,state="UNKNOWN",blocked_reason=None,waiting_for=None,
                   context_version=0,artifact_refs=(),event_refs=()):
        j=self.ensure_journey(task_id,"")
        cid=f"CP-{uuid4().hex[:10].upper()}"
        row={"checkpoint_id":cid,"journey_id":j.journey_id,"task_id":task_id,"timestamp":now(),
             "current_step":current_step,"completed_steps":list(completed_steps),"active_step":active_step,
             "remaining_steps":list(remaining_steps),"active_character":active_character,"active_capability":active_capability,
             "state":state,"blocked_reason":blocked_reason,"waiting_for":waiting_for,"context_version":context_version,
             "artifact_refs":list(artifact_refs),"event_refs":list(event_refs)}
        self.store.state_checkpoint(row);self.store.update_state_journey(task_id,{"updated_at":row["timestamp"]})
        return Checkpoint(**row)

    def latest_checkpoint(self,task_id): 
        row=self.store.latest_state_checkpoint(task_id); return Checkpoint(**row) if row else None
    def events(self,task_id):
        return tuple(ExecutionEvent(**x) for x in self.store.state_events(task_id))
    def resolve(self,task_id=None,conversation_id=None):
        if task_id:
            j=self.store.get_state_journey_by_task(task_id)
            return (j.get("journey_id"),task_id) if j else (None,task_id)
        if conversation_id:
            rows=self.store.state_journeys_by_conversation(conversation_id)
            if len(rows)==1:return rows[0]["journey_id"],rows[0]["task_id"]
            if len(rows)>1:return None,None
        rows=self.store.active_state_journeys()
        if len(rows)==1:return rows[0]["journey_id"],rows[0]["task_id"]
        return None,None

    def situation(self,task_id:str,level:SituationLevel)->SituationAwarenessResponse:
        j=self.store.get_state_journey_by_task(task_id)
        cp=self.latest_checkpoint(task_id);events=self.events(task_id)
        if not j:return SituationAwarenessResponse(level=level)
        sources=tuple(dict.fromkeys(["journey:"+j["journey_id"],*(f"event:{e.event_id}" for e in events[-20:]),*( [f"checkpoint:{cp.checkpoint_id}"] if cp else [])]))
        if level is SituationLevel.HISTORY:
            if not events:return SituationAwarenessResponse(level,uncertainty=("NO_AUTHORITATIVE_EVENT_RECORD",),sources=sources)
            hist=tuple({"event_id":e.event_id,"type":e.event_type,"actor":e.actor,"timestamp":e.timestamp,
                        "previous_state":e.previous_state,"new_state":e.new_state,"caused_by":e.caused_by,"status":e.status} for e in events[-20:])
            return SituationAwarenessResponse(level,history=hist,sources=sources,truth_class=TruthClass.RECORDED_FACT,status="RECORDED")
        if level is SituationLevel.CURRENT:
            if not cp:return SituationAwarenessResponse(level,uncertainty=("NO_AUTHORITATIVE_CHECKPOINT",),sources=sources)
            current={"checkpoint_id":cp.checkpoint_id,"step":cp.current_step,"active_step":cp.active_step,"character":cp.active_character,
                     "capability":cp.active_capability,"state":cp.state,"completed_steps":list(cp.completed_steps),
                     "remaining_steps":list(cp.remaining_steps),"blocked_reason":cp.blocked_reason,"waiting_for":cp.waiting_for}
            blocking={"reason":cp.blocked_reason,"waiting_for":cp.waiting_for} if cp.blocked_reason or cp.waiting_for else None
            return SituationAwarenessResponse(level,current=current,blocking=blocking,sources=sources,
                                              truth_class=TruthClass.RECORDED_FACT,status="RECORDED")
        if not cp:return SituationAwarenessResponse(level,uncertainty=("NO_AUTHORITATIVE_CHECKPOINT",),sources=sources)
        remaining=list(cp.remaining_steps)
        if cp.blocked_reason or cp.waiting_for:
            nxt={"type":NextType.BLOCKED.value,"description":cp.blocked_reason or f"waiting for {cp.waiting_for}"}
            tc=TruthClass.BLOCKED;status="BLOCKED"
        elif remaining:
            nxt={"type":NextType.RECORDED_NEXT_STEP.value,"description":remaining[0]}
            tc=TruthClass.PROJECTION;status="RECORDED_NEXT_STEP"
        else:
            nxt={"type":NextType.NO_REMAINING_STEPS.value,"description":"No remaining recorded steps."}
            tc=TruthClass.RECORDED_FACT;status="NO_REMAINING_STEPS"
        return SituationAwarenessResponse(level,next=nxt,sources=sources,truth_class=tc,status=status)

    def pause(self,task_id,reason="Human requested pause."):
        self.record_event(task_id,"HUMAN_INTERRUPTION",actor="human",new_state="PAUSING",provenance={"reason":reason})
        from criterivox.application.home03_runtime import home03_runtime
        return home03_runtime.pause(task_id,reason)
    def resume(self,task_id):
        from criterivox.application.home03_runtime import home03_runtime
        result=home03_runtime.resume(task_id);self.record_event(task_id,"TASK_RESUMED",actor="human",new_state="RESUMED");return result

state_runtime=StateRuntime()
