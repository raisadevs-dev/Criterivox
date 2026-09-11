from __future__ import annotations
from typing import Any
from .home03_models import adaptive_intent_model, output_renderer_model, ui_intent_model
from .home03_runtime import home03_runtime
from .bloom import bloom_controller

class Home03Services:
 def dispatch(self,message:str,task_id:str|None=None):
  prediction=adaptive_intent_model.predict({'text':message});tid=task_id or 'adaptive-'+str(abs(hash(message)));home03_runtime.start(tid,{'intent':prediction});return {'task_id':tid,'intent':prediction,'event':home03_runtime.emit('INTENT_CLASSIFIED',tid,prediction=prediction)}
 def render(self,text:str,intent:str='general',mode:str=''):
  result=output_renderer_model.predict({'text':text,'intent':intent,'mode':mode});result['ui']=ui_intent_model.predict({'intent':intent,'text':text});return result
 def suspend(self,task_id,correction=''):return home03_runtime.pause(task_id,correction)
 def resume(self,task_id):return home03_runtime.resume(task_id)
 def intervene(self,task_id,action,diff=None):
  result=home03_runtime.approve(task_id,action,diff);return {**result,'decision_diff':diff or {},'resume_required':action.lower() in {'approve','reject','edit'}}
 def budget(self,task_id,home,tokens):return home03_runtime.allocate(task_id,home,tokens)
 def consume(self,task_id,home,cost):return home03_runtime.consume(task_id,home,cost)
 def ingest_runtime_event(self,event):
  out=home03_runtime.emit('RUNTIME_HANDOFF',event.get('task_id','unknown'),source=event.get('source'),target=event.get('target'),payload=event.get('payload',{}),confidence=event.get('confidence'));home03_runtime.ingest_pollen(out);score=float(event.get('confidence') if event.get('confidence') is not None else 1.0);evaluation=bloom_controller.evaluate(str(event.get('task_id','unknown')),str(event.get('source','')),str(event.get('target','')),score,reason=str(event.get('event','runtime')));return {'event':out,'pollen':home03_runtime.pollen[-1],'evaluation':evaluation}
 def restore(self,checkpoint_id):return home03_runtime.restore(checkpoint_id)
 def fork(self,checkpoint_id,name):return home03_runtime.fork(checkpoint_id,name)
 def snapshot(self):return home03_runtime.snapshot()

home03_services=Home03Services()
