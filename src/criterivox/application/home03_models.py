from __future__ import annotations
from typing import Any
from .home03_learning import intent_model, ui_model, TRAINING_REPORT

class AdaptiveIntentModel:
 def __init__(self): self.name='adaptive-intent-v1-trained'
 def predict(self,payload:dict[str,Any]):
  p=intent_model.predict(payload.get('text','')); p.update({'model':self.name,'training_report':TRAINING_REPORT['intent']}); return p

class OutputRendererModel:
 def __init__(self): self.name='adaptive-renderer-v1-trained'
 def predict(self,payload):
  p=ui_model.predict(payload.get('text','')); label=p['label']; requested=str(payload.get('mode','')).lower(); mode=requested if requested in {'executive','reasoning','json','comparison','code'} else {'executive':'executive','reasoning':'reasoning','json':'json','comparison':'comparison','code':'code'}.get(label,'executive')
  return {'mode':mode,'components':{'executive':['summary','tradeoffs'],'reasoning':['reasoning_tree','evidence'],'json':['json'],'comparison':['comparison_table','tradeoffs'],'code':['code_block','validation']}.get(mode,['summary']),'model':self.name,'confidence':p['confidence'],'scores':p['scores'],'training_report':TRAINING_REPORT['ui']}

class UIIntentModel:
 def __init__(self): self.name='ui-intent-v1-trained'
 def predict(self,payload):
  text=str(payload.get('text',payload.get('intent',''))); p=ui_model.predict(text); intent=str(payload.get('intent','general')); mapping={'compare':(['comparison_table','parameter_slider'],True),'decide':(['tradeoff_matrix','approval_card'],True),'analyze':(['reasoning_tree','evidence_card'],True),'explain':(['reasoning_tree','provenance_card'],False),'build':(['code_editor','validation_card'],True)}
  components,interactive=mapping.get(intent,([p['label']],False)); return {'components':components,'interactive':interactive,'model':self.name,'confidence':p['confidence'],'scores':p['scores']}

adaptive_intent_model=AdaptiveIntentModel(); output_renderer_model=OutputRendererModel(); ui_intent_model=UIIntentModel()
