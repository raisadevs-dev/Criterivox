from __future__ import annotations

from dataclasses import dataclass
from math import exp, log
from statistics import mean, pstdev
from typing import Any

@dataclass(frozen=True)
class MLResult:
    model: str
    score: float
    label: str
    features: dict[str, float]
    training_rows: int
    inference_seconds: float
    rationale: tuple[str, ...] = ()

class LocalMLStack:
    """Dependency-light local ML baseline.

    Stage 1 is deliberately classical and deterministic. It trains from supplied
    numeric rows, never sends data off-device, and exposes a stable adapter for
    later sklearn/ONNX/LLM implementations without coupling the domain model.
    """
    def _numeric(self, rows: list[dict[str, Any]]) -> list[dict[str, float]]:
        out=[]
        for row in rows:
            vals={k: float(v) for k,v in row.items() if isinstance(v,(int,float)) and not isinstance(v,bool)}
            if vals: out.append(vals)
        return out

    def train_anomaly_baseline(self, rows: list[dict[str, Any]]) -> dict[str, Any]:
        numeric=self._numeric(rows)
        if not numeric: return {"model":"robust_zscore","trained":False,"rows":0,"means":{},"stds":{}}
        keys=sorted({k for row in numeric for k in row})
        means={k:mean(row[k] for row in numeric if k in row) for k in keys}
        stds={k:max(pstdev([row[k] for row in numeric if k in row]),1e-9) if sum(k in r for r in numeric)>1 else 1.0 for k in keys}
        return {"model":"robust_zscore","trained":True,"rows":len(numeric),"means":means,"stds":stds}

    def score(self, model: dict[str,Any], row: dict[str,Any]) -> MLResult:
        import time
        start=time.perf_counter(); features={}
        for key,mu in model.get("means",{}).items():
            value=row.get(key)
            if isinstance(value,(int,float)) and not isinstance(value,bool):
                features[key]=abs((float(value)-mu)/model["stds"].get(key,1.0))
        raw=mean(features.values()) if features else 0.0
        score=1.0/(1.0+exp(-min(raw,20.0)))
        label="anomaly" if score>=0.85 else "normal"
        return MLResult(model=model.get("model","robust_zscore"),score=score,label=label,features=features,training_rows=int(model.get("rows",0)),inference_seconds=time.perf_counter()-start,rationale=("Progressive local baseline: robust z-score over numeric fields.",))

    def semantic_readability(self, tags: dict[str,str], required: tuple[str,...]) -> float:
        if not required: return 1.0
        return round(sum(1 for key in required if key in tags and str(tags[key]).strip())/len(required),4)

    def gate_threshold(self, scores: list[float], minimum: float=0.85) -> dict[str,Any]:
        if not scores: return {"passed":False,"threshold":minimum,"mean":0.0,"variance":0.0,"reason":"No evaluation scores supplied."}
        avg=mean(scores); variance=pstdev(scores)**2 if len(scores)>1 else 0.0
        return {"passed":avg>=minimum,"threshold":minimum,"mean":avg,"variance":variance,"reason":"Evaluation mean meets provisional gate." if avg>=minimum else "Evaluation mean is below the provisional gate."}
