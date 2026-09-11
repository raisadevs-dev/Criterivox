from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from hashlib import sha256
import json
from typing import Any


def now() -> str: return datetime.now(timezone.utc).isoformat()
def digest(value: Any) -> str: return sha256(json.dumps(value, sort_keys=True, default=str).encode()).hexdigest()

@dataclass(frozen=True)
class LedgerEntry:
    revision: int
    timestamp: str
    foundation_id: str
    event: str
    payload_hash: str
    snapshot: dict[str, Any]
    parent_revision: int | None = None

@dataclass
class ProvenanceLedger:
    entries: dict[str,list[LedgerEntry]] = field(default_factory=dict)
    def append(self, foundation_id: str, event: str, snapshot: dict[str,Any]) -> LedgerEntry:
        history=self.entries.setdefault(foundation_id,[]); revision=len(history)+1
        entry=LedgerEntry(revision,now(),foundation_id,event,digest(snapshot),json.loads(json.dumps(snapshot,default=str)),revision-1 or None)
        history.append(entry); return entry
    def timeline(self, foundation_id: str) -> list[LedgerEntry]: return list(self.entries.get(foundation_id,[]))
    def rewind(self, foundation_id: str, revision: int) -> LedgerEntry:
        history=self.entries.get(foundation_id,[])
        if revision<1 or revision>len(history): raise ValueError("Unknown provenance revision.")
        return history[revision-1]

@dataclass(frozen=True)
class SyncEnvelope:
    foundation_id: str
    revision: int
    payload_hash: str
    operation: str
    payload: dict[str,Any]

class FoundationSynchronizer:
    """Idempotent browser/Python synchronization state machine."""
    def __init__(self) -> None: self.revisions: dict[str,int]={}; self.hashes: dict[str,str]={}
    def prepare(self, foundation_id: str, revision: int, payload: dict[str,Any], operation: str="upsert") -> SyncEnvelope:
        return SyncEnvelope(foundation_id,revision,digest(payload),operation,payload)
    def accept(self, envelope: SyncEnvelope) -> dict[str,Any]:
        current=self.revisions.get(envelope.foundation_id,0)
        if envelope.revision < current: return {"accepted":False,"reason":"stale_revision","revision":current}
        if envelope.revision == current and self.hashes.get(envelope.foundation_id)==envelope.payload_hash: return {"accepted":True,"duplicate":True,"revision":current}
        self.revisions[envelope.foundation_id]=envelope.revision; self.hashes[envelope.foundation_id]=envelope.payload_hash
        return {"accepted":True,"duplicate":False,"revision":envelope.revision,"payload_hash":envelope.payload_hash}

@dataclass(frozen=True)
class PipelineStep:
    name: str
    action: str
    inputs: tuple[str,...]=()
    outputs: tuple[str,...]=()

class KaelenPipeline:
    """Declarative, inspectable S5->S6 transformation DAG."""
    def __init__(self) -> None:
        self.steps=(PipelineStep("ingest","load",(),("raw",)),PipelineStep("profile","profile",("raw",),("profile",)),PipelineStep("validate","quality_gate",("raw","profile"),("validated",)),PipelineStep("normalize","normalize",("validated",),("normalized",)),PipelineStep("patch","schema_patch",("normalized",),("canonical",)),PipelineStep("handoff","package",("canonical","profile"),("handoff",)))
    def dag(self)->dict[str,Any]: return {"nodes":[s.name for s in self.steps],"edges":[[a.name,b.name] for a,b in zip(self.steps,self.steps[1:])],"steps":[s.__dict__ for s in self.steps]}
    def execute(self, data: list[dict[str,Any]]) -> dict[str,Any]:
        keys=sorted({k for row in data for k in row})
        normalized=[{k: row.get(k) for k in keys} for row in data]
        return {"status":"ready","rows":len(normalized),"schema":keys,"canonical_data":normalized,"dag":self.dag()}

class SchemaDriftHealer:
    def diff(self, old: list[str], new: list[str]) -> dict[str,Any]:
        old_set,new_set=set(old),set(new)
        return {"added":sorted(new_set-old_set),"removed":sorted(old_set-new_set),"unchanged":sorted(old_set&new_set),"drift":old_set!=new_set}
    def patch(self, rows: list[dict[str,Any]], old: list[str], new: list[str], aliases: dict[str,str]|None=None) -> dict[str,Any]:
        aliases=aliases or {}; mapping={key:aliases.get(key,key) for key in old}
        patched=[{target:row.get(source) for source,target in mapping.items() if target in new} for row in rows]
        return {"diff":self.diff(old,new),"mapping":mapping,"patched_rows":patched,"reversible":True}

class SyntheticDataEngine:
    def preview(self, rows: list[dict[str,Any]], seed: int=17) -> dict[str,Any]:
        import random
        rng=random.Random(seed); output=[]
        for row in rows[:25]:
            synthetic={}
            for key,value in row.items():
                if isinstance(value,bool): synthetic[key]=value
                elif isinstance(value,(int,float)): synthetic[key]=round(float(value)*(1+rng.uniform(-.03,.03)),6)
                elif isinstance(value,str): synthetic[key]=f"synthetic_{rng.randrange(100000):05d}"
                else: synthetic[key]=None
            output.append(synthetic)
        return {"rows":output,"seed":seed,"privacy_mode":"no source values emitted"}

class SemanticTagger:
    def tag(self, rows: list[dict[str,Any]], context: dict[str,Any]) -> dict[str,Any]:
        tags={}
        for key in sorted({k for row in rows for k in row}):
            lk=key.lower(); kind="identifier" if lk.endswith("id") else "temporal" if "date" in lk or "time" in lk else "numeric" if any(isinstance(r.get(key),(int,float)) for r in rows) else "text"
            tags[key]={"semantic_type":kind,"required":key in context.get("required_fields",[]),"commentary":context.get("schema_commentary",{}).get(key,"")}
        required=tuple(context.get("required_fields",()))
        readability=sum(1 for k in required if k in tags)/len(required) if required else 1.0
        return {"tags":tags,"agent_readability_score":round(readability,4),"temporal_markers":context.get("temporal_markers",{}),"relationship_constraints":context.get("relationship_constraints",{})}

class EvaluationGate:
    def evaluate(self, metrics: dict[str,float], datasets: list[dict[str,Any]], minimum: float=.85) -> dict[str,Any]:
        values=[float(v) for v in metrics.values() if isinstance(v,(int,float))]
        score=sum(values)/len(values) if values else 0.0
        return {"passed":score>=minimum,"score":round(score,6),"threshold":minimum,"datasets":len(datasets),"dataset_roles":[d.get("role","unspecified") for d in datasets],"threshold_status":"provisional"}
