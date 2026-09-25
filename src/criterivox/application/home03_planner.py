from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any

ALLOWED_HOMES = {f"Home {i:02d}" for i in range(1, 9)}
ALLOWED_ACTORS = {
    "Dharen",
    "Syvax",
    "Tarkis",
    "Vivren",
    "Medrus",
    "Epistre",
    "Pramon",
    "Manis",
    "Kaelen",
    "Anuka",
    "Bodhex",
    "Veridat",
    "Viveda",
    "Sandre",
}


@dataclass(frozen=True)
class RouteNode:
    id: str
    actor: str
    home: str
    capability: str


@dataclass(frozen=True)
class RouteEdge:
    source: str
    target: str
    reason: str


@dataclass(frozen=True)
class CandidateRouteGraph:
    graph_id: str
    task_id: str
    intent: str
    nodes: tuple[RouteNode, ...]
    edges: tuple[RouteEdge, ...]
    rationale: dict[str, Any]


class CandidateRoutePlanner:
    """Turns the canonical Syvax plan into an inspectable route graph."""

    def propose(self, plan) -> CandidateRouteGraph:
        nodes = tuple(
            RouteNode(
                f"n{i + 1}",
                step.actor,
                step.home,
                step.capability,
            )
            for i, step in enumerate(plan.steps)
        )
        edges = tuple(
            RouteEdge(
                nodes[i].id,
                nodes[i + 1].id,
                nodes[i + 1].capability,
            )
            for i in range(len(nodes) - 1)
        )
        return CandidateRouteGraph(
            graph_id=f"candidate-{plan.task_id}",
            task_id=plan.task_id,
            intent=plan.intent.intent_type,
            nodes=nodes,
            edges=edges,
            rationale={
                "confidence": plan.intent.confidence,
                "source": "Syvax hybrid planner",
            },
        )


class DeterministicRoutePolicy:
    """Safety boundary between a proposed route and runtime execution."""

    def validate(self, graph: CandidateRouteGraph) -> dict[str, Any]:
        reasons: list[str] = []
        ids = {node.id for node in graph.nodes}

        if not graph.nodes:
            reasons.append("Candidate graph must contain at least one node.")
        if any(node.actor not in ALLOWED_ACTORS for node in graph.nodes):
            reasons.append("Unknown actor in candidate graph.")
        if any(node.home not in ALLOWED_HOMES for node in graph.nodes):
            reasons.append("Unknown home in candidate graph.")
        if any(
            edge.source not in ids or edge.target not in ids
            for edge in graph.edges
        ):
            reasons.append("Edge references an unknown node.")
        if graph.nodes and graph.nodes[-1].actor != "Syvax":
            reasons.append("Human-facing plans must terminate at Syvax.")
        if len({node.actor for node in graph.nodes}) != len(graph.nodes):
            reasons.append(
                "Duplicate actor execution is rejected by the baseline policy."
            )

        return {
            "valid": not reasons,
            "reasons": reasons,
            "policy": "home03-route-policy-v1",
            "graph": asdict(graph),
        }


class RuntimeAdaptivePlanner:
    """Re-evaluates a plan from runtime signals without owning task execution."""

    def __init__(self) -> None:
        self.candidates: dict[str, dict[str, Any]] = {}
        self.policy = DeterministicRoutePolicy()
        self.planner = CandidateRoutePlanner()

    def propose(self, plan) -> dict[str, Any]:
        graph = self.planner.propose(plan)
        validation = self.policy.validate(graph)
        self.candidates[graph.graph_id] = {
            "graph": graph,
            "validation": validation,
        }
        return {
            "candidate": asdict(graph),
            "validation": validation,
        }

    def revise(self, plan, event: dict[str, Any]):
        signal: dict[str, Any] = {}
        confidence = event.get("confidence")
        if confidence is not None and float(confidence) < 0.5:
            signal["evidence_required"] = True
            signal["human_challenge"] = True

        target = str(event.get("target", ""))
        if (
            target in {"Tarkis", "Vivren"}
            and event.get("status") in {"failed", "blocked"}
        ):
            signal["skip_hypothesis"] = True

        return signal, plan


runtime_adaptive_planner = RuntimeAdaptivePlanner()
