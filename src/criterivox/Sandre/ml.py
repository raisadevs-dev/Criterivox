from __future__ import annotations
from dataclasses import dataclass
from math import log1p
from typing import Any
from criterivox.context.ml import S6LearnedModelRegistry
@dataclass(frozen=True,slots=True)
class SandrePrediction:
    anomaly_score:float; readiness_score:float; signals:tuple[str,...]; model_version:str="sandre-quality-fused-1"; learned_state:str|None=None; learned_confidence:float|None=None
class SandreMLAgent:
    """Sandre quality baseline plus trained learned quality advisory."""
    def __init__(self,alert_threshold:float=.85,*,model_registry:S6LearnedModelRegistry|None=None):
        if not 0<alert_threshold<1:raise ValueError("alert_threshold must be between 0 and 1")
        self.alert_threshold=alert_threshold;self._baseline=None;self.model_registry=model_registry or S6LearnedModelRegistry();self.learned_model=self.model_registry.sandre;self.learned_model.load()
    def train(self,clean_rows:list[dict[str,Any]])->dict[str,float]:
        if not clean_rows:raise ValueError("clean_rows must not be empty")
        self._baseline=self.quality_features(clean_rows);return dict(self._baseline)
    @property
    def is_trained(self)->bool:return self._baseline is not None
    @property
    def learned_model_available(self)->bool:return self.learned_model.available
    def predict(self,rows:list[dict[str,Any]])->SandrePrediction:
        if not rows:return SandrePrediction(1.,0.,("empty_dataset",),learned_state="quarantine",learned_confidence=1.)
        fields=sorted({k for r in rows for k in r});missing=sum(1 for r in rows for k in fields if r.get(k) in (None,""));cells=max(1,len(rows)*max(1,len(fields)));missing_rate=missing/cells;duplicate_rate=1-len({self._stable_row(r) for r in rows})/len(rows);schema_penalty=max((abs(len(r)-len(fields))/max(1,len(fields)) for r in rows),default=0.);current=self.quality_features(rows);scale_penalty=0.
        if self._baseline is not None:scale_penalty=min(1.,abs(current["fields"]-max(1.,self._baseline["fields"]))/max(1.,self._baseline["fields"]))
        anomaly=min(1.,.45*missing_rate+.30*duplicate_rate+.15*schema_penalty+.10*scale_penalty);readiness=max(0.,1-anomaly);signals=[]
        if missing_rate>.05:signals.append("missingness")
        if duplicate_rate>0:signals.append("duplicate_candidates")
        if schema_penalty>0 or scale_penalty>0:signals.append("schema_inconsistency")
        if anomaly>=self.alert_threshold:signals.append("quarantine_review")
        state=conf=None
        if self.learned_model.available:
            p=self.learned_model.predict_one(f"rows={len(rows)} fields={len(fields)} missing_rate={missing_rate:.3f} duplicate_rate={duplicate_rate:.3f} schema_penalty={schema_penalty:.3f} anomaly={anomaly:.3f} readiness={readiness:.3f}")
            if p:state,conf=p.label,p.confidence;signals.append(f"learned_quality_{state}")
        return SandrePrediction(anomaly,readiness,tuple(signals),learned_state=state,learned_confidence=conf)
    @staticmethod
    def _stable_row(row):return "|".join(f"{k}={row[k]!r}" for k in sorted(row))
    @staticmethod
    def quality_features(rows):
        if not rows:return {"rows":0.,"fields":0.,"entropy_proxy":0.}
        fields={k for r in rows for k in r};unique=len({SandreMLAgent._stable_row(r) for r in rows});return {"rows":float(len(rows)),"fields":float(len(fields)),"entropy_proxy":log1p(unique)/max(1.,log1p(len(rows)))}
