from __future__ import annotations
<<<<<<< HEAD

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from hashlib import sha256
from typing import Any, Literal

Mode = Literal["HITL", "HOTL"]

@dataclass(frozen=True)
class BloomPetal:
    home: str
    label: str
    status: str
    budget: int
    active: bool
    confidence: float | None

class BloomController:
    HOMES = {
        "Home 01": "Sandre / Data Foundation", "Home 02": "Dharen / Context", "Home 03": "Syvax / Gateway",
        "Home 04": "Vivren + Tarkis / Intelligence", "Home 05": "Pramon + Bodhex / Planning",
        "Home 06": "Medrus + Epistre + Veridat / Evidence", "Home 07": "Manis / Human Challenge", "Home 08": "Viveda / Knowledge",
    }
    def __init__(self) -> None:
        self.mode: Mode = "HITL"
        self.budgets = {home: 100 for home in self.HOMES}
        self.active: set[str] = set()
        self.seeds: list[dict[str, Any]] = []
        self.checkpoints: list[dict[str, Any]] = []
        self.traces: list[dict[str, Any]] = []

    @staticmethod
    def _now() -> str:
        return datetime.now(timezone.utc).isoformat()

    def petals(self) -> list[dict[str, Any]]:
        return [asdict(BloomPetal(home, label, "ACTIVE" if home in self.active else "IDLE", self.budgets[home], home in self.active, None)) for home, label in self.HOMES.items()]

    def route_seed(self, source: str, destinations: list[str], payload: dict[str, Any]) -> dict[str, Any]:
        item = {"seed_id": f"seed-{len(self.seeds)+1:06d}", "source": source, "destinations": destinations, "payload": payload, "created_at": self._now()}
        self.seeds.append(item)
        self.active.update(destinations)
        return item

    def checkpoint(self, task_id: str, state: dict[str, Any]) -> dict[str, Any]:
        serialized = repr(sorted(state.items())).encode()
        item = {"checkpoint_id": f"bloom-cp-{len(self.checkpoints)+1:06d}", "task_id": task_id, "state_hash": sha256(serialized).hexdigest(), "state": state, "created_at": self._now()}
        self.checkpoints.append(item)
        return item

    def evaluate(self, task_id: str, source: str, target: str, score: float, *, reason: str = "") -> dict[str, Any]:
        score = max(0.0, min(1.0, float(score)))
        status = "ANOMALY" if score < .5 else ("REVIEW" if score < .75 else "OK")
        item = {"trace_id": f"bloom-trace-{len(self.traces)+1:06d}", "task_id": task_id, "source": source, "target": target, "score": score, "status": status, "reason": reason, "created_at": self._now()}
        self.traces.append(item)
        return item

    def set_budget(self, home: str, budget: int) -> int:
        if home not in self.HOMES:
            raise KeyError(f"Unknown Bloom home: {home}")
        self.budgets[home] = max(1, min(1000, int(budget)))
        return self.budgets[home]

    def set_mode(self, mode: Mode) -> str:
        if mode not in {"HITL", "HOTL"}:
            raise ValueError("Bloom mode must be HITL or HOTL.")
        self.mode = mode
        return mode

    def state(self) -> dict[str, Any]:
        return {"mode": self.mode, "petals": self.petals(), "active_homes": sorted(self.active), "seeds": self.seeds[-20:], "checkpoints": self.checkpoints[-20:], "traces": self.traces[-50:]}

bloom_controller = BloomController()
=======
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
>>>>>>> origin/main
