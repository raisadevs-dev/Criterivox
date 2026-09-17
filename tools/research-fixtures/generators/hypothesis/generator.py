from __future__ import annotations


def generate(count: int, task: str) -> list[dict]:
    return [{"hypothesis_id": f"H{i+1}", "statement": f"Synthetic alternative {i+1} for {task}", "synthetic": True} for i in range(max(2, count))]
