from __future__ import annotations
from criterivox.context.agents import AnukaAgent
from criterivox.context.ml import S6LearnedModelRegistry
from criterivox.context.models import AdaptiveContextState, ContextDiff, ContextFrame

class AnukaMLAgent(AnukaAgent):
    """Anuka with learned adaptation classification fused with deterministic gates."""
    model_version="anuka-adaptation-learned-1"
    def __init__(self,*args,model_registry:S6LearnedModelRegistry|None=None,**kwargs):
        super().__init__(*args,**kwargs); self.model_registry=model_registry or S6LearnedModelRegistry(); self.learned_model=self.model_registry.anuka; self.learned_model.load()
    @property
    def is_ready(self)->bool:return True
    @property
    def learned_model_available(self)->bool:return self.learned_model.available
    def should_activate(self,triggers,*,manual_activation:bool=False)->bool:
        deterministic=super().should_activate(triggers,manual_activation=manual_activation)
        if deterministic or not self.learned_model.available:return deterministic
        text=" ".join(k.replace("_"," ") for k,v in triggers.items() if v)
        p=self.learned_model.predict_one(text)
        return bool(p and p.label!="stable" and p.confidence>=.50)
    def adapt(self,previous:ContextFrame|None,current:ContextFrame,*,previous_state:AdaptiveContextState|None=None)->AdaptiveContextState:
        state=super().adapt(previous,current,previous_state=previous_state)
        if not self.learned_model.available:return state
        d=state.diff; signals=[]
        if d.goal_shift:signals.append("requirements changed")
        if d.constraint_shift:signals.append("constraint changed")
        if d.changed:signals.append("evidence changed")
        if not signals and (d.added or d.removed):signals.append("context drift detected")
        if not signals:signals.append("stable context")
        p=self.learned_model.predict_one(f"request={current.request}; previous={previous.request if previous else ''}; signals={' '.join(signals)}; added={','.join(d.added)}; removed={','.join(d.removed)}; changed={','.join(d.changed)}")
        if not p:return state
        active=dict(state.active_context); active["_ml"]={"agent":"anuka","model_version":p.model_version,"label":p.label,"confidence":p.confidence}
        return AdaptiveContextState(state.frame,state.diff,active,state.sandbox_states,state.checkpoint_id,state.state_version)
