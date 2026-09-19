from __future__ import annotations

import asyncio
from dataclasses import dataclass, field
from typing import Any, Callable

from criterivox.domain.analysis import (
    AnalysisReference,
    AnalysisResult,
    AnalysisTask,
    AnalysisTaskSource,
    AnalysisTaskState,
    Evidence,
    Finding,
    Observation,
)
from criterivox.domain.data_foundation import ConfirmationStatus, DataFoundation

from .home03_runtime import home03_runtime
from .state_runtime import state_runtime


@dataclass
class AnalysisTaskStore:
    tasks: dict[str, AnalysisTask] = field(default_factory=dict)

    def create(self, **kwargs):
        item = AnalysisTask.create(**kwargs)
        self.tasks[item.task_id] = item
        return item

    def get(self, task_id):
        try:
            return self.tasks[task_id]
        except KeyError as exc:
            raise KeyError(f"Unknown analysis task: {task_id}") from exc

    def all(self):
        return tuple(
            sorted(
                self.tasks.values(),
                key=lambda x: x.updated_at,
                reverse=True,
            )
        )

    def search(self, query="", status=None, character=None):
        q = query.strip().lower()
        wanted = (status or "").upper()

        return tuple(
            x
            for x in self.all()
            if (
                not wanted
                or x.state.value == wanted
            )
            and (
                not character
                or character.lower() == "dharen"
            )
            and (
                not q
                or q
                in f"{x.task_id} {x.task} {x.source.value} "
                f"{x.foundation_id or ''}".lower()
            )
        )


class UnknownAnalysisTaskError(ValueError):
    pass


@dataclass
class AnalysisTaskService:
    store: AnalysisTaskStore = field(default_factory=AnalysisTaskStore)
    publish: Callable[[AnalysisTask], Any] | None = None
    _locks: dict[str, asyncio.Lock] = field(default_factory=dict)

    def create_task(
        self,
        *,
        task,
        data,
        context,
        source,
        references=(),
        reference_details=(),
        data_foundation=None,
    ):
        item = self.store.create(
            task=task,
            data=data,
            context=context,
            source=source,
            references=references,
            reference_details=reference_details,
            data_foundation=data_foundation,
        )

        item.add_activity(f"Task created from {source.value}.")
        state_runtime.ensure_journey(item.task_id, item.task)

        if data_foundation is not None:
            item.add_activity(
                f"Attached curated S5 foundation "
                f"{data_foundation.foundation_id}."
            )

        if reference_details:
            item.add_activity(
                f"Attached {len(reference_details)} reference(s) to the task."
            )

        return item

    def attach_foundation(self, task_id, foundation):
        task = self.get_task(task_id)

        if foundation.confirmation_status not in {
            ConfirmationStatus.USER_CONFIRMED,
            ConfirmationStatus.USER_CORRECTED,
        }:
            raise ValueError(
                "A user-confirmed or user-corrected foundation "
                "is required before attaching it to an analysis task."
            )

        task.data_foundation = foundation
        task.data = {
            **task.data,
            "foundation_id": foundation.foundation_id,
            "canonical_data": [
                dict(row) for row in foundation.canonical_data
            ],
            "quality_metadata": (
                foundation.quality.__dict__
                if hasattr(foundation.quality, "__dict__")
                else {}
            ),
        }

        task.context = {
            **task.context,
            "supplied_context": dict(foundation.supplied_context),
            "derived_information": dict(foundation.derived_information),
        }

        task.references = tuple(
            dict.fromkeys(
                (
                    *task.references,
                    *[s.source_id for s in foundation.sources],
                )
            )
        )

        task.add_activity(
            f"S5 foundation {foundation.foundation_id} attached; "
            "canonical data and lineage remain available."
        )

        return task

    def get_task(self, task_id):
        try:
            return self.store.get(task_id)
        except KeyError as exc:
            raise UnknownAnalysisTaskError(str(exc)) from exc

    def find_tasks(self, query="", status=None, character=None):
        return self.store.search(
            query,
            status=status,
            character=character,
        )

    async def execute(self, task_id):
        task = self.get_task(task_id)
        lock = self._locks.setdefault(task_id, asyncio.Lock())

        async with lock:
            home03_runtime.start(
                task_id,
                {
                    "task": task.task,
                    "source": task.source.value,
                },
            )

            await home03_runtime.wait_if_paused(task_id)
            home03_runtime.consume(task_id, "Home 02", 5)

            if task.is_terminal:
                return task

            await self._move(
                task,
                AnalysisTaskState.RECEIVED,
                "Task received by the analysis application.",
            )
            await asyncio.sleep(0.15)

            await home03_runtime.wait_if_paused(task_id)
            home03_runtime.consume(task_id, "Home 02", 5)

            await self._move(
                task,
                AnalysisTaskState.VALIDATING,
                "Validating task data, context, references, "
                "and attached foundation.",
            )
            await asyncio.sleep(0.20)

            if (
                task.data_foundation is not None
                and task.data_foundation.confirmation_status
                not in {
                    ConfirmationStatus.USER_CONFIRMED,
                    ConfirmationStatus.USER_CORRECTED,
                }
            ):
                task.transition(AnalysisTaskState.WAITING)
                task.add_activity(
                    "Waiting for user confirmation of the S5 foundation."
                )
                await self._publish(task)
                return task

            if not task.task.strip():
                task.fail("The analysis task is empty.")
                await self._publish(task)
                return task

            await home03_runtime.wait_if_paused(task_id)
            home03_runtime.consume(task_id, "Home 02", 10)

            await self._move(
                task,
                AnalysisTaskState.PROCESSING,
                "Preparing the supplied data for analysis.",
            )
            await asyncio.sleep(0.25)

            await home03_runtime.wait_if_paused(task_id)
            home03_runtime.consume(task_id, "Home 02", 10)

            await self._move(
                task,
                AnalysisTaskState.ANALYZING,
                "Analyzing the supplied information and "
                "attached S5 foundation.",
            )
            await asyncio.sleep(0.40)

            result = self._deterministic_result(task)
            task.result = result

            task.add_activity(
                f"Produced {len(result.observations)} observations "
                f"and {len(result.findings)} findings."
            )

            await self._move(
                task,
                AnalysisTaskState.RESULT_READY,
                "Analysis result is ready.",
            )
            await asyncio.sleep(0.15)

            task.complete(result)
            task.add_activity("Analysis completed successfully.")

            await self._publish(task)
            return task

    async def _move(self, task, state, activity):
        previous = task.state.value

        task.transition(state)
        task.add_activity(activity)

        state_runtime.record_event(
            task.task_id,
            "STATE_CHANGED",
            actor="dharen",
            previous_state=previous,
            new_state=state.value,
            provenance={"activity": activity},
        )

        ordered = (
            "CREATED",
            "RECEIVED",
            "VALIDATING",
            "PROCESSING",
            "ANALYZING",
            "RESULT_READY",
            "COMPLETED",
        )

        idx = (
            ordered.index(state.value)
            if state.value in ordered
            else -1
        )

        completed_steps = (
            ordered[: idx + 1]
            if idx >= 0
            else (state.value,)
        )

        remaining_steps = (
            ordered[idx + 1:]
            if idx >= 0
            else ()
        )

        state_runtime.checkpoint(
            task.task_id,
            current_step=state.value,
            active_step=state.value,
            completed_steps=completed_steps,
            remaining_steps=remaining_steps,
            active_character="dharen",
            active_capability="analysis",
            state=state.value,
            event_refs=tuple(
                e.event_id
                for e in state_runtime.events(task.task_id)[-5:]
            ),
        )

        await self._publish(task)

    async def _publish(self, task):
        if self.publish is not None:
            value = self.publish(task)

            if asyncio.iscoroutine(value):
                await value

    @staticmethod
    def _deterministic_result(task):
        foundation = task.data_foundation

        data_fields = len(task.data)
        context_fields = len(task.context)
        reference_count = len(task.reference_details)
        canonical_rows = (
            len(foundation.canonical_data)
            if foundation is not None
            else 0
        )

        foundation_state = (
            f"{canonical_rows} canonical foundation row(s)"
            if foundation is not None
            else "no attached S5 foundation"
        )

        observations = (
            Observation(
                "obs-1",
                (
                    f"The supplied task contains {data_fields} "
                    f"top-level data field(s) and {context_fields} "
                    f"contextual field(s)."
                ),
                "measured",
            ),
            Observation(
                "obs-2",
                (
                    f"The task carries {reference_count} attached "
                    f"reference(s) and {foundation_state}."
                ),
                "measured",
            ),
        )

        findings = (
            Finding(
                "finding-1",
                (
                    "The supplied task can be processed with the "
                    "currently available deterministic analysis provider."
                ),
            ),
            Finding(
                "finding-2",
                (
                    "Interpretation remains bounded by the supplied "
                    "data, context, and curated foundation; no "
                    "unsupported intelligence claim is made."
                ),
            ),
        )

        evidence = (
            Evidence(
                "evidence-1",
                "Input structure",
                "analysis_task",
                (
                    f"{data_fields} data fields; "
                    f"{context_fields} context fields; "
                    f"{reference_count} references; "
                    f"{canonical_rows} canonical foundation rows"
                ),
            ),
        )

        return AnalysisResult(
            summary=(
                f"Deterministic analysis completed using "
                f"{data_fields} data fields, "
                f"{context_fields} context fields, "
                f"{reference_count} references, and "
                f"{canonical_rows} canonical foundation rows."
            ),
            observations=observations,
            findings=findings,
            evidence=evidence,
        )


analysis_tasks = AnalysisTaskService()


__all__ = [
    "AnalysisTaskService",
    "AnalysisTaskStore",
    "UnknownAnalysisTaskError",
    "analysis_tasks",
]