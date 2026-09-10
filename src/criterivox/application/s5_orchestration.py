"""Sprint 5 orchestration contracts for Syvax and Dharen."""
from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
import os
import re
from typing import Any
from urllib.parse import quote

from criterivox.application.analysis_tasks import analysis_tasks

PAST_QUERY = re.compile(r"\b(past|previous|earlier|old|history|historical)\b.*\b(analysis|task|report|result|finding)s?\b|\b(show|find|query|retrieve)\b.*\b(previous|past|old)\b", re.I)
SUMMON = re.compile(r"@(sandre|dharen)\b", re.I)

@dataclass(frozen=True, slots=True)
class DoorAddressConfig:
    workspace_path: str = "/workspace"
    stewardship_path: str = "/workspace/sandre"

    @classmethod
    def from_environment(cls) -> "DoorAddressConfig":
        return cls(
            workspace_path=os.getenv("CRITERIVOX_ANALYSIS_WORKSPACE_PATH", "/workspace"),
            stewardship_path=os.getenv("CRITERIVOX_SANDRE_WORKSPACE_PATH", "/workspace/sandre"),
        )

DOOR_CONFIG = DoorAddressConfig.from_environment()

@dataclass(frozen=True, slots=True)
class DoorAddress:
    character: str
    path: str
    state: tuple[tuple[str, str], ...] = ()
    @property
    def url(self) -> str:
        query = "&".join(f"{quote(k)}={quote(v)}" for k, v in self.state)
        return self.path + (f"?{query}" if query else "")

@dataclass(frozen=True, slots=True)
class LineageSnapshot:
    material_set_id: str
    timestamp: str
    user_intent_context: dict[str, Any]
    def to_dict(self) -> dict[str, Any]:
        return {"material_set_id": self.material_set_id, "timestamp": self.timestamp, "user_intent_context": dict(self.user_intent_context)}

def is_past_analysis_query(message: str) -> bool:
    return bool(PAST_QUERY.search(message.strip()))

def summoned_members(message: str) -> tuple[str, ...]:
    return tuple(dict.fromkeys(m.group(1).lower() for m in SUMMON.finditer(message)))

def analysis_door(task_id: str) -> DoorAddress:
    return DoorAddress("dharen", DOOR_CONFIG.workspace_path, (("task_id", task_id), ("focus", "analysis")))

def stewardship_door(material_set_id: str) -> DoorAddress:
    return DoorAddress("sandre", DOOR_CONFIG.stewardship_path, (("highlight", material_set_id),))

def lineage_snapshot(foundation: Any, *, intent_context: dict[str, Any] | None = None) -> LineageSnapshot:
    return LineageSnapshot(foundation.foundation_id, datetime.now(timezone.utc).isoformat(), dict(intent_context or foundation.supplied_context or {}))

def past_analysis_summary(query: str = "") -> tuple[dict[str, Any], ...]:
    results = analysis_tasks.find_tasks(query, character="dharen")
    return tuple({"task_id": task.task_id, "task": task.task, "state": task.state.value, "updated_at": task.updated_at.isoformat(), "foundation_id": task.foundation_id, "summary": task.result.summary if task.result else "No completed analytical result is stored for this task."} for task in results[:10])

DELIVERY_PACKAGES: dict[str, dict[str, Any]] = {}

def delivery_package(task: Any) -> dict[str, Any]:
    package = {"delivery_id": f"delivery-{task.task_id}", "task_id": task.task_id, "recipient": "viveda", "status": "READY_FOR_INSPECTION", "created_at": datetime.now(timezone.utc).isoformat(), "result_summary": task.result.summary if task.result else None, "observations": [o.text for o in (task.result.observations if task.result else ())], "findings": [f.statement for f in (task.result.findings if task.result else ())], "evidence": [e.detail for e in (task.result.evidence if task.result else ())], "references": list(task.references)}
    DELIVERY_PACKAGES[task.task_id] = package
    return package

def get_delivery_package(task_id: str) -> dict[str, Any] | None:
    return DELIVERY_PACKAGES.get(task_id)
