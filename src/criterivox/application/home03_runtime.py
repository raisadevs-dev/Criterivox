from __future__ import annotations
import asyncio
from dataclasses import dataclass,asdict
from datetime import datetime,timezone
from hashlib import sha256
from .home03_store import home03_store
@dataclass
class WorkflowState:
 task_id:str;status:str='running';revision:int=0;correction:str='';approval:str='';budget:dict[str,int]|None=None;remaining:dict[str,int]|None=None;updated_at:str=''
class Home03Runtime:
 def __init__(self):self.workflows={};self.events=[];self.branches={};self.pollen=[];self.checkpoints={};self._wake={}
 def _now(self):return datetime.now(timezone.utc).isoformat()
 def emit(self,event_type,task_id,**payload):
  e={'event_id':'evt-'+sha256(f'{task_id}:{len(self.events)}:{self._now()}'.encode()).hexdigest()[:14],'type':event_type,'task_id':task_id,'created_at':self._now(),**payload};self.events.append(e);home03_store.event(event_type,task_id,e);return e
 def start(self,task_id,plan):
  if task_id in self.workflows:return self.emit('WORKFLOW_REUSED',task_id,plan=plan)
  self.workflows[task_id]=WorkflowState(task_id=task_id,updated_at=self._now(),budget={},remaining={});self._wake[task_id]=asyncio.Event();self._wake[task_id].set();return self.emit('WORKFLOW_STARTED',task_id,plan=plan)
 def _ensure(self,task_id):
  if task_id not in self.workflows:self.start(task_id,{})
  self._wake.setdefault(task_id,asyncio.Event());return self.workflows[task_id]
 def pause(self,task_id,correction=''):w=self._ensure(task_id);w.status='paused';w.correction=correction;w.revision+=1;w.updated_at=self._now();self._wake[task_id].clear();return self.emit('WORKFLOW_PAUSED',task_id,correction=correction,revision=w.revision)
 def resume(self,task_id):w=self._ensure(task_id);w.status='running';w.updated_at=self._now();self._wake[task_id].set();return self.emit('WORKFLOW_RESUMED',task_id,revision=w.revision)
 async def wait_if_paused(self,task_id):self._ensure(task_id);await self._wake[task_id].wait()
 def approve(self,task_id,action,diff=None):w=self._ensure(task_id);w.approval=action;w.updated_at=self._now();return self.emit('WORKFLOW_INTERVENTION',task_id,action=action,diff=diff or {},revision=w.revision)
 def checkpoint(self,task_id,state):
  canonical=repr(sorted(state.items())).encode();cid='cp-'+sha256(f'{task_id}:{canonical!r}'.encode()).hexdigest()[:14];item={'checkpoint_id':cid,'task_id':task_id,'state_hash':sha256(canonical).hexdigest(),'state':state,'created_at':self._now()};self.checkpoints[cid]=item;home03_store.checkpoint('default','main',state,item['state_hash']);self.emit('CHECKPOINT_CREATED',task_id,checkpoint=item);return item
 def restore(self,checkpoint_id):
  cp=self.checkpoints.get(checkpoint_id)
  if not cp:raise KeyError(f'Unknown checkpoint: {checkpoint_id}')
  task_id=cp['task_id'];w=self._ensure(task_id);state=cp.get('state',{})
  if isinstance(state,dict) and isinstance(state.get('workflow'),dict):
   r=state['workflow'];w.status=r.get('status',w.status);w.revision=int(r.get('revision',w.revision));w.correction=r.get('correction','');w.approval=r.get('approval','');w.budget=r.get('budget',w.budget);w.remaining=r.get('remaining',w.remaining)
  (self._wake[task_id].clear() if w.status=='paused' else self._wake[task_id].set());self.emit('REPLAY_RESTORED',task_id,checkpoint_id=checkpoint_id,state_hash=cp['state_hash']);return {'restored':True,'checkpoint':cp,'workflow':asdict(w),'branchable':True}
 def fork(self,checkpoint_id,branch_name):
  cp=self.checkpoints.get(checkpoint_id)
  if not cp:raise KeyError(f'Unknown checkpoint: {checkpoint_id}')
  bid='branch-'+sha256(f'{checkpoint_id}:{branch_name}'.encode()).hexdigest()[:12];item={'branch_id':bid,'name':branch_name,'parent_checkpoint':checkpoint_id,'state':cp['state'],'created_at':self._now()};self.branches[bid]=item;self.emit('BRANCH_CREATED',cp['task_id'],branch=item);return item
 def ingest_pollen(self,event):
  item={'pollen_id':'pol-'+sha256(repr(event).encode()).hexdigest()[:14],'source_event':event.get('event_id'),'task_id':event.get('task_id'),'source':event.get('source'),'target':event.get('target'),'claim':event.get('claim'),'confidence':event.get('confidence'),'created_at':self._now()};self.pollen.append(item);home03_store.pollen(str(event.get('task_id','')),str(event.get('source','')),str(event.get('target','')),event,item['confidence']);return item
 def allocate(self,task_id,home,tokens):w=self._ensure(task_id);w.budget=w.budget or {};w.remaining=w.remaining or {};w.budget[home]=max(1,int(tokens));w.remaining[home]=w.budget[home];return self.emit('COMPUTE_BUDGET_SET',task_id,home=home,tokens=w.budget[home])
 def consume(self,task_id,home,cost):
  w=self._ensure(task_id);w.remaining=w.remaining or {};remaining=w.remaining.get(home,w.budget.get(home,100) if w.budget else 100)-max(0,int(cost));w.remaining[home]=remaining;self.emit('COMPUTE_BUDGET_CONSUMED',task_id,home=home,cost=cost,remaining=remaining)
  if remaining<0:w.status='paused';self._wake[task_id].clear();self.emit('COMPUTE_BUDGET_EXHAUSTED',task_id,home=home,remaining=remaining);raise RuntimeError(f'Compute budget exhausted for {home}.')
  return remaining
 def snapshot(self):return {'workflows':{k:asdict(v) for k,v in self.workflows.items()},'events':self.events[-200:],'branches':self.branches,'pollen':self.pollen[-200:],'checkpoints':self.checkpoints}
home03_runtime=Home03Runtime()
