from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Mapping
from uuid import uuid4


@dataclass
class Sandbox:
    sandbox_id: str
    foundation_id: str
    base_state_version: int
    variables: dict[str, Any] = field(default_factory=dict)
    status: str = "created"
    result: dict[str, Any] = field(default_factory=dict)
    created_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    updated_at: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

    def touch(self) -> None:
        self.updated_at = datetime.now(timezone.utc).isoformat()


class ContextSandboxManager:
    """Operational lifecycle for isolated context replay state."""

    def __init__(self) -> None:
        self._sandboxes: dict[str, Sandbox] = {}

    def create(self, foundation_id: str, base_state_version: int, variables: Mapping[str, Any] | None = None) -> Sandbox:
        sandbox = Sandbox(f"sandbox-{uuid4().hex[:12]}", foundation_id, base_state_version, dict(variables or {}))
        self._sandboxes[sandbox.sandbox_id] = sandbox
        return sandbox

    def populate(self, sandbox_id: str, variables: Mapping[str, Any]) -> Sandbox:
        sandbox = self.get(sandbox_id)
        sandbox.variables.update(dict(variables))
        sandbox.status = "populated"
        sandbox.touch()
        return sandbox

    def run(self, sandbox_id: str, executor) -> Sandbox:
        sandbox = self.get(sandbox_id)
        sandbox.status = "running"
        sandbox.touch()
        result = executor(dict(sandbox.variables))
        sandbox.result = dict(result or {})
        sandbox.status = "completed"
        sandbox.touch()
        return sandbox

    def replay(self, sandbox_id: str, executor) -> Sandbox:
        return self.run(sandbox_id, executor)

    def compare(self, sandbox_id: str, active: Mapping[str, Any]) -> dict[str, Any]:
        sandbox = self.get(sandbox_id)
        keys = sorted(set(active) | set(sandbox.variables) | set(sandbox.result))
        changed = [key for key in keys if active.get(key) != sandbox.result.get(key, sandbox.variables.get(key))]
        added = [key for key in keys if key not in active]
        removed = [key for key in keys if key not in sandbox.result and key not in sandbox.variables]
        return {"sandbox_id": sandbox_id, "changed": changed, "added": added, "removed": removed, "equivalent": not changed and not added and not removed}

    def promote(self, sandbox_id: str) -> dict[str, Any]:
        sandbox = self.get(sandbox_id)
        if sandbox.status != "completed":
            raise ValueError("Only a completed sandbox can be promoted.")
        sandbox.status = "promoted"
        sandbox.touch()
        return dict(sandbox.result or sandbox.variables)

    def discard(self, sandbox_id: str) -> None:
        sandbox = self.get(sandbox_id)
        sandbox.status = "discarded"
        sandbox.touch()

    def inspect(self, sandbox_id: str) -> dict[str, Any]:
        sandbox = self.get(sandbox_id)
        return {"sandbox_id": sandbox.sandbox_id, "foundation_id": sandbox.foundation_id, "base_state_version": sandbox.base_state_version, "variables": dict(sandbox.variables), "status": sandbox.status, "result": dict(sandbox.result), "created_at": sandbox.created_at, "updated_at": sandbox.updated_at}

    def list(self, foundation_id: str | None = None) -> list[dict[str, Any]]:
        values = self._sandboxes.values() if foundation_id is None else (s for s in self._sandboxes.values() if s.foundation_id == foundation_id)
        return [self.inspect(s.sandbox_id) for s in values]

    def get(self, sandbox_id: str) -> Sandbox:
        try:
            return self._sandboxes[sandbox_id]
        except KeyError as exc:
            raise ValueError(f"Unknown sandbox: {sandbox_id}") from exc


__all__ = ["ContextSandboxManager", "Sandbox"]
