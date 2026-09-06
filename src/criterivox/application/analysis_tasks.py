from __future__ import annotations

import asyncio
from dataclasses import dataclass, field
from typing import Any, Callable

from criterivox.domain.analysis import (
    AnalysisResult,
    AnalysisTask,
    AnalysisTaskSource,
    AnalysisTaskState,
    Evidence,
    Finding,
    Observation,
)


@dataclass
class AnalysisTaskStore:
    """Process-local task store for the S4 runtime. Persistence can replace it later."""

    tasks: dict[str, AnalysisTask] = field(default_factory=dict)

    def create(self, *, task: str, data: dict[str, Any], context: dict[str, Any], source: AnalysisTaskSource, references: tuple[str, ...] = ()) -> AnalysisTask:
        item = AnalysisTask.create(task=task, data=data, context=context, source=source, references=references)
        self.tasks[item.task_id] = item
        return item

    def get(self, task_id: str) -> AnalysisTask:
        try:
            return self.tasks[task_id]
        except KeyError as exc:
            raise KeyError(f"Unknown analysis task: {task_id}") from exc


class UnknownAnalysisTaskError(ValueError):
    pass


@dataclass
class AnalysisTaskService:
    store: AnalysisTaskStore = field(default_factory=AnalysisTaskStore)
    publish: Callable[[AnalysisTask], Any] | None = None
    _locks: dict[str, asyncio.Lock] = field(default_factory=dict)

    def create_task(self, *, task: str, data: dict[str, Any], context: dict[str, Any], source: AnalysisTaskSource, references: tuple[str, ...] = ()) -> AnalysisTask:
        item = self.store.create(task=task, data=data, context=context, source=source, references=references)
        item.add_activity(f"Task created from {source.value}.")
        return item

    def get_task(self, task_id: str) -> AnalysisTask:
        try:
            return self.store.get(task_id)
        except KeyError as exc:
            raise UnknownAnalysisTaskError(str(exc)) from exc

    async def execute(self, task_id: str) -> AnalysisTask:
        task = self.get_task(task_id)
        lock = self._locks.setdefault(task_id, asyncio.Lock())
        async with lock:
            if task.is_terminal:
                return task
            await self._move(task, AnalysisTaskState.RECEIVED, "Task received by the analysis application.")
            await asyncio.sleep(0.15)
            await self._move(task, AnalysisTaskState.VALIDATING, "Validating task data, context, and references.")
            await asyncio.sleep(0.20)
            if not task.task.strip():
                task.fail("The analysis task is empty.")
                await self._publish(task)
                return task
            await self._move(task, AnalysisTaskState.PROCESSING, "Preparing the supplied data for analysis.")
            await asyncio.sleep(0.25)
            await self._move(task, AnalysisTaskState.ANALYZING, "Analyzing observations and establishing contextual findings.")
            await asyncio.sleep(0.40)
            result = self._deterministic_result(task)
            task.result = result
            task.add_activity(f"Produced {len(result.observations)} observations and {len(result.findings)} findings.")
            await self._move(task, AnalysisTaskState.RESULT_READY, "Analysis result is ready.")
            await asyncio.sleep(0.15)
            task.complete(result)
            task.add_activity("Analysis completed successfully.")
            await self._publish(task)
            return task

    async def _move(self, task: AnalysisTask, state: AnalysisTaskState, activity: str) -> None:
        task.transition(state)
        task.add_activity(activity)
        await self._publish(task)

    async def _publish(self, task: AnalysisTask) -> None:
        if self.publish is not None:
            value = self.publish(task)
            if asyncio.iscoroutine(value):
                await value

    @staticmethod
    def _deterministic_result(task: AnalysisTask) -> AnalysisResult:
        data_fields = len(task.data)
        context_fields = len(task.context)
        observations = (
            Observation("obs-1", f"The task contains {data_fields} top-level data fields.", "measured"),
            Observation("obs-2", f"The task provides {context_fields} contextual fields.", "measured"),
        )
        findings = (
            Finding("finding-1", "The supplied task can be processed with the currently available deterministic analysis provider."),
            Finding("finding-2", "Interpretation remains bounded by the supplied data and context; no unsupported intelligence claim is made."),
        )
        evidence = (
            Evidence("evidence-1", "Input structure", "analysis_task", f"{data_fields} data fields; {context_fields} context fields"),
        )
        return AnalysisResult(
            summary=f"Deterministic analysis completed using {data_fields} data fields and {context_fields} context fields.",
            observations=observations,
            findings=findings,
            evidence=evidence,
        )


analysis_tasks = AnalysisTaskService()

__all__ = ["AnalysisTaskService", "AnalysisTaskStore", "UnknownAnalysisTaskError", "analysis_tasks"]
