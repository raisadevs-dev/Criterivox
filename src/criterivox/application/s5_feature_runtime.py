from __future__ import annotations
from dataclasses import asdict,dataclass
from datetime import datetime,timezone
import hashlib,json
from typing import Any
from .s5_advanced_runtime import EvaluationGate,FoundationSynchronizer,KaelenPipeline,ProvenanceLedger,SchemaDriftHealer,SyntheticDataEngine,SemanticTagger
from .s5_ml_stack import LocalMLStack
from .s5_sklearn_backend import SklearnAnomalyBackend
@dataclass(frozen=True)
class ReadinessSnapshot:
 completeness:float;schema_alignment:float;anomaly_score:float;readiness:float;decision:str
class S5FeatureRuntime:
 provisional_alert_threshold=.85
 def __init__(self)->None:
  self.ledger=ProvenanceLedger();self.sync=FoundationSynchronizer();self.pipeline=KaelenPipeline();self.healer=SchemaDriftHealer();self.synthetic=SyntheticDataEngine();self.tagger=SemanticTagger();self.evaluator=EvaluationGate();self.ml=LocalMLStack();self.sklearn=SklearnAnomalyBackend()
 def _rows(self,f:Any)->list[dict[str,Any]]: return [dict(r) for r in (getattr(f,'canonical_data',()) or getattr(f,'normalized_data',()) or getattr(f,'raw_data',())) if isinstance(r,dict)]
 def readiness(self,f:Any)->ReadinessSnapshot:
  rows=self._rows(f);p=getattr(f,'profile',None);total=max(1,(p.record_count*max(1,p.field_count)) if p else 1);missing=sum(p.missingness.values()) if p else 0;comp=max(0,min(1,1-missing/total));align=1 if rows else 0;anom=max(0,min(1,len(getattr(f,'anomalies',()))/max(1,len(getattr(f,'candidates',())))));score=max(0,min(1,comp*.45+align*.35+(1-anom)*.2));return ReadinessSnapshot(round(comp,4),round(align,4),round(anom,4),round(score,4),'READY' if score>=.85 else 'REVIEW')
 def provenance(self,f:Any,revision:int|None=None)->dict[str,Any]:
  e=self.ledger.append(f.foundation_id,'FOUNDATION_SNAPSHOT',f.to_dict());r={'payload_hash':hashlib.sha256(json.dumps(f.raw_data,sort_keys=True,default=str).encode()).hexdigest(),'captured_at':datetime.now(timezone.utc).isoformat(),'source_count':len(f.sources),'transformation_count':len(f.transformations),'revision':e.revision,'timeline_supported':True};
  if revision is not None:r['rewind']=asdict(self.ledger.rewind(f.foundation_id,revision))
  return r
 def rewind(self,f:Any,revision:int)->dict[str,Any]:return asdict(self.ledger.rewind(f.foundation_id,revision))
 def synthetic_preview(self,f:Any,seed:int=17)->dict[str,Any]:return self.synthetic.preview(self._rows(f),seed)
 def semantic(self,f:Any)->dict[str,Any]:return self.tagger.tag(self._rows(f),getattr(f,'supplied_context',{}) or {})
 def schema_patch(self,f:Any)->dict[str,Any]:
  rows=self._rows(f);old=sorted({k for r in rows for k in r});ctx=getattr(f,'supplied_context',{}) or {};new=[str(k) for k in ctx.get('expected_schema',old)];aliases=ctx.get('schema_aliases',{});return self.healer.patch(rows,old,new,{str(k):str(v) for k,v in aliases.items()} if isinstance(aliases,dict) else {})
 def pipeline_result(self,f:Any)->dict[str,Any]:return self.pipeline.execute(self._rows(f))
 def sync_envelope(self,f:Any,revision:int=1)->dict[str,Any]:return asdict(self.sync.prepare(f.foundation_id,revision,f.to_dict()))
 def accept_sync(self,e:dict[str,Any])->dict[str,Any]:
  from .s5_advanced_runtime import SyncEnvelope
  return self.sync.accept(SyncEnvelope(str(e['foundation_id']),int(e['revision']),str(e['payload_hash']),str(e.get('operation','upsert')),dict(e['payload'])))
 def ml_train_and_score(self,f:Any)->dict[str,Any]:
  rows=self._rows(f);baseline=self.ml.train_anomaly_baseline(rows);out={'baseline':baseline,'agent':'sandre','execution':'local'}
  if len(rows)>=4:
   try:
    model=self.sklearn.train(rows);out['sklearn']=self.sklearn.score(model,rows[:100])
   except ValueError as exc:out['sklearn']={'status':'not_ready','reason':str(exc)}
  return out
 def agent_runtime(self,f:Any,agent:str)->dict[str,Any]:return {'agent':agent.lower(),'runtime':'local-executable','foundation_id':f.foundation_id,'result':self.ml_train_and_score(f) if agent.lower()=='sandre' else self.pipeline_result(f)}
 def vector_readiness(self,f:Any)->dict[str,Any]:return {'stage':'embedding-ready-representation','text':bool(self._rows(f)),'image':False,'audio':False,'lakehouse':'deferred-by-S5-scope'}
 def edd_gate(self,f:Any)->dict[str,Any]:
  r=self.readiness(f);ml=self.ml_train_and_score(f);ctx=getattr(f,'supplied_context',{}) or {};datasets=ctx.get('evaluation_datasets',[]);metrics={'readiness':r.readiness};return {'status':'PASS' if r.readiness>=.85 and bool(f.sources) and f.confirmation_status.value in {'user-confirmed','user-corrected'} else 'REVIEW','checks':{'readiness':r.readiness>=.85,'provenance':bool(f.sources),'confirmation':f.confirmation_status.value in {'user-confirmed','user-corrected'},'ml_execution':bool(ml.get('baseline',{}).get('trained'))},'metrics':metrics,'evaluation_datasets':datasets,'threshold':.85,'threshold_status':'provisional','training_policy':'local-only-with-explicit-consent'}
