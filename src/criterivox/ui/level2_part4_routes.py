"""Part IV Intelligence and Decision/Action API routes."""

from fastapi import APIRouter
from fastapi.responses import JSONResponse

from ..world.level2_part4 import runtime

router = APIRouter(prefix="/api/world/level2/part4", tags=["world-level2-part4"])


def _call(fn, *args, **kwargs):
    try:
        return {"accepted": True, **fn(*args, **kwargs)}
    except KeyError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=404)
    except ValueError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=400)


@router.get("/state")
async def state():
    return runtime.state()


@router.get("/rooms")
async def rooms():
    return {"rooms": runtime.rooms()}


@router.post("/hypothesis")
async def hypothesis(payload: dict):
    return _call(runtime.create_hypothesis, str(payload.get("statement", "")), list(payload.get("assumptions", [])), list(payload.get("evidence_refs", [])), str(payload.get("title", "Candidate hypothesis")))


@router.post("/search")
async def search(payload: dict):
    return _call(runtime.search, str(payload.get("hypothesis_id", "")), str(payload.get("mode", "BALANCED")), int(payload.get("depth", 3)), int(payload.get("budget", 12)))


@router.post("/debate")
async def debate(payload: dict):
    return _call(runtime.debate, str(payload.get("hypothesis_id", "")), str(payload.get("objection", "")), str(payload.get("counter_hypothesis", "")), str(payload.get("actor", "vivren")))


@router.post("/audit")
async def audit(payload: dict):
    return _call(runtime.audit, str(payload.get("hypothesis_id", "")), list(payload.get("flags", [])))


@router.post("/counterfactual")
async def counterfactual(payload: dict):
    return _call(runtime.counterfactual, str(payload.get("hypothesis_id", "")), dict(payload.get("variables", {})))


@router.post("/reflexion")
async def reflexion(payload: dict):
    return _call(runtime.reflexion, str(payload.get("hypothesis_id", "")), str(payload.get("failure", "")), str(payload.get("remediation", "")))


@router.post("/goal-alignment")
async def goal_alignment(payload: dict):
    return _call(runtime.goal_alignment, str(payload.get("original_goal", "")), str(payload.get("current_goal", "")))


@router.post("/handoff")
async def handoff(payload: dict):
    return _call(runtime.handoff, str(payload.get("hypothesis_id", "")), str(payload.get("objective", "")), list(payload.get("evidence_refs", [])), list(payload.get("assumptions", [])), str(payload.get("uncertainty", "")))


@router.post("/conflict")
async def conflict(payload: dict):
    return _call(runtime.conflict, str(payload.get("hypothesis_id", "")), str(payload.get("thesis", "")), str(payload.get("objection", "")))


@router.post("/formalize")
async def formalize(payload: dict):
    return _call(runtime.formalize, str(payload.get("proposition", "")), list(payload.get("relations", [])))


@router.post("/plan")
async def plan(payload: dict):
    return _call(runtime.plan, str(payload.get("objective", "")), list(payload.get("steps", [])), list(payload.get("evidence_refs", [])))


@router.post("/tradeoff")
async def tradeoff(payload: dict):
    return _call(runtime.tradeoff, list(payload.get("alternatives", [])), list(payload.get("objectives", [])))


@router.post("/action-contract")
async def action_contract(payload: dict):
    return _call(runtime.action_contract, str(payload.get("objective", "")), str(payload.get("rationale", "")), list(payload.get("dependencies", [])), list(payload.get("constraints", [])), list(payload.get("preconditions", [])), dict(payload.get("tool_args", {})), dict(payload.get("rate_limits", {})), list(payload.get("validation", [])))


@router.post("/contingency")
async def contingency(payload: dict):
    return _call(runtime.contingency, str(payload.get("primary", "")), list(payload.get("fallbacks", [])))


@router.post("/proof")
async def proof(payload: dict):
    return _call(runtime.proof, str(payload.get("claim", "")), list(payload.get("evidence_refs", [])), list(payload.get("gaps", [])))


@router.post("/peer-review")
async def peer_review(payload: dict):
    return _call(runtime.peer_review, str(payload.get("contract_id", "")), str(payload.get("reviewer", "")), list(payload.get("objections", [])))


@router.post("/blast-radius")
async def blast_radius(payload: dict):
    return _call(runtime.blast_radius, str(payload.get("contract_id", "")), str(payload.get("impact", "REVIEW")), bool(payload.get("approval_required", False)))


@router.post("/execution-dag")
async def execution_dag(payload: dict):
    return _call(runtime.execution_dag, list(payload.get("nodes", [])))


@router.post("/resource-budget")
async def resource_budget(payload: dict):
    return _call(runtime.resource_budget, int(payload.get("estimated_tokens", 0)), int(payload.get("configured_budget", 1)), int(payload.get("api_calls", 0)), int(payload.get("latency_ms", 0)), int(payload.get("concurrency", 1)))


@router.post("/finops")
async def finops(payload: dict):
    return _call(runtime.finops, float(payload.get("estimated_cost", 0)), float(payload.get("budget", 0)), bool(payload.get("authorized", False)))


@router.post("/tool")
async def tool(payload: dict):
    return _call(runtime.register_tool, str(payload.get("identifier", "")), dict(payload.get("schema", {})), str(payload.get("capability", "")), list(payload.get("permissions", [])), int(payload.get("latency_ms", 0)), bool(payload.get("available", True)))


@router.post("/tool-health")
async def tool_health(payload: dict):
    return _call(runtime.tool_health_update, str(payload.get("identifier", "")), int(payload.get("failures", 0)), bool(payload.get("timeout", False)))


@router.post("/replay")
async def replay(payload: dict):
    return _call(runtime.replay, str(payload.get("checkpoint_id", "")), list(payload.get("events", [])))


@router.post("/archive")
async def archive(payload: dict):
    return _call(runtime.archive_decision, dict(payload))


@router.get("/latest")
async def latest():
    return {
        "hypotheses": list(runtime.hypotheses.values())[-10:],
        "plans": runtime.plans[-10:],
        "contracts": list(runtime.contracts.values())[-10:],
        "reviews": runtime.reviews[-10:],
        "tools": list(runtime.tools.values())[-20:],
        "tool_health": runtime.tool_health,
    }
