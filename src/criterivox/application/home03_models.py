from __future__ import annotations
from typing import Any
from .home03_learning import intent_model, ui_model, TRAINING_REPORT

class AdaptiveIntentModel:
 def __init__(self): self.name='adaptive-intent-v1-trained'
 def predict(self,payload:dict[str,Any]):
  p=intent_model.predict(payload.get('text','')); p.update({'model':self.name,'training_report':TRAINING_REPORT['intent']}); return p

class OutputRendererModel:
 def __init__(self): self.name='adaptive-renderer-v1'
 def predict(self,payload):
  p=ui_model.predict(payload.get('text','')); label=p['label']; mode={'executive':'executive','reasoning':'reasoning','json':'json','comparison':'comparison','code':'code'}.get(label,'executive')
  return {'mode':mode,'components':{'executive':['summary','tradeoffs'],'reasoning':['reasoning_tree','evidence'],'json':['json'],'comparison':['comparison_table','tradeoffs'],'code':['code_block','validation']}.get(mode,['summary']),'model':self.name,'confidence':p['confidence'],'scores':p['scores'],'training_report':TRAINING_REPORT['ui']}

class UIIntentModel:
 def __init__(self): self.name='ui-intent-v1-trained'
 def predict(self,payload):
  intent=payload.get('intent','general'); mapping={'compare':(['comparison_table','parameter_slider'],True),'decide':(['tradeoff_matrix','approval_card'],True),'analyze':(['reasoning_tree','evidence_card'],True),'explain':(['reasoning_tree','provenance_card'],False),'build':(['code_editor','validation_card'],True)}
  components,interactive=mapping.get(intent,(['summary'],False)); return {'components':components,'interactive':interactive,'model':self.name}

adaptive_intent_model=AdaptiveIntentModel(); output_renderer_model=OutputRendererModel(); ui_intent_model=UIIntentModel()
