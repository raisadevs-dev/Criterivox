from __future__ import annotations
<<<<<<< HEAD
from dataclasses import asdict,dataclass
from datetime import datetime,timezone
from hashlib import sha256
import re
from typing import Any,Literal
from .home03_models import adaptive_intent_model
from .home03_planner import runtime_adaptive_planner
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
 def __init__(self):self.mode:OversightMode='HITL';self.budgets={f'Home {i:02d}':100 for i in range(1,9)};self.traces=[];self.checkpoints={}
 @staticmethod
 def _now():return datetime.now(timezone.utc).isoformat()
 def safety_check(self,message:str)->dict[str,Any]:
  reasons=[];status='clear'
  if not message.strip():reasons.append('A non-empty request is required.');status='review'
  if any(p.search(message) for p in self._INJECTION):reasons.append('Potential instruction-injection pattern detected.');status='blocked'
  if any(p.search(message) for p in self._OUT_OF_SCOPE):reasons.append('Request appears to target private credentials or unauthorized access.');status='blocked'
  if re.search(r'\bcontradict\b.*\b(yes|no)\b|\bmust\b.*\bmust not\b',message,re.I):reasons.append('Potentially contradictory constraints require clarification.');status='review' if status!='blocked' else status
  return {'status':status,'reasons':reasons,'policy':'syvax-preflight-v2'}
 def extract_intent(self,message:str)->Intent:
  p=adaptive_intent_model.predict({'text':message});entities=tuple(sorted(set(re.findall(r'\b[A-Z][A-Za-z]{2,}\b',message))));return Intent(message.strip(),p['label'],float(p['confidence']),entities)
 def compile_plan(self,message:str,task_id:str|None=None,signals:dict[str,Any]|None=None)->TaskPlan:
  intent=self.extract_intent(message);task_id=task_id or 'S3-'+sha256(f'{message}:{self._now()}'.encode()).hexdigest()[:12];signals=signals or {};text=message.lower();routes={'analyze':[RouteStep('Dharen','Home 02','context intelligence','structure task context'),RouteStep('Tarkis','Home 04','hypothesis challenge','question candidate explanations'),RouteStep('Medrus','Home 06','evidence investigation','test claims against evidence'),RouteStep('Syvax','Home 03','output translation','return an inspectable human-facing result')],'compare':[RouteStep('Dharen','Home 02','context normalization','establish comparable context'),RouteStep('Pramon','Home 05','decision planning','construct trade-offs'),RouteStep('Syvax','Home 03','adaptive rendering','render comparison for the task')],'explain':[RouteStep('Vivren','Home 04','reasoning critique','inspect reasoning structure'),RouteStep('Epistre','Home 06','provenance','surface evidence lineage'),RouteStep('Syvax','Home 03','adaptive rendering','translate explanation')],'build':[RouteStep('Dharen','Home 02','context constraints','establish requirements'),RouteStep('Kaelen','Home 01','construction','build the requested artifact'),RouteStep('Syvax','Home 03','output translation','present implementation status')],'explore':[RouteStep('Dharen','Home 02','context framing','frame the exploration'),RouteStep('Tarkis','Home 04','question generation','surface alternatives and gaps'),RouteStep('Syvax','Home 03','output translation','organize findings')],'decide':[RouteStep('Dharen','Home 02','context framing','establish decision context'),RouteStep('Pramon','Home 05','decision planning','evaluate options and constraints'),RouteStep('Manis','Home 07','human challenge','stress-test the decision from the human side'),RouteStep('Syvax','Home 03','decision rendering','return options and trade-offs')]};steps=list(routes.get(intent.intent_type,[RouteStep('Dharen','Home 02','context framing','establish context'),RouteStep('Syvax','Home 03','dialogue','retain the human boundary')]))
  if signals.get('evidence_required') or any(k in text for k in ('source','evidence','citation','verify')):
   if not any(s.actor=='Medrus' for s in steps):steps.insert(max(1,len(steps)-1),RouteStep('Medrus','Home 06','evidence investigation','evidence requirement raised by task signals'))
   if not any(s.actor=='Epistre' for s in steps):steps.insert(max(1,len(steps)-1),RouteStep('Epistre','Home 06','provenance','evidence lineage requested'))
  if signals.get('human_challenge') and not any(s.actor=='Manis' for s in steps):steps.insert(max(1,len(steps)-1),RouteStep('Manis','Home 07','human challenge','risk signal requires human-side challenge'))
  if signals.get('skip_hypothesis'):steps=[s for s in steps if s.actor!='Tarkis']
  return TaskPlan(task_id,intent,tuple(steps),self._now())
 def candidate_route(self,plan:TaskPlan)->dict[str,Any]:return runtime_adaptive_planner.propose(plan)
 def revise_from_runtime(self,plan:TaskPlan,event:dict[str,Any])->dict[str,Any]:
  signals,_=runtime_adaptive_planner.revise(plan,event);revised=self.compile_plan(plan.intent.goal,plan.task_id,signals);candidate=self.candidate_route(revised);return {'signals':signals,'plan':asdict(revised),'candidate':candidate}
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
=======
from dataclasses import dataclass
from datetime import datetime, timezone
from hashlib import sha256
import re
from typing import Any

@dataclass(frozen=True)
class Intent:
    goal: str
    intent_type: str
    confidence: float
    entities: tuple[str, ...] = ()
@dataclass(frozen=True)
class RouteStep:
    actor: str
    home: str
    capability: str
    reason: str
@dataclass(frozen=True)
class TaskPlan:
    task_id: str
    intent: Intent
    steps: tuple[RouteStep, ...]
    created_at: str
@dataclass(frozen=True)
class SafetyResult:
    status: str
    reasons: tuple[str, ...]

class SyvaxEngine:
    """Home 03 computational actor with pluggable deterministic baselines."""
    rules=(('analyze',r'\b(analy[sz]e|investigate|understand|examine)\b'),('compare',r'\b(compare|versus|vs\.?|trade[- ]?off)\b'),('explain',r'\b(explain|why|interpret|clarify)\b'),('build',r'\b(build|implement|create|develop|code)\b'),('explore',r'\b(explore|research|find|discover)\b'))
    injections=(r'ignore\s+(all|any|previous|prior)\s+instructions',r'reveal\s+(the\s+)?system\s+prompt',r'bypass\s+(safety|guardrails|security)')
    def __init__(self):
        self.tasks:dict[str,TaskPlan]={}; self.mode='HITL'; self.budgets={f'home-{i:02d}':100 for i in range(1,9)}; self.traces:list[dict[str,Any]]=[]
    def safety_check(self,message:str)->SafetyResult:
        reasons=tuple('Potential instruction-injection pattern detected.' for p in self.injections if re.search(p,message,re.I))
        if reasons:return SafetyResult('blocked',reasons)
        if len(message.strip())<3:return SafetyResult('review',('The request is too short to establish a reliable goal.',))
        return SafetyResult('clear',())
    def extract_intent(self,message:str)->Intent:
        matches=[name for name,p in self.rules if re.search(p,message,re.I)]; kind=matches[0] if matches else 'general'; conf=min(.55+.12*len(matches),.95) if matches else .42
        entities=tuple(sorted(set(re.findall(r'\b[A-Z][A-Za-z]{2,}\b',message))))
        return Intent(message.strip(),kind,conf,entities)
    def compile_plan(self,message:str,task_id:str|None=None)->TaskPlan:
        intent=self.extract_intent(message); tid=task_id or 'S3-'+sha256(f'{message}:{datetime.now(timezone.utc).isoformat()}'.encode()).hexdigest()[:12]
        routes={
        'analyze':(('Dharen','Home 02','context structuring','establish context before downstream reasoning'),('Tarkis','Home 04','hypothesis generation','question competing explanations'),('Medrus','Home 06','evidence/experiment','test claims against evidence'),('Syvax','Home 03','output synthesis','translate completed work for the human')),
        'compare':(('Dharen','Home 02','context structuring','normalize comparison context'),('Pramon','Home 05','decision planning','construct trade-off frame'),('Syvax','Home 03','output synthesis','render decision-oriented comparison')),
        'explain':(('Vivren','Home 04','reasoning critique','inspect reasoning'),('Epistre','Home 06','provenance','surface evidence lineage'),('Syvax','Home 03','output synthesis','present an accessible explanation')),
        'build':(('Dharen','Home 02','context structuring','establish implementation constraints'),('Kaelen','Home 01','build/experimentation','construct implementation'),('Syvax','Home 03','output synthesis','present implementation result')),
        'explore':(('Dharen','Home 02','context structuring','frame exploration'),('Tarkis','Home 04','question generation','generate alternatives and gaps'),('Syvax','Home 03','output synthesis','organize findings'))}
        steps=tuple(RouteStep(*x) for x in routes.get(intent.intent_type,(('Dharen','Home 02','context structuring','establish context'),('Syvax','Home 03','output synthesis','retain dialogue frame'))))
        plan=TaskPlan(tid,intent,steps,datetime.now(timezone.utc).isoformat()); self.tasks[tid]=plan; return plan
    def steer(self,task_id:str,correction:str):
        if task_id not in self.tasks:raise KeyError(f'Unknown task: {task_id}')
        if not correction.strip():raise ValueError('A steering correction is required.')
        return {'type':'STEER_EXECUTION','task_id':task_id,'paused':True,'correction':correction.strip(),'recipients':['Anuka','Dharen'],'resume_required':True}
    def set_oversight(self,mode:str):
        if mode not in {'HITL','HOTL'}:raise ValueError('Oversight mode must be HITL or HOTL.')
        self.mode=mode; return mode
    def set_budget(self,home:str,limit:int):
        key=home.lower().replace(' ','-');
        if not key.startswith('home-'):key='home-'+key
        if key not in self.budgets:raise KeyError(f'Unknown home: {home}')
        self.budgets[key]=max(1,min(1000,int(limit))); return self.budgets[key]
    def record_trace(self,task_id,source,target,score,reason):self.traces.append({'task_id':task_id,'source':source,'target':target,'score':score,'reason':reason,'at':datetime.now(timezone.utc).isoformat()})
>>>>>>> origin/main
syvax_engine=SyvaxEngine()
