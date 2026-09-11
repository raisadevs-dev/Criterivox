from __future__ import annotations
from dataclasses import dataclass, field
from datetime import datetime, timezone
from hashlib import sha256
from typing import Any

@dataclass
class BloomController:
    mode: str = 'HITL'
    budgets: dict[str,int] = field(default_factory=lambda:{f'home-{i:02d}':100 for i in range(1,9)})
    checkpoints: list[dict[str,Any]] = field(default_factory=list)
    traces: list[dict[str,Any]] = field(default_factory=list)
    seeds: list[dict[str,Any]] = field(default_factory=list)
    active_homes: set[str] = field(default_factory=set)
    def _now(self): return datetime.now(timezone.utc).isoformat()
    def petals(self):
        names=('Data','Context','Interaction','Intelligence','Planning','Evidence','Human Challenge','Knowledge')
        return [{'home':f'home-{i:02d}','label':n,'active':f'home-{i:02d}' in self.active_homes,'energy':self.budgets[f'home-{i:02d}']} for i,n in enumerate(names,1)]
    def route_seed(self,source:str,destination:str,payload:dict[str,Any]):
        seed={'id':'seed-'+sha256(f'{source}:{destination}:{self._now()}'.encode()).hexdigest()[:10],'source':source,'destination':destination,'payload':payload,'created_at':self._now()};self.seeds.append(seed);return seed
    def pause_checkpoint(self,task_id:str,reason:str='human verification'):
        snapshot={'task_id':task_id,'reason':reason,'mode':self.mode,'budgets':dict(self.budgets),'active_homes':sorted(self.active_homes),'created_at':self._now()};snapshot['state_hash']=sha256(repr(sorted(snapshot.items())).encode()).hexdigest();self.checkpoints.append(snapshot);return snapshot
    def set_budget(self,home:str,limit:int):
        key=home.lower().replace(' ','-');key=key if key.startswith('home-') else 'home-'+key
        if key not in self.budgets:raise KeyError(f'Unknown home: {home}')
        self.budgets[key]=max(1,min(1000,int(limit)));return self.budgets[key]
    def evaluate_trace(self,task_id:str,source:str,target:str,score:float,reason:str=''):
        score=max(0.0,min(1.0,float(score)));status='ok' if score>=.7 else ('review' if score>=.4 else 'anomaly');item={'task_id':task_id,'source':source,'target':target,'score':score,'status':status,'reason':reason,'created_at':self._now()};self.traces.append(item);return item
    def set_mode(self,mode:str):
        if mode not in {'HITL','HOTL'}:raise ValueError('Bloom mode must be HITL or HOTL.')
        self.mode=mode;return mode
bloom_controller=BloomController()
