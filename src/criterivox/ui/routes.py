"""Browser-facing UI routes and Home 03 interaction APIs."""
import asyncio
from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from ..application.syvax import syvax_engine
from ..application.bloom import bloom_controller
from ..infrastructure.runtime import handle_application_request

router = APIRouter()
templates = Jinja2Templates(directory="src/criterivox/ui/templates")

@router.get("/", response_class=HTMLResponse)
def home(request: Request):
    return templates.TemplateResponse(request=request, name="home.html", context={"request": request, "title": "Criterivox"})

@router.get("/settings", response_class=HTMLResponse)
def settings_page(request: Request):
    return templates.TemplateResponse(request=request, name="home.html", context={"request": request, "title": "Criterivox Settings"})

@router.get("/home-03", response_class=HTMLResponse)
def home03(request: Request):
    return templates.TemplateResponse(request=request, name="home03.html", context={"request": request, "title": "Home 03 • Syvax + The Bloom"})

def placeholder_page(request: Request, page_name: str):
    return templates.TemplateResponse(request=request, name="home.html", context={"request": request, "title": f"Criterivox {page_name}"})

def _register_placeholder(page_name: str) -> None:
    router.add_api_route(f"/{page_name}", lambda request, _page_name=page_name: placeholder_page(request, _page_name), methods=["GET"], response_class=HTMLResponse, name=f"{page_name}_page")
for _page in ("workspace", "data", "intelligence", "explanations", "experiments", "knowledge"):
    _register_placeholder(_page)

def _plan_payload(plan):
    return {"task_id": plan.task_id, "intent": {"goal": plan.intent.goal, "intent_type": plan.intent.intent_type, "confidence": plan.intent.confidence, "entities": plan.intent.entities}, "steps": [step.__dict__ for step in plan.steps], "created_at": plan.created_at}

@router.post("/api/syvax/plan")
async def syvax_plan(payload: dict):
    message = str(payload.get("message", "")).strip()
    safety = syvax_engine.safety_check(message)
    if safety["status"] == "blocked":
        return JSONResponse({"safety": safety, "plan": None}, status_code=422)
    return {"safety": safety, "plan": _plan_payload(syvax_engine.compile_plan(message, payload.get("task_id")))}

@router.post("/api/syvax/dispatch")
async def syvax_dispatch(payload: dict):
    message = str(payload.get("message", "")).strip()
    safety = syvax_engine.safety_check(message)
    if safety["status"] == "blocked":
        return JSONResponse({"safety": safety, "plan": None}, status_code=422)
    plan = syvax_engine.compile_plan(message, payload.get("task_id"))
    await handle_application_request({"contract_version": 1, "intent": plan.intent.intent_type if plan.intent.intent_type in {"analyze", "compare", "explain", "build", "explore"} else "analyze", "task": message, "task_id": plan.task_id, "data": payload.get("data", {}), "context": payload.get("context", {}), "source": "syvax-home03", "references": payload.get("references", [])})
    return {"safety": safety, "plan": _plan_payload(plan), "dispatched": True}

@router.post("/api/syvax/steer")
async def syvax_steer(payload: dict):
    return syvax_engine.steer(str(payload.get("task_id", "")), str(payload.get("correction", "")))

@router.post("/api/syvax/oversight")
async def syvax_oversight(payload: dict):
    return {"mode": syvax_engine.set_mode(str(payload.get("mode", "HITL")))}

@router.post("/api/syvax/budget")
async def syvax_budget(payload: dict):
    return {"home": str(payload.get("home", "")), "budget": syvax_engine.set_budget(str(payload.get("home", "")), int(payload.get("budget", 100)))}

@router.get("/api/bloom/state")
async def bloom_state():
    return bloom_controller.state()

@router.post("/api/bloom/mode")
async def bloom_mode(payload: dict):
    return {"mode": bloom_controller.set_mode(str(payload.get("mode", "HITL")))}

@router.post("/api/bloom/budget")
async def bloom_budget(payload: dict):
    return {"home": str(payload.get("home", "")), "budget": bloom_controller.set_budget(str(payload.get("home", "")), int(payload.get("budget", 100)))}

@router.post("/api/bloom/checkpoint")
async def bloom_checkpoint(payload: dict):
    return bloom_controller.checkpoint(str(payload.get("task_id", "unknown")), dict(payload.get("state", {})))

@router.post("/api/bloom/trace")
async def bloom_trace(payload: dict):
    return bloom_controller.evaluate(str(payload.get("task_id", "unknown")), str(payload.get("source", "")), str(payload.get("target", "")), float(payload.get("score", 1)), reason=str(payload.get("reason", "")))
