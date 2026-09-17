from __future__ import annotations
from dataclasses import asdict
from typing import Any
from criterivox.s7.reasoning_pipeline import StagedReasoningPipeline

def build_reasoning_graph(task: str, context: dict[str, Any]) -> dict[str, Any]:
    graph=StagedReasoningPipeline().plan(task,context)
    return {'nodes':[asdict(n) for n in graph.nodes],'edges':[{'from':a,'to':b} for a,b in graph.edges]}
