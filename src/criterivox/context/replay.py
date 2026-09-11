from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Mapping

from .models import AdaptiveContextState, ContextInput
from .sandbox import ContextSandboxManager


@dataclass(frozen=True)
class ReplayResult:
    replay_id: str
    foundation_id: str
    sandbox_id: str
    task_id: str
    state_version: int
    context: Mapping[str, Any]
    comparison: Mapping[str, Any]


class ContextReplayService:
    """Runs a forked context through Dharen and the normal AnalysisTask pipeline."""

    def __init__(self, runtime, analysis_tasks, dharen_runtime) -> None:
        self.runtime = runtime
        self.analysis_tasks = analysis_tasks
        self.dharen_runtime = dharen_runtime
        self.sandboxes = ContextSandboxManager()

    def create(self, foundation_id: str, state: AdaptiveContextState, variables: Mapping[str, Any] | None = None) -> dict[str, Any]:
        sandbox = self.sandboxes.create(foundation_id, state.state_version, variables or state.active_context)
        return self.sandboxes.inspect(sandbox.sandbox_id)

    async def run_fork(self, foundation, state: AdaptiveContextState, *, sandbox_id: str, overrides: Mapping[str, Any], task_id: str) -> ReplayResult:
        sandbox = self.sandboxes.populate(sandbox_id, overrides)
        base = dict(state.active_context)
        fork_context = dict(base)
        fork_context.update(overrides)
        sandbox.variables = fork_context
        sandbox.status = "running"
        sandbox.touch()
        task = self.analysis_tasks.create_task(
            task="Replay the active analysis under the forked S6 context.",
            data={"foundation_id": foundation.foundation_id, "canonical_rows": len(foundation.canonical_data), "replay": True, "sandbox_id": sandbox_id},
            context=fork_context,
            source=getattr(task_id, "source", None) or "s6-context-replay",
            references=tuple(s.source_id for s in foundation.sources),
            data_foundation=foundation,
        )
        await self.dharen_runtime.publish_task(task, message="Dharen started a forked context replay.", event="S6_CONTEXT_FORK_STARTED")
        if not task.is_terminal:
            await self.analysis_tasks.execute(task.task_id)
        result = {"task_id": task.task_id, "terminal": task.is_terminal, "result": getattr(task, "result", None)}
        sandbox.result = result
        sandbox.status = "completed"
        sandbox.touch()
        comparison = self.sandboxes.compare(sandbox_id, base)
        return ReplayResult(sandbox_id, foundation.foundation_id, sandbox_id, task.task_id, state.state_version, fork_context, comparison)

    def inspect(self, sandbox_id: str) -> dict[str, Any]:
        return self.sandboxes.inspect(sandbox_id)

    def promote(self, sandbox_id: str) -> dict[str, Any]:
        return self.sandboxes.promote(sandbox_id)

    def discard(self, sandbox_id: str) -> None:
        self.sandboxes.discard(sandbox_id)


__all__ = ["ContextReplayService", "ReplayResult"]
