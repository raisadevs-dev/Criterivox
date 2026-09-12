"""Local Python mirror for browser Human Residence records.

The browser IndexedDB record is authoritative for browser-local work. Python
keeps a durable local mirror so runtime restarts do not erase the residence
metadata and so future DataFoundation/context handoff can bind to residence_id.
This is local persistence, not production authentication.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

DEFAULT_PATH = Path("data/runtime/human_residences.json")


def save_residence(record: dict[str, Any], path: str | Path = DEFAULT_PATH) -> dict[str, Any]:
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    existing = load_residences(target)
    residence_id = str(record["residence_id"])
    existing[residence_id] = dict(record)
    target.write_text(json.dumps(existing, indent=2, sort_keys=True), encoding="utf-8")
    return existing[residence_id]


def load_residences(path: str | Path = DEFAULT_PATH) -> dict[str, dict[str, Any]]:
    target = Path(path)
    if not target.exists():
        return {}
    raw = json.loads(target.read_text(encoding="utf-8"))
    return {str(k): dict(v) for k, v in raw.items()}


def get_residence(residence_id: str, path: str | Path = DEFAULT_PATH) -> dict[str, Any] | None:
    return load_residences(path).get(residence_id)
