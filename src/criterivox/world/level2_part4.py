"""Part IV Intelligence + Decision/Action integration runtime.

This module is deliberately an integration layer over the existing Part I-III
routing, evidence, collaboration, work-material, sandbox, replay and telemetry
systems. It does not create replacement engines for those systems.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any
import uuid


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _id(prefix: str) -> str:
    return f"{prefix}-{uuid.uuid4().hex[:10]}"


INTELLIGENCE_ROOMS = (
    "reasoning.hypothesis",
    "reasoning.debate",
    "reasoning.audit",
    "reasoning.search",
    "reasoning.counterfactual",
    "reasoning.supervision",
    "reasoning.boundary",
    "reasoning.reflexion",
    "reasoning.handoff",
    "reasoning.goal",
    "reasoning.formal",
    "reasoning.conflict",
)

DECISION_ROOMS = (
    "decision.planning",
    "decision.tradeoff",
    "decision.contract",
    "decision.contingency",
    "decision.proof",
    "decision.rationale",
    "decision.peer",
    "decision.blast",
    "decision.isolation",
    "decision.dag",
    "decision.budget",
    "decision.finops",
    "decision.mcp",
    "decision.replay",
    "decision.circuit",
)

LIVE = "LIVE"
SIMULATED = "SIMULATED"
HISTORICAL = "HISTORICAL"
PLANNED = "PLANNED"


@dataclass
class Hypothesis:
    hypothesis_id: str
    title: str
    statement: str
    assumptions: list[str]
    evidence_refs: list[str]
    status: str = "RAW_HYPOTHESIS"
    alternatives: list[str] = field(default_factory=list)
    created_at: str = field(default_factory=_now)


@dataclass
class ActionContract:
    contract_id: str
    objective: str
    rationale: str
    dependencies: list[str]
    constraints: list[str]
    preconditions: list[str]
    tool_args: dict[str, Any]
    rate_limits: dict[str, Any]
    validation: list[str]
    risk_state: str = "REVIEW"
    status: str = "DRAFT"


class Part4Runtime:
    """Canonical Part IV control/read model."""

    def __init__(self) -> None:
        self.hypotheses: dict[str, Hypothesis] = {}
        self.debates: list[dict[str, Any]] = []
        self.audits: list[dict[str, Any]] = []
        self.searches: list[dict[str, Any]] = []
        self.counterfactuals: list[dict[str, Any]] = []
        self.reflexions: list[dict[str, Any]] = []
        self.handoffs: list[dict[str, Any]] = []
        self.conflicts: list[dict[str, Any]] = []
        self.plans: list[dict[str, Any]] = []
        self.tradeoffs: list[dict[str, Any]] = []
        self.contracts: dict[str, ActionContract] = {}
        self.contingencies: list[dict[str, Any]] = []
        self.proofs: list[dict[str, Any]] = []
        self.reviews: list[dict[str, Any]] = []
        self.risk_profiles: list[dict[str, Any]] = []
        self.dags: list[dict[str, Any]] = []
        self.resources: list[dict[str, Any]] = []
        self.finops_records: list[dict[str, Any]] = []
        self.tools: dict[str, dict[str, Any]] = {}
        self.replays: list[dict[str, Any]] = []
        self.tool_health: dict[str, dict[str, Any]] = {}
        self.archive: list[dict[str, Any]] = []

    def rooms(self) -> dict[str, dict[str, Any]]:
        intelligence = {
            room: {
                "id": room,
                "home": "intelligence",
                "truth": LIVE,
                "owner": "Vivren" if room not in {"reasoning.hypothesis", "reasoning.search", "reasoning.counterfactual"} else "Tarkis",
            }
            for room in INTELLIGENCE_ROOMS
        }
        decision = {
            room: {
                "id": room,
                "home": "decision",
                "truth": LIVE,
                "owner": "Pramon" if room in {"decision.planning", "decision.tradeoff", "decision.contingency", "decision.proof", "decision.rationale", "decision.peer", "decision.budget", "decision.finops"} else "Bodhex",
            }
            for room in DECISION_ROOMS
        }
        return {**intelligence, **decision}

    def state(self) -> dict[str, Any]:
        return {
            "version": "part4-v1",
            "updated_at": _now(),
            "homes": {
                "intelligence": {"resident": "Vivren", "partner": "Tarkis", "truth": LIVE, "rooms": list(INTELLIGENCE_ROOMS)},
                "decision": {"resident": "Pramon", "partner": "Bodhex", "truth": LIVE, "rooms": list(DECISION_ROOMS)},
            },
            "rooms": self.rooms(),
            "counts": {
                "hypotheses": len(self.hypotheses),
                "debates": len(self.debates),
                "audits": len(self.audits),
                "searches": len(self.searches),
                "counterfactuals": len(self.counterfactuals),
                "plans": len(self.plans),
                "contracts": len(self.contracts),
                "reviews": len(self.reviews),
                "tools": len(self.tools),
            },
            "integration": {
                "parts_1_3_reuse": [
                    "routing",
                    "trace",
                    "event",
                    "collaboration",
                    "human-authority",
                    "evidence/provenance",
                    "work-materials",
                    "sandbox",
                    "checkpoint/replay",
                    "telemetry",
                ],
                "duplicate_engines": [],
            },
        }

    def create_hypothesis(self, statement: str, assumptions: list[str] | None = None, evidence_refs: list[str] | None = None, title: str = "Candidate hypothesis") -> dict[str, Any]:
        h = Hypothesis(_id("hyp"), title, statement, assumptions or [], evidence_refs or [])
        self.hypotheses[h.hypothesis_id] = h
        return h.__dict__.copy()

    def search(self, hypothesis_id: str, mode: str = "BALANCED", depth: int = 3, budget: int = 12) -> dict[str, Any]:
        if hypothesis_id not in self.hypotheses:
            raise KeyError("hypothesis_not_found")
        modes = {"FAST", "BALANCED", "DEEP", "EXPERIMENTAL"}
        if mode.upper() not in modes:
            raise ValueError("invalid_search_mode")
        depth = max(1, min(int(depth), 12))
        budget = max(1, min(int(budget), 100))
        h = self.hypotheses[hypothesis_id]
        result = {
            "search_id": _id("search"),
            "hypothesis_id": hypothesis_id,
            "mode": mode.upper(),
            "depth": depth,
            "budget": budget,
            "branches": [{"branch_id": f"{hypothesis_id}-b{i}", "score": round(1.0 / i, 4), "status": "CANDIDATE"} for i in range(1, min(depth, 4) + 1)],
            "truth": SIMULATED,
            "created_at": _now(),
        }
        self.searches.append(result)
        h.status = "SEARCHED"
        return result

    def debate(self, hypothesis_id: str, objection: str, counter_hypothesis: str = "", actor: str = "vivren") -> dict[str, Any]:
        if hypothesis_id not in self.hypotheses:
            raise KeyError("hypothesis_not_found")
        result = {
            "debate_id": _id("debate"),
            "hypothesis_id": hypothesis_id,
            "actor": actor,
            "objection": objection.strip(),
            "counter_hypothesis": counter_hypothesis.strip(),
            "status": "UNDER_REVIEW",
            "truth": LIVE,
            "created_at": _now(),
        }
        self.debates.append(result)
        self.hypotheses[hypothesis_id].status = "UNDER_CHALLENGE"
        return result

    def audit(self, hypothesis_id: str, flags: list[dict[str, Any]]) -> dict[str, Any]:
        if hypothesis_id not in self.hypotheses:
            raise KeyError("hypothesis_not_found")
        result = {
            "audit_id": _id("audit"),
            "hypothesis_id": hypothesis_id,
            "flags": flags,
            "status": "PASS" if not flags else "NEEDS_REVIEW",
            "truth": LIVE,
            "created_at": _now(),
        }
        self.audits.append(result)
        return result

    def counterfactual(self, hypothesis_id: str, variables: dict[str, Any]) -> dict[str, Any]:
        if hypothesis_id not in self.hypotheses:
            raise KeyError("hypothesis_not_found")
        result = {
            "scenario_id": _id("cf"),
            "hypothesis_id": hypothesis_id,
            "changed_variables": variables,
            "baseline_status": "REFERENCE",
            "result": "SIMULATED_SCENARIO",
            "stability": "UNASSESSED",
            "truth": SIMULATED,
            "created_at": _now(),
        }
        self.counterfactuals.append(result)
        return result

    def reflexion(self, hypothesis_id: str, failure: str, remediation: str) -> dict[str, Any]:
        result = {"reflexion_id": _id("ref"), "hypothesis_id": hypothesis_id, "failure": failure, "remediation": remediation, "status": "RECORDED", "truth": HISTORICAL, "created_at": _now()}
        self.reflexions.append(result)
        return result

    def goal_alignment(self, original_goal: str, current_goal: str) -> dict[str, Any]:
        a = " ".join(original_goal.lower().split())
        b = " ".join(current_goal.lower().split())
        if not a or not b:
            score = 0.0
        else:
            aa, bb = set(a.split()), set(b.split())
            score = round(len(aa & bb) / max(1, len(aa | bb)), 4)
        result = {"alignment_id": _id("goal"), "original_goal": original_goal, "current_goal": current_goal, "score": score, "drift": round(1.0 - score, 4), "truth": LIVE, "created_at": _now()}
        return result

    def handoff(self, hypothesis_id: str, objective: str, evidence_refs: list[str], assumptions: list[str], uncertainty: str) -> dict[str, Any]:
        missing = [name for name, value in {"objective": objective, "hypothesis_id": hypothesis_id}.items() if not value]
        result = {"handoff_id": _id("handoff"), "hypothesis_id": hypothesis_id, "objective": objective, "evidence_refs": evidence_refs, "assumptions": assumptions, "uncertainty": uncertainty, "status": "REJECTED" if missing else "VALIDATED", "missing": missing, "truth": LIVE, "created_at": _now()}
        self.handoffs.append(result)
        return result

    def conflict(self, hypothesis_id: str, thesis: str, objection: str) -> dict[str, Any]:
        result = {"conflict_id": _id("conflict"), "hypothesis_id": hypothesis_id, "thesis": thesis, "objection": objection, "status": "OPEN", "truth": LIVE, "created_at": _now()}
        self.conflicts.append(result)
        return result

    def formalize(self, proposition: str, relations: list[dict[str, Any]]) -> dict[str, Any]:
        result = {"formal_id": _id("formal"), "proposition": proposition, "logic_graph": {"nodes": [{"id": "p0", "label": proposition}], "relations": relations}, "status": "STRUCTURED", "truth": LIVE, "created_at": _now()}
        return result

    def plan(self, objective: str, steps: list[dict[str, Any]], evidence_refs: list[str] | None = None) -> dict[str, Any]:
        result = {"plan_id": _id("plan"), "objective": objective, "steps": steps, "evidence_refs": evidence_refs or [], "status": "DRAFT", "truth": LIVE, "created_at": _now()}
        self.plans.append(result)
        return result

    def tradeoff(self, alternatives: list[dict[str, Any]], objectives: list[str]) -> dict[str, Any]:
        if not alternatives:
            raise ValueError("alternatives_required")
        result = {"tradeoff_id": _id("trade"), "objectives": objectives, "alternatives": alternatives, "method": "DECLARED_METRICS", "truth": LIVE, "created_at": _now()}
        self.tradeoffs.append(result)
        return result

    def action_contract(self, objective: str, rationale: str, dependencies: list[str], constraints: list[str], preconditions: list[str], tool_args: dict[str, Any], rate_limits: dict[str, Any], validation: list[str]) -> dict[str, Any]:
        c = ActionContract(_id("action"), objective, rationale, dependencies, constraints, preconditions, tool_args, rate_limits, validation)
        self.contracts[c.contract_id] = c
        return c.__dict__.copy()

    def contingency(self, primary: str, fallbacks: list[dict[str, Any]]) -> dict[str, Any]:
        result = {"contingency_id": _id("cont"), "primary": primary, "fallbacks": fallbacks, "truth": LIVE, "created_at": _now()}
        self.contingencies.append(result)
        return result

    def proof(self, claim: str, evidence_refs: list[str], gaps: list[str] | None = None) -> dict[str, Any]:
        result = {"proof_id": _id("proof"), "claim": claim, "evidence_refs": evidence_refs, "gaps": gaps or [], "status": "SUFFICIENT" if evidence_refs and not gaps else "REVIEW_REQUIRED", "truth": LIVE, "created_at": _now()}
        self.proofs.append(result)
        return result

    def peer_review(self, contract_id: str, reviewer: str, objections: list[str] | None = None) -> dict[str, Any]:
        if contract_id not in self.contracts:
            raise KeyError("action_contract_not_found")
        result = {"review_id": _id("review"), "contract_id": contract_id, "reviewer": reviewer, "objections": objections or [], "status": "APPROVED" if not objections else "CHALLENGED", "truth": LIVE, "created_at": _now()}
        self.reviews.append(result)
        return result

    def blast_radius(self, contract_id: str, impact: str, approval_required: bool = False) -> dict[str, Any]:
        if contract_id not in self.contracts:
            raise KeyError("action_contract_not_found")
        normalized = impact.upper()
        state = "BLOCKED" if normalized == "BLOCKED" else "APPROVAL_REQUIRED" if approval_required else "REVIEW" if normalized in {"STATE_CHANGE", "EXTERNAL"} else "SAFE"
        result = {"risk_id": _id("risk"), "contract_id": contract_id, "impact": normalized, "state": state, "truth": LIVE, "created_at": _now()}
        self.risk_profiles.append(result)
        self.contracts[contract_id].risk_state = state
        return result

    def execution_dag(self, nodes: list[dict[str, Any]]) -> dict[str, Any]:
        result = {"dag_id": _id("dag"), "nodes": nodes, "status": "READY", "truth": LIVE, "created_at": _now()}
        self.dags.append(result)
        return result

    def resource_budget(self, estimated_tokens: int, configured_budget: int, api_calls: int = 0, latency_ms: int = 0, concurrency: int = 1) -> dict[str, Any]:
        estimated_tokens = max(0, int(estimated_tokens)); configured_budget = max(1, int(configured_budget))
        result = {"resource_id": _id("res"), "estimated_tokens": estimated_tokens, "actual_tokens": None, "api_calls": max(0, int(api_calls)), "latency_ms": max(0, int(latency_ms)), "concurrency": max(1, int(concurrency)), "configured_budget": configured_budget, "remaining_budget": max(0, configured_budget - estimated_tokens), "status": "WITHIN_BUDGET" if estimated_tokens <= configured_budget else "BUDGET_WARNING", "truth": LIVE, "created_at": _now()}
        self.resources.append(result)
        return result

    def finops(self, estimated_cost: float, budget: float, authorized: bool = False) -> dict[str, Any]:
        estimated_cost = max(0.0, float(estimated_cost)); budget = max(0.0, float(budget))
        result = {"finops_id": _id("fin"), "estimated_cost": estimated_cost, "budget": budget, "authorized": bool(authorized and estimated_cost <= budget), "throttle_required": estimated_cost > budget, "truth": LIVE, "created_at": _now()}
        self.finops_records.append(result)
        return result

    def register_tool(self, identifier: str, schema: dict[str, Any], capability: str, permissions: list[str], latency_ms: int = 0, available: bool = True) -> dict[str, Any]:
        if not identifier:
            raise ValueError("tool_identifier_required")
        result = {"identifier": identifier, "schema": schema, "capability": capability, "permissions": permissions, "latency_ms": max(0, int(latency_ms)), "available": bool(available), "health": "HEALTHY" if available else "ISOLATED", "registered_at": _now()}
        self.tools[identifier] = result
        self.tool_health[identifier] = {"state": result["health"], "failures": 0, "retries": 0, "updated_at": _now()}
        return result

    def tool_health_update(self, identifier: str, failures: int = 0, timeout: bool = False) -> dict[str, Any]:
        if identifier not in self.tools:
            raise KeyError("tool_not_registered")
        failures = max(0, int(failures))
        state = "ISOLATED" if timeout or failures >= 3 else "DEGRADED" if failures else "HEALTHY"
        result = {"identifier": identifier, "state": state, "failures": failures, "timeout": bool(timeout), "fallback": state != "HEALTHY", "updated_at": _now()}
        self.tool_health[identifier] = result
        self.tools[identifier]["health"] = state
        return result

    def replay(self, checkpoint_id: str, events: list[dict[str, Any]]) -> dict[str, Any]:
        result = {"replay_id": _id("replay"), "checkpoint_id": checkpoint_id, "event_count": len(events), "rehydrated": True, "status": "REPLAYABLE", "truth": HISTORICAL, "created_at": _now()}
        self.replays.append(result)
        return result

    def archive_decision(self, decision: dict[str, Any]) -> dict[str, Any]:
        result = {"archive_id": _id("archive"), **decision, "archived_at": _now()}
        self.archive.append(result)
        return result


runtime = Part4Runtime()
