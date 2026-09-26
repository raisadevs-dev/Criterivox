"""Level-2 Part-I inspection APIs.

These endpoints expose the canonical runtime/read-model to the presentation
layer. They distinguish live runtime data from explicitly simulated routes.
"""
from fastapi import APIRouter
from fastapi.responses import JSONResponse

from ..world.level2_part1 import (
    AttentionState,
    CharacterState,
    TruthClass,
    level2_runtime,
)

router = APIRouter(prefix="/api/world/level2")


@router.get("/roster")
async def roster():
    return {"accepted": True, **level2_runtime.roster()}


@router.get("/characters/{character_id}")
async def character(character_id: str):
    if character_id not in level2_runtime.character_states:
        return JSONResponse({"accepted": False, "error": "character_not_found"}, status_code=404)
    definition = next(c for c in level2_runtime.roster()["characters"] if c["character_id"] == character_id)
    return {"accepted": True, "character": definition, "runtime": level2_runtime.state(character_id).to_dict()}


@router.post("/states/{character_id}")
async def update_character_state(character_id: str, payload: dict):
    if character_id not in level2_runtime.character_states:
        return JSONResponse({"accepted": False, "error": "character_not_found"}, status_code=404)
    try:
        value = level2_runtime.set_state(
            character_id,
            state=CharacterState(str(payload.get("state", "IDLE"))),
            attention=AttentionState(str(payload.get("attention", "ATTENTIVE"))),
            task=payload.get("task"),
            event=payload.get("event"),
            collaborators=[str(x) for x in payload.get("collaborators", [])],
            evidence_status=str(payload.get("evidence_status", "UNKNOWN")),
            truth=TruthClass(str(payload.get("truth", "LIVE"))),
        )
    except ValueError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=400)
    return {"accepted": True, "runtime": value.to_dict()}


@router.post("/handshake")
async def handshake(payload: dict):
    source = str(payload.get("source", "")).strip().lower()
    destination = str(payload.get("destination", "")).strip().lower()
    intent = str(payload.get("intent", "")).strip()
    if not source or not destination or not intent:
        return JSONResponse({"accepted": False, "error": "source_destination_intent_required"}, status_code=400)
    simulation = bool(payload.get("simulation", True))
    route = level2_runtime.create_route(
        source=source,
        destination=destination,
        intent=intent,
        simulation=simulation,
    )
    envelope = level2_runtime.envelope(
        source=source,
        target=destination,
        intent=intent,
        required_context=dict(payload.get("required_context") or {}),
        excluded_content=["private_chain_of_thought"],
        truth=TruthClass.SIMULATED if simulation else TruthClass.LIVE,
    )
    return {
        "accepted": True,
        "route": route.to_dict(),
        "envelope": envelope.to_dict(),
        "trace": level2_runtime.trace(route.trace_id).to_dict(),
        "simulation": simulation,
    }


@router.get("/network")
async def network():
    return {"accepted": True, **level2_runtime.route_status()}


@router.get("/trace/{trace_id}")
async def trace(trace_id: str):
    value = level2_runtime.trace(trace_id)
    if value is None:
        return JSONResponse({"accepted": False, "error": "trace_not_found"}, status_code=404)
    return {"accepted": True, "trace": value.to_dict()}


@router.get("/capabilities")
async def capabilities():
    return {
        "accepted": True,
        "capabilities": level2_runtime.route_status()["capabilities"],
        "truth": "LIVE",
    }
