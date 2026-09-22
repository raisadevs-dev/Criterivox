from __future__ import annotations

import asyncio
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from hashlib import sha256
from typing import Any

from .home03_store import home03_store


@dataclass
class WorkflowState:
    task_id: str
    status: str = "running"
    revision: int = 0
    correction: str = ""
    approval: str = ""
    budget: dict[str, int] | None = None
    remaining: dict[str, int] | None = None
    plan: dict[str, Any] | None = None
    updated_at: str = ""


class Home03Runtime:
    """Execution-control state for tasks admitted by the Syvax Gateway."""

    def __init__(self) -> None:
        self.workflows: dict[str, WorkflowState] = {}
        self.events: list[dict[str, Any]] = []
        self.branches: dict[str, dict[str, Any]] = {}
        self.pollen: list[dict[str, Any]] = []
        self.checkpoints: dict[str, dict[str, Any]] = {}
        self._wake: dict[str, asyncio.Event] = {}

    @staticmethod
    def _now() -> str:
        return datetime.now(timezone.utc).isoformat()

    def emit(
        self,
        event_type: str,
        task_id: str,
        **payload: Any,
    ) -> dict[str, Any]:
        event = {
            "event_id": "evt-"
            + sha256(
                f"{task_id}:{len(self.events)}:{self._now()}".encode()
            ).hexdigest()[:14],
            "type": event_type,
            "task_id": task_id,
            "created_at": self._now(),
            **payload,
        }
        self.events.append(event)
        home03_store.event(event_type, task_id, event)
        return event

    def start(self, task_id: str, plan: dict[str, Any]) -> dict[str, Any]:
        if task_id in self.workflows:
            return self.emit("WORKFLOW_REUSED", task_id, plan=plan)

        self.workflows[task_id] = WorkflowState(
            task_id=task_id,
            updated_at=self._now(),
            budget={},
            remaining={},
            plan=plan,
        )
        self._wake[task_id] = asyncio.Event()
        self._wake[task_id].set()
        return self.emit("WORKFLOW_STARTED", task_id, plan=plan)

    def _ensure(self, task_id: str) -> WorkflowState:
        if task_id not in self.workflows:
            self.start(task_id, {})
        self._wake.setdefault(task_id, asyncio.Event())
        return self.workflows[task_id]

    def pause(self, task_id: str, correction: str = ""):
        workflow = self._ensure(task_id)
        workflow.status = "paused"
        workflow.correction = correction.strip()
        workflow.revision += 1
        workflow.updated_at = self._now()
        self._wake[task_id].clear()
        return self.emit(
            "WORKFLOW_PAUSED",
            task_id,
            correction=workflow.correction,
            revision=workflow.revision,
        )

    def resume(self, task_id: str):
        workflow = self._ensure(task_id)
        workflow.status = "running"
        workflow.updated_at = self._now()
        self._wake[task_id].set()
        return self.emit(
            "WORKFLOW_RESUMED",
            task_id,
            revision=workflow.revision,
        )

    async def wait_if_paused(self, task_id: str):
        self._ensure(task_id)
        await self._wake[task_id].wait()

    def approve(
        self,
        task_id: str,
        action: str,
        diff: dict[str, Any] | None = None,
    ):
        workflow = self._ensure(task_id)
        workflow.approval = action.strip()
        workflow.updated_at = self._now()
        return self.emit(
            "WORKFLOW_INTERVENTION",
            task_id,
            action=workflow.approval,
            diff=diff or {},
            revision=workflow.revision,
        )

    def checkpoint(self, task_id: str, state: dict[str, Any]):
        canonical = repr(sorted(state.items())).encode()
        checkpoint_id = (
            "cp-"
            + sha256(
                f"{task_id}:{canonical!r}".encode()
            ).hexdigest()[:14]
        )
        item = {
            "checkpoint_id": checkpoint_id,
            "task_id": task_id,
            "state_hash": sha256(canonical).hexdigest(),
            "state": state,
            "created_at": self._now(),
        }
        self.checkpoints[checkpoint_id] = item
        home03_store.checkpoint(
            "default",
            "main",
            state,
            item["state_hash"],
        )
        self.emit(
            "CHECKPOINT_CREATED",
            task_id,
            checkpoint=item,
        )
        return item

    def restore(self, checkpoint_id: str):
        checkpoint = self.checkpoints.get(checkpoint_id)
        if not checkpoint:
            raise KeyError(f"Unknown checkpoint: {checkpoint_id}")

        task_id = checkpoint["task_id"]
        workflow = self._ensure(task_id)
        state = checkpoint.get("state", {})
        if isinstance(state, dict) and isinstance(
            state.get("workflow"),
            dict,
        ):
            restored = state["workflow"]
            workflow.status = restored.get(
                "status",
                workflow.status,
            )
            workflow.revision = int(
                restored.get(
                    "revision",
                    workflow.revision,
                )
            )
            workflow.correction = restored.get(
                "correction",
                "",
            )
            workflow.approval = restored.get(
                "approval",
                "",
            )
            workflow.budget = restored.get(
                "budget",
                workflow.budget,
            )
            workflow.remaining = restored.get(
                "remaining",
                workflow.remaining,
            )
            workflow.plan = restored.get(
                "plan",
                workflow.plan,
            )

        if workflow.status == "paused":
            self._wake[task_id].clear()
        else:
            self._wake[task_id].set()

        self.emit(
            "REPLAY_RESTORED",
            task_id,
            checkpoint_id=checkpoint_id,
            state_hash=checkpoint["state_hash"],
        )
        return {
            "restored": True,
            "checkpoint": checkpoint,
            "workflow": asdict(workflow),
            "branchable": True,
        }

    def fork(self, checkpoint_id: str, branch_name: str):
        checkpoint = self.checkpoints.get(checkpoint_id)
        if not checkpoint:
            raise KeyError(f"Unknown checkpoint: {checkpoint_id}")

        branch_id = (
            "branch-"
            + sha256(
                f"{checkpoint_id}:{branch_name}".encode()
            ).hexdigest()[:12]
        )
        item = {
            "branch_id": branch_id,
            "name": branch_name,
            "parent_checkpoint": checkpoint_id,
            "state": checkpoint["state"],
            "created_at": self._now(),
        }
        self.branches[branch_id] = item
        self.emit(
            "BRANCH_CREATED",
            checkpoint["task_id"],
            branch=item,
        )
        return item

    def ingest_pollen(self, event: dict[str, Any]):
        item = {
            "pollen_id": "pol-"
            + sha256(repr(event).encode()).hexdigest()[:14],
            "source_event": event.get("event_id"),
            "task_id": event.get("task_id"),
            "source": event.get("source"),
            "target": event.get("target"),
            "claim": event.get("claim"),
            "confidence": event.get("confidence"),
            "created_at": self._now(),
        }
        self.pollen.append(item)
        home03_store.pollen(
            str(event.get("task_id", "")),
            str(event.get("source", "")),
            str(event.get("target", "")),
            event,
            item["confidence"],
        )
        return item

    def allocate(self, task_id: str, home: str, tokens: int):
        workflow = self._ensure(task_id)
        workflow.budget = workflow.budget or {}
        workflow.remaining = workflow.remaining or {}
        workflow.budget[home] = max(1, int(tokens))
        workflow.remaining[home] = workflow.budget[home]
        return self.emit(
            "COMPUTE_BUDGET_SET",
            task_id,
            home=home,
            tokens=workflow.budget[home],
        )

    def consume(self, task_id: str, home: str, cost: int):
        workflow = self._ensure(task_id)
        workflow.remaining = workflow.remaining or {}
        remaining = (
            workflow.remaining.get(
                home,
                workflow.budget.get(home, 100)
                if workflow.budget
                else 100,
            )
            - max(0, int(cost))
        )
        workflow.remaining[home] = remaining
        self.emit(
            "COMPUTE_BUDGET_CONSUMED",
            task_id,
            home=home,
            cost=cost,
            remaining=remaining,
        )
        if remaining < 0:
            workflow.status = "paused"
            self._wake[task_id].clear()
            self.emit(
                "COMPUTE_BUDGET_EXHAUSTED",
                task_id,
                home=home,
                remaining=remaining,
            )
            raise RuntimeError(
                f"Compute budget exhausted for {home}."
            )
        return remaining

    def snapshot(self):
        return {
            "workflows": {
                key: asdict(value)
                for key, value in self.workflows.items()
            },
            "events": self.events[-200:],
            "branches": self.branches,
            "pollen": self.pollen[-200:],
            "checkpoints": self.checkpoints,
        }


home03_runtime = Home03Runtime()
