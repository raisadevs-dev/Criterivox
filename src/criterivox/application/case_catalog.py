"""Standardized case contract loader for the demo boundary.

Case manifests describe execution contracts. They do not contain answer keys.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[3]
CASE_ROOT = ROOT / "packages" / "avishkaar_demo" / "cases"


def load_case(case_id: str) -> dict[str, Any]:
    normalized = str(case_id or "CASE-001").strip().upper()
    path = CASE_ROOT / normalized / "manifest.json"
    if not path.is_file():
        raise ValueError(f"unknown_case:{normalized}")
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("case_id") != normalized:
        raise ValueError(f"case_manifest_mismatch:{normalized}")
    return data


def available_cases() -> list[str]:
    return sorted(
        p.name for p in CASE_ROOT.glob("CASE-*")
        if (p / "manifest.json").is_file()
    )


__all__ = ["load_case", "available_cases"]
