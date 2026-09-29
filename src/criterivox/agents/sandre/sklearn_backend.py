from __future__ import annotations
from dataclasses import asdict, dataclass
from time import perf_counter
from typing import Any
import numpy as np
from sklearn.ensemble import IsolationForest

@dataclass(frozen=True)
class LocalAnomalyModel:
    feature_names: tuple[str,...]
    contamination: float
    rows: int
    model: IsolationForest

class SklearnAnomalyBackend:
    """Actual local ML stage for Sandre anomaly review.

    No network calls are made. The model is trained on the supplied working set.
    """
    def train(self, rows:list[dict[str,Any]], contamination:float=0.05)->LocalAnomalyModel:
        numeric=[{k:float(v) for k,v in r.items() if isinstance(v,(int,float)) and not isinstance(v,bool)} for r in rows]
        names=tuple(sorted({k for r in numeric for k in r}))
        matrix=np.array([[r.get(k,0.0) for k in names] for r in numeric],dtype=float)
        if len(matrix)<4 or not names: raise ValueError('At least four rows with numeric features are required for IsolationForest.')
        model=IsolationForest(n_estimators=128,contamination=contamination,random_state=42,n_jobs=1)
        model.fit(matrix)
        return LocalAnomalyModel(names,contamination,len(matrix),model)
    def score(self, trained:LocalAnomalyModel, rows:list[dict[str,Any]])->dict[str,Any]:
        start=perf_counter(); matrix=np.array([[float(r.get(k,0.0)) if isinstance(r.get(k), (int,float)) else 0.0 for k in trained.feature_names] for r in rows],dtype=float)
        labels=trained.model.predict(matrix).tolist(); scores=(-trained.model.score_samples(matrix)).tolist()
        return {'backend':'scikit-learn','algorithm':'IsolationForest','rows':len(rows),'feature_names':list(trained.feature_names),'labels':labels,'anomaly_scores':scores,'inference_seconds':perf_counter()-start,'local_only':True}
