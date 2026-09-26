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

@router.post("/loop-check")
async def loop_check(payload: dict):
    return {"accepted": True, "loop": level2_runtime.inspect_loop([str(x) for x in payload.get("visited_nodes", [])], int(payload.get("max_depth", 8)))}


@router.post("/edge-metric")
async def edge_metric(payload: dict):
    return {"accepted": True, "edge": level2_runtime.update_edge_metric(
        str(payload.get("source", "")), str(payload.get("target", "")),
        latency_ms=float(payload.get("latency_ms", 0.0)),
        success=bool(payload.get("success", True)),
        active_workload=int(payload.get("active_workload", 0)),
    )}


@router.post("/protocol-bridge")
async def protocol_bridge(payload: dict):
    try:
        return {"accepted": True, "bridge": level2_runtime.translate_protocol(
            str(payload.get("source_protocol", "")),
            str(payload.get("target_protocol", "")),
            dict(payload.get("payload") or {}),
        )}
    except ValueError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=400)


@router.post("/parallel-route")
async def parallel_route(payload: dict):
    try:
        return {"accepted": True, "parallel": level2_runtime.parallel_route(
            str(payload.get("source", "anukor")),
            [str(x) for x in payload.get("destinations", [])],
            str(payload.get("intent", "")),
        )}
    except ValueError as exc:
        return JSONResponse({"accepted": False, "error": str(exc)}, status_code=400)


@router.post("/events/subscribe")
async def event_subscribe(payload: dict):
    event_type = str(payload.get("event_type", "")).strip()
    subscriber = str(payload.get("subscriber", "")).strip()
    if not event_type or not subscriber:
        return JSONResponse({"accepted": False, "error": "event_type_and_subscriber_required"}, status_code=400)
    level2_runtime.subscribe(event_type, subscriber)
    return {"accepted": True, "event_type": event_type, "subscriber": subscriber}


@router.post("/events/dispatch")
async def event_dispatch(payload: dict):
    event_type = str(payload.get("event_type", "")).strip()
    producer = str(payload.get("producer", "")).strip()
    if not event_type or not producer:
        return JSONResponse({"accepted": False, "error": "event_type_and_producer_required"}, status_code=400)
    return {"accepted": True, "event": level2_runtime.dispatch_event(event_type, producer, dict(payload.get("payload") or {}))}
