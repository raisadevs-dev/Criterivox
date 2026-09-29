from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


PHASES = (
    "structural_reasoning", "evidence_context_reasoning", "hypothesis_generation",
    "hypothesis_comparison", "critical_evaluation", "contradiction_conflict_handling",
    "branch_exploration", "counterfactual_scenario_reasoning", "revision_backtracking",
    "human_intervention_continuation",
)


@dataclass(frozen=True, slots=True)
class ReasoningNode:
    node_id: str
    phase: str
    status: str
    depends_on: tuple[str, ...] = ()
    artifact_ids: tuple[str, ...] = ()
    mechanism_ids: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class ReasoningGraph:
    nodes: tuple[ReasoningNode, ...]
    edges: tuple[tuple[str, str], ...]


class StagedReasoningPipeline:
    """Coordinates explicit stages without pretending to expose hidden chain-of-thought."""

    def plan(self, task: str, context: dict[str, Any]) -> ReasoningGraph:
        nodes = []
        edges = []
        for index, phase in enumerate(PHASES):
            node_id = f"phase-{index + 1}"
            deps = () if index == 0 else (f"phase-{index}",)
            nodes.append(ReasoningNode(node_id, phase, "planned", deps))
            if index:
                edges.append((f"phase-{index}", node_id))
        return ReasoningGraph(tuple(nodes), tuple(edges))

    def public_summary(self, graph: ReasoningGraph) -> list[dict[str, Any]]:
        return [{"node_id": n.node_id, "phase": n.phase, "status": n.status,
                 "depends_on": list(n.depends_on), "artifact_ids": list(n.artifact_ids),
                 "mechanism_ids": list(n.mechanism_ids)} for n in graph.nodes]
