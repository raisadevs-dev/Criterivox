from __future__ import annotations

import json
from collections.abc import Mapping, Sequence
from typing import Any


def to_human_text(value: Any) -> str:
    """Convert common human/data forms into traceable text without inventing meaning."""
    if value is None:
        return ""
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace").strip()
    if isinstance(value, str):
        return value.strip()
    if isinstance(value, Mapping):
        parts = []
        for key, item in value.items():
            rendered = to_human_text(item)
            parts.append(f"{key}: {rendered}" if rendered else f"{key}:")
        return "\n".join(parts).strip()
    if isinstance(value, Sequence) and not isinstance(value, (str, bytes, bytearray)):
        return "\n".join(
            f"{index + 1}. {to_human_text(item)}"
            for index, item in enumerate(value)
        ).strip()
    if isinstance(value, (int, float, bool)):
        return str(value)
    return str(value).strip()


def normalize_material(value: Any) -> str:
    """Preserve JSON/CSV/plain-text material while giving downstream capabilities text."""
    if value is None:
        return ""
    if isinstance(value, str):
        return value.strip()
    if isinstance(value, (Mapping, list, tuple)):
        return json.dumps(value, ensure_ascii=False, indent=2, default=str)
    return to_human_text(value)


def normalize_human_situation(
    *,
    description: Any,
    data: Any = "",
    context: Any = "",
) -> tuple[str, str, str]:
    normalized_description = to_human_text(description)
    if not normalized_description:
        raise ValueError("situation description is required")
    return (
        normalized_description,
        normalize_material(data),
        to_human_text(context),
    )
