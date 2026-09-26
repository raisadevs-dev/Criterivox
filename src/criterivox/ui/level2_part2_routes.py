"""Canonical Level-2 Part-II presentation/control APIs."""
from fastapi import APIRouter
from fastapi.responses import JSONResponse

from ..world.level2_part2 import part2_runtime

router = APIRouter(prefix="/api/world/level2/part2")

@router.get("/state")
async def state():
    return {"accepted": True, **part2_runtime.state()}

@router.get("/homes/{home}")
async def home(home: str):
    try:
        return {"accepted": True, "home": part2_runtime.home(home)}
    except ValueError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=404)

@router.post("/render")
async def render(payload: dict):
    return {"accepted": True, "render": part2_runtime.adaptive_render(
        payload.get("result"), intent=str(payload.get("intent", "general")),
        detail=str(payload.get("detail", "balanced")),
    )}

@router.post("/guardrails")
async def guardrails(payload: dict):
    return {"accepted": True, "guardrails": part2_runtime.guardrail_state(
        [str(x) for x in payload.get("constraints", [])],
        [str(x) for x in payload.get("blocked_actions", [])],
    )}

@router.post("/ui-intents")
async def ui_intents(payload: dict):
    return {"accepted": True, "ui_intents": part2_runtime.synthesize_ui_intents(dict(payload or {}))}

@router.post("/steering")
async def steering(payload: dict):
    try:
        return {"accepted": True, "steering": part2_runtime.steer(
            str(payload.get("action", "")),
            checkpoint=payload.get("checkpoint"),
            changes=dict(payload.get("changes") or {}),
        )}
    except ValueError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=400)

@router.post("/energy")
async def energy(payload: dict):
    try:
        return {"accepted": True, "energy": part2_runtime.allocate_energy(
            str(payload.get("home", "")), int(payload.get("budget", 100))
        )}
    except (ValueError, TypeError) as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=400)

@router.post("/context-budget")
async def context_budget(payload: dict):
    try:
        allocation = {str(k): int(v) for k, v in dict(payload.get("allocation") or {}).items()}
        return {"accepted": True, "context_budget": part2_runtime.allocate_context_budget(allocation)}
    except (ValueError, TypeError) as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=400)

@router.get("/status")
async def status():
    return {"accepted": True, "status": part2_runtime.status_ticker()}
