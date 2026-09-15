from __future__ import annotations


def generate(component: str, count: int, task: str) -> list[dict]:
    return [{
        "record_id": f"obs-{i+1:04d}",
        "source_component": component,
        "observation": f"Synthetic observation {i+1} relevant to: {task}",
        "status": "synthetic",
    } for i in range(count)]
