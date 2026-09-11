"""Executable S5 Home 01 services backed by the local progressive ML stack."""
from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import datetime, timezone
import hashlib
import json
from typing import Any

from .s5_advanced_runtime import EvaluationGate, FoundationSynchronizer, KaelenPipeline, ProvenanceLedger, SchemaDriftHealer, SemanticTagger, SyntheticDataEngine
from .s5_ml_stack import LocalMLStack

@dataclass(frozen=True)
class ReadinessSnapshot:
    completeness: float
    schema_alignment: float
    anomaly_score: float
    readiness: float
    decision: str

class S5FeatureRuntime:
    provisional_alert_threshold = 0.85
    def __init__(self) -> None:
        self.ledger=ProvenanceLedger(); self.sync=FoundationSynchronizer(); self.pipeline=KaelenPipeline(); self.healer=SchemaDriftHealer(); self.synthetic=SyntheticDataEngine(); self.tagger=SemanticTagger(); self.evaluator=EvaluationGate(); self.ml=LocalMLStack()

    def _rows(self, foundation: Any) -> list[dict[str,Any]]:
        rows=getattr(foundation,'canonical_data',()) or getattr(foundation,'normalized_data',()) or getattr(foundation,'raw_data',())
        return [dict(r) for r in rows if isinstance(r,dict)]

    def readiness(self, foundation: Any) -> ReadinessSnapshot:
        rows=self._rows(foundation); profile=getattr(foundation,'profile',None)
        if profile is not None and rows:
            total=max(1,profile.record_count*max(1,profile.field_count)); missing=sum(profile.missingness.values()); completeness=max(0.0,min(1.0,1-missing/total))
            duplicate_rate=min(1.0,profile.duplicate_candidates/max(1,profile.record_count)); schema_alignment=1.0 if profile.field_count else 0.0
        else: completeness=1.0 if rows else 0.0; duplicate_rate=0.0; schema_alignment=1.0 if rows else 0.0
        anomaly_score=max(0.0,min(1.0,len(getattr(foundation,'anomalies',()))/max(1,len(getattr(foundation,'candidates',())))))
        readiness=max(0.0,min(1.0,completeness*.45+schema_alignment*.35+(1-anomaly_score)*.20-duplicate_rate*.10))
        return ReadinessSnapshot(round(completeness,4),round(schema_alignment,4),round(anomaly_score,4),round(readiness,4),'READY' if readiness>=self.provisional_alert_threshold else 'REVIEW')

    def provenance(self, foundation: Any, revision: int | None = None) -> dict[str,Any]:
        snapshot=foundation.to_dict(); entry=self.ledger.append(foundation.foundation_id,'FOUNDATION_SNAPSHOT',snapshot)
        result={'payload_hash':hashlib.sha256(json.dumps(foundation.raw_data,sort_keys=True,default=str).encode()).hexdigest(),'captured_at':datetime.now(timezone.utc).isoformat(),'source_count':len(foundation.sources),'transformation_count':len(foundation.transformations),'revision':entry.revision,'timeline_supported':True}
        if revision is not None: result['rewind']=asdict(self.ledger.rewind(foundation.foundation_id,revision))
        return result

    def rewind(self, foundation: Any, revision: int) -> dict[str,Any]: return asdict(self.ledger.rewind(foundation.foundation_id,revision))
    def synthetic_preview(self, foundation: Any, seed: int=17) -> dict[str,Any]: return self.synthetic.preview(self._rows(foundation),seed)
    def semantic(self, foundation: Any) -> dict[str,Any]: return self.tagger.tag(self._rows(foundation),getattr(foundation,'supplied_context',{}) or {})
    def schema_patch(self, foundation: Any) -> dict[str,Any]:
        rows=self._rows(foundation); old=sorted({k for r in rows for k in r}); supplied=getattr(foundation,'supplied_context',{}) or {}; new=supplied.get('expected_schema',old); aliases=supplied.get('schema_aliases',{})
        return self.healer.patch(rows,old,[str(k) for k in new],{str(k):str(v) for k,v in aliases.items()} if isinstance(aliases,dict) else {})
    def pipeline_result(self, foundation: Any) -> dict[str,Any]: return self.pipeline.execute(self._rows(foundation))
    def sync_envelope(self, foundation: Any, revision: int=1) -> dict[str,Any]: return asdict(self.sync.prepare(foundation.foundation_id,revision,foundation.to_dict()))
    def accept_sync(self, envelope: dict[str,Any]) -> dict[str,Any]:
        from .s5_advanced_runtime import SyncEnvelope
        return self.sync.accept(SyncEnvelope(str(envelope['foundation_id']),int(envelope['revision']),str(envelope['payload_hash']),str(envelope.get('operation','upsert')),dict(envelope['payload'])))
    def ml_train_and_score(self, foundation: Any) -> dict[str,Any]:
        rows=self._rows(foundation); model=self.ml.train_anomaly_baseline(rows); scored=[asdict(self.ml.score(model,row)) for row in rows[:25]]; return {'model':model,'scores':scored,'agent':'sandre','execution':'local'}
    def agent_runtime(self, foundation: Any, agent: str) -> dict[str,Any]:
        result=self.pipeline_result(foundation) if agent.lower()=='kaelen' else self.ml_train_and_score(foundation)
        return {'agent':agent.lower(),'runtime':'local-executable','foundation_id':foundation.foundation_id,'result':result}
    def vector_readiness(self, foundation: Any) -> dict[str,Any]: return {'stage':'embedding-ready-representation','text':bool(self._rows(foundation)),'image':False,'audio':False,'matrix_preview':[[0.0,0.0,0.0] for _ in range(min(3,len(getattr(foundation,'candidates',()))))],'lakehouse':'deferred-by-S5-scope'}
    def edd_gate(self, foundation: Any) -> dict[str,Any]:
        readiness=self.readiness(foundation); ml=self.ml_train_and_score(foundation); metrics={'readiness':readiness.readiness};
        scores=[float(x['score']) for x in ml['scores'] if isinstance(x.get('score'),(int,float))]
        if scores: metrics['model_stability']=max(0.0,1.0-min(1.0,(max(scores)-min(scores))))
        datasets=(getattr(foundation,'supplied_context',{}) or {}).get('evaluation_datasets',[]); result=self.evaluator.evaluate(metrics,datasets,self.provisional_alert_threshold)
        result['checks']={'readiness':readiness.readiness>=.85,'confirmation':getattr(foundation,'confirmation_status',None).value in {'user-confirmed','user-corrected'},'provenance':bool(foundation.sources),'ml_execution':bool(ml['model'].get('trained'))}; result['status']='PASS' if all(result['checks'].values()) and result['passed'] else 'REVIEW'; result['threshold_status']='provisional'; return result
