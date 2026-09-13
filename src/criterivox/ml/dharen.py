from __future__ import annotations
from criterivox.context.agents import DharenAgent
from criterivox.context.ml import S6LearnedModelRegistry
from criterivox.context.models import ContextFrame, ContextInput

class DharenMLAgent(DharenAgent):
    """Dharen with learned tier ranking fused into deterministic context safety."""
    model_version="dharen-context-learned-1"
    def __init__(self,*args,model_registry:S6LearnedModelRegistry|None=None,**kwargs):
        super().__init__(*args,**kwargs); self.model_registry=model_registry or S6LearnedModelRegistry(); self.learned_model=self.model_registry.dharen; self.learned_model.load()
    @property
    def is_ready(self)->bool:return True
    @property
    def learned_model_available(self)->bool:return self.learned_model.available
    def frame(self,context:ContextInput,*,max_items:int=64)->ContextFrame:
        base=super().frame(context,max_items=max_items)
        if not self.learned_model.available:return base
        preds={}
        for item in base.items:
            p=self.learned_model.predict_one(f"key={item.key}; value={item.value}; deterministic_tier={item.tier.name.lower()}")
            if p: preds[item.key]=p
        order={"critical":1,"high":2,"medium":3,"low":4}
        items=tuple(sorted(base.items,key=lambda x:(x.critical,-preds.get(x.key,type("P",(),{"confidence":0.0})()).confidence,-order.get(preds.get(x.key,type("P",(),{"label":"low"})()).label,4)),reverse=True))
        env={**dict(base.environment),"ml":{"agent":"dharen","model_version":self.learned_model.model_version,"available":True,"predictions":{k:{"label":p.label,"confidence":p.confidence} for k,p in preds.items()}}}
        return ContextFrame(base.frame_id,base.request,items,base.hard_constraints,base.soft_guidelines,env,base.violations,base.compression_ratio,base.original_item_count,base.tier_budget)
