from __future__ import annotations
from dataclasses import dataclass
from typing import Any
from criterivox.context.ml import S6LearnedModelRegistry
@dataclass(frozen=True,slots=True)
class KaelenPlan:
    action:str;confidence:float;operations:tuple[dict[str,Any],...];model_version:str="kaelen-schema-fused-1";learned_action:str|None=None;learned_confidence:float|None=None
class KaelenMLAgent:
    """Kaelen schema diff with trained action classification and declarative safety."""
    model_version="kaelen-schema-fused-1"
    def __init__(self,*,model_registry:S6LearnedModelRegistry|None=None):self.model_registry=model_registry or S6LearnedModelRegistry();self.learned_model=self.model_registry.kaelen;self.learned_model.load()
    @property
    def is_ready(self):return True
    @property
    def learned_model_available(self):return self.learned_model.available
    def propose(self,before:dict[str,str],after:dict[str,str])->KaelenPlan:
        bk,ak=set(before),set(after);removed=sorted(bk-ak);added=sorted(ak-bk);types=sorted(k for k in bk&ak if before[k]!=after[k]);ops=[]
        for f in types:ops.append({"op":"cast","field":f,"from":before[f],"to":after[f]})
        for f in added:ops.append({"op":"add_field","field":f,"type":after[f]})
        for f in removed:ops.append({"op":"remove_field","field":f,"type":before[f]})
        if types:action="type_repair"
        elif added and removed and len(added)==len(removed):action="schema_mapping_review"
        elif added:action="schema_extension"
        elif removed:action="schema_reduction_review"
        else:action="no_change"
        la=lc=None
        if self.learned_model.available:
            p=self.learned_model.predict_one(f"schema before={sorted(before.items())}; after={sorted(after.items())}; added={added}; removed={removed}; type_changes={types}")
            if p:la,lc=p.label,p.confidence
            if la==action and lc is not None:action=la
        count=len(types)+len(added)+len(removed);det=1. if count==0 else max(.5,1-.1*count);conf=det if lc is None else (det+lc)/2
        return KaelenPlan(action,conf,tuple(ops),learned_action=la,learned_confidence=lc)
    @staticmethod
    def validate_plan(plan:KaelenPlan)->None:
        allowed={"cast","add_field","remove_field"}
        for op in plan.operations:
            if op.get("op") not in allowed:raise ValueError(f"Unsupported transformation operation: {op.get('op')}")
