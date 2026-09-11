from __future__ import annotations
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from hashlib import sha256
from typing import Any

@dataclass
class WorkflowState:
    task_id: str
    status: str = 'running'
    revision: int = 0
    correction: str = ''
    approval: str = ''
    budget: dict[str, int] | None = None
    updated_at: str = ''

class Home03Runtime:
    def __init__(self):
        self.workflows: dict[str, WorkflowState] = {}
        self.events: list[dict[str, Any]] = []
        self.branches: dict[str, dict[str, Any]] = {}
        self.pollen: list[dict[str, Any]] = []
        self.checkpoints: dict[str, dict[str, Any]] = {}

    def _now(self): return datetime.now(timezone.utc).isoformat()

    def emit(self, event_type: str, task_id: str, **payload):
        event = {'event_id': 'evt-' + sha256(f'{task_id}:{len(self.events)}:{self._now()}'.encode()).hexdigest()[:14], 'type': event_type, 'task_id': task_id, 'created_at': self._now(), **payload}
        self.events.append(event)
        return event

    def start(self, task_id: str, plan: dict[str, Any]):
        self.workflows[task_id] = WorkflowState(task_id=task_id, updated_at=self._now(), budget={})
        return self.emit('WORKFLOW_STARTED', task_id, plan=plan)

    def pause(self, task_id: str, correction: str = ''):
        w = self.workflows[task_id]; w.status='paused'; w.correction=correction; w.revision += 1; w.updated_at=self._now()
        return self.emit('WORKFLOW_PAUSED', task_id, correction=correction, revision=w.revision)

    def resume(self, task_id: str):
        w = self.workflows[task_id]; w.status='running'; w.updated_at=self._now()
        return self.emit('WORKFLOW_RESUMED', task_id, revision=w.revision)

    def approve(self, task_id: str, action: str, diff: dict[str, Any] | None = None):
        w = self.workflows[task_id]; w.approval=action; w.updated_at=self._now()
        return self.emit('WORKFLOW_INTERVENTION', task_id, action=action, diff=diff or {})

    def checkpoint(self, task_id: str, state: dict[str, Any]):
        canonical = repr(sorted(state.items())).encode(); cid='cp-' + sha256(f'{task_id}:{canonical!r}'.encode()).hexdigest()[:14]
        item={'checkpoint_id':cid,'task_id':task_id,'state_hash':sha256(canonical).hexdigest(),'state':state,'created_at':self._now()}; self.checkpoints[cid]=item
        self.emit('CHECKPOINT_CREATED',task_id,checkpoint=item)
        return item

    def fork(self, checkpoint_id: str, branch_name: str):
        cp=self.checkpoints[checkpoint_id]; bid='branch-' + sha256(f'{checkpoint_id}:{branch_name}'.encode()).hexdigest()[:12]
        item={'branch_id':bid,'name':branch_name,'parent_checkpoint':checkpoint_id,'state':cp['state'],'created_at':self._now()}; self.branches[bid]=item
        self.emit('BRANCH_CREATED',cp['task_id'],branch=item)
        return item

    def ingest_pollen(self, event: dict[str, Any]):
        item={'pollen_id':'pol-' + sha256(repr(event).encode()).hexdigest()[:14],'source_event':event.get('event_id'),'task_id':event.get('task_id'),'source':event.get('source'),'target':event.get('target'),'claim':event.get('claim'),'confidence':event.get('confidence'),'created_at':self._now()}; self.pollen.append(item); return item

    def allocate(self, task_id: str, home: str, tokens: int):
        w=self.workflows[task_id]; w.budget = w.budget or {}; w.budget[home]=max(1,int(tokens)); self.emit('COMPUTE_BUDGET_SET',task_id,home=home,tokens=w.budget[home]); return w.budget[home]

    def snapshot(self): return {'workflows':{k:asdict(v) for k,v in self.workflows.items()},'events':self.events[-200:],'branches':self.branches,'pollen':self.pollen[-200:],'checkpoints':self.checkpoints}

home03_runtime = Home03Runtime()
