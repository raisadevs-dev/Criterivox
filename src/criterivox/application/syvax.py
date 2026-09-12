from __future__ import annotations
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
syvax_engine=SyvaxEngine()
