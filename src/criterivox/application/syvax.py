from __future__ import annotations
from dataclasses import asdict,dataclass
from datetime import datetime,timezone
from hashlib import sha256
import re
from typing import Any,Literal
from .home03_models import adaptive_intent_model
OversightMode=Literal['HITL','HOTL']
@dataclass(frozen=True)
class Intent: goal:str; intent_type:str; confidence:float; entities:tuple[str,...]
@dataclass(frozen=True)
class RouteStep: actor:str; home:str; capability:str; reason:str
@dataclass(frozen=True)
class TaskPlan: task_id:str; intent:Intent; steps:tuple[RouteStep,...]; created_at:str
@dataclass(frozen=True)
class Trace: trace_id:str; task_id:str; source:str; target:str; status:str; score:float; reason:str; created_at:str
class SyvaxEngine:
 _INJECTION=(re.compile(r'ignore\s+(all|any|previous|prior)\s+instructions',re.I),re.compile(r'reveal\s+(the\s+)?system\s+prompt',re.I),re.compile(r'bypass\s+(safety|guardrails|security)',re.I),re.compile(r'disable\s+(security|guardrails)',re.I))
 _OUT_OF_SCOPE=(re.compile(r'private\s+passwords?',re.I),re.compile(r'steal\s+(credentials|accounts?)',re.I))
 def __init__(self): self.mode:OversightMode='HITL';self.budgets={f'Home {i:02d}':100 for i in range(1,9)};self.traces=[];self.checkpoints={}
 @staticmethod
 def _now():return datetime.now(timezone.utc).isoformat()
 def safety_check(self,message:str)->dict[str,Any]:
  reasons=[];status='clear'
  if not message.strip(): reasons.append('A non-empty request is required.');status='review'
  if any(p.search(message) for p in self._INJECTION): reasons.append('Potential instruction-injection pattern detected.');status='blocked'
  if any(p.search(message) for p in self._OUT_OF_SCOPE): reasons.append('Request appears to target private credentials or unauthorized access.');status='blocked'
  if re.search(r'\bcontradict\b.*\b(yes|no)\b|\bmust\b.*\bmust not\b',message,re.I): reasons.append('Potentially contradictory constraints require clarification.');status='review' if status!='blocked' else status
  return {'status':status,'reasons':reasons,'policy':'syvax-preflight-v2'}
 def extract_intent(self,message:str)->Intent:
  p=adaptive_intent_model.predict({'text':message});entities=tuple(sorted(set(re.findall(r'\b[A-Z][A-Za-z]{2,}\b',message))));return Intent(message.strip(),p['label'],float(p['confidence']),entities)
 def compile_plan(self,message:str,task_id:str|None=None,signals:dict[str,Any]|None=None)->TaskPlan:
  intent=self.extract_intent(message);task_id=task_id or 'S3-'+sha256(f'{message}:{self._now()}'.encode()).hexdigest()[:12];signals=signals or {}; text=message.lower()
  routes={
   'analyze':[RouteStep('Dharen','Home 02','context intelligence','structure task context'),RouteStep('Tarkis','Home 04','hypothesis challenge','question candidate explanations'),RouteStep('Medrus','Home 06','evidence investigation','test claims against evidence'),RouteStep('Syvax','Home 03','output translation','return an inspectable human-facing result')],
   'compare':[RouteStep('Dharen','Home 02','context normalization','establish comparable context'),RouteStep('Pramon','Home 05','decision planning','construct trade-offs'),RouteStep('Syvax','Home 03','adaptive rendering','render comparison for the task')],
   'explain':[RouteStep('Vivren','Home 04','reasoning critique','inspect reasoning structure'),RouteStep('Epistre','Home 06','provenance','surface evidence lineage'),RouteStep('Syvax','Home 03','adaptive rendering','translate explanation')],
   'build':[RouteStep('Dharen','Home 02','context constraints','establish requirements'),RouteStep('Kaelen','Home 01','construction','build the requested artifact'),RouteStep('Syvax','Home 03','output translation','present implementation status')],
   'explore':[RouteStep('Dharen','Home 02','context framing','frame the exploration'),RouteStep('Tarkis','Home 04','question generation','surface alternatives and gaps'),RouteStep('Syvax','Home 03','output translation','organize findings')],
   'decide':[RouteStep('Dharen','Home 02','context framing','establish decision context'),RouteStep('Pramon','Home 05','decision planning','evaluate options and constraints'),RouteStep('Manis','Home 07','human challenge','stress-test the decision from the human side'),RouteStep('Syvax','Home 03','decision rendering','return options and trade-offs')],
  }
  steps=list(routes.get(intent.intent_type,[RouteStep('Dharen','Home 02','context framing','establish context'),RouteStep('Syvax','Home 03','dialogue','retain the human boundary')]))
  if signals.get('evidence_required') or any(k in text for k in ('source','evidence','citation','verify')):
   if not any(s.actor=='Medrus' for s in steps):steps.insert(max(1,len(steps)-1),RouteStep('Medrus','Home 06','evidence investigation','evidence requirement raised by task signals'))
   if not any(s.actor=='Epistre' for s in steps):steps.insert(max(1,len(steps)-1),RouteStep('Epistre','Home 06','provenance','evidence lineage requested'))
  if signals.get('human_challenge') and not any(s.actor=='Manis' for s in steps):steps.insert(max(1,len(steps)-1),RouteStep('Manis','Home 07','human challenge','risk signal requires human-side challenge'))
  if signals.get('skip_hypothesis') and any(s.actor=='Tarkis' for s in steps):steps=[s for s in steps if s.actor!='Tarkis']
  return TaskPlan(task_id,intent,tuple(steps),self._now())
 def steer(self,task_id:str,correction:str):
  if not correction.strip():raise ValueError('A steering correction is required.')
  return {'type':'STEER_EXECUTION','task_id':task_id,'paused':True,'correction':correction.strip(),'recipients':['Anuka','Dharen'],'resume_required':True}
 def set_budget(self,home:str,limit:int)->int:
  if home not in self.budgets:raise KeyError(f'Unknown home: {home}')
  self.budgets[home]=max(1,min(1000,int(limit)));return self.budgets[home]
 def set_mode(self,mode:OversightMode)->str:
  if mode not in {'HITL','HOTL'}:raise ValueError('Oversight mode must be HITL or HOTL.')
  self.mode=mode;return mode
 def checkpoint(self,task_id,state):
  canonical=repr(sorted(state.items())).encode();item={'checkpoint_id':f'cp-{len(self.checkpoints)+1:06d}','task_id':task_id,'state_hash':sha256(canonical).hexdigest(),'state':state,'created_at':self._now()};self.checkpoints[item['checkpoint_id']]=item;return item
 def record_trace(self,task_id,source,target,score,status='ok',reason=''):
  item=Trace(f'trace-{len(self.traces)+1:06d}',task_id,source,target,status,max(0,min(1,float(score))),reason,self._now());self.traces.append(item);return asdict(item)
syvax_engine=SyvaxEngine()
