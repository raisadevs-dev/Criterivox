from __future__ import annotations
from typing import Any
from .home03_models import adaptive_intent_model, output_renderer_model, ui_intent_model
from .home03_runtime import home03_runtime

class Home03Services:
    def dispatch(self, message: str, task_id: str | None = None):
        prediction=adaptive_intent_model.predict({'text':message})
        tid=task_id or 'adaptive-' + str(abs(hash(message)))
        event=home03_runtime.emit('INTENT_CLASSIFIED',tid,prediction=prediction)
        return {'task_id':tid,'intent':prediction,'event':event}
    def render(self, text: str, intent: str = 'general'):
        result=output_renderer_model.predict({'text':text,'intent':intent}); result['ui']=ui_intent_model.predict({'intent':intent}); return result
    def suspend(self, task_id: str, correction: str = ''): return home03_runtime.pause(task_id,correction)
    def resume(self, task_id: str): return home03_runtime.resume(task_id)
    def intervene(self, task_id: str, action: str, diff: dict[str,Any] | None = None): return home03_runtime.approve(task_id,action,diff)
    def budget(self, task_id: str, home: str, tokens: int): return home03_runtime.allocate(task_id,home,tokens)
    def ingest_runtime_event(self, event: dict[str,Any]):
        out=home03_runtime.emit('RUNTIME_HANDOFF',event.get('task_id','unknown'),source=event.get('source'),target=event.get('target'),payload=event.get('payload',{}),confidence=event.get('confidence'))
        home03_runtime.ingest_pollen(out)
        return out
    def snapshot(self): return home03_runtime.snapshot()

home03_services=Home03Services()
