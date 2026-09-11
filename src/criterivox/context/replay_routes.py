from __future__ import annotations

from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/runtime/context", tags=["s6-context"])
_service = None


def configure(service) -> None:
    global _service
    _service = service


def service():
    if _service is None:
        raise HTTPException(status_code=503, detail="S6 replay service is not initialized")
    return _service


@router.post("/sandbox/create")
async def create_sandbox(payload: dict) -> dict:
    try:
        foundation_id = str(payload["foundation_id"])
        state = service().runtime.states[foundation_id]
        return service().create(foundation_id, state, payload.get("variables", {}))
    except KeyError as exc:
        raise HTTPException(status_code=404, detail=f"Unknown foundation: {exc}") from exc


@router.post("/sandbox/run")
async def run_sandbox(payload: dict) -> dict:
    try:
        foundation_id = str(payload["foundation_id"])
        sandbox_id = str(payload["sandbox_id"])
        state = service().runtime.states[foundation_id]
        foundation = service().runtime_foundations.get(foundation_id)
        if foundation is None:
            raise KeyError(foundation_id)
        result = await service().run_fork(foundation, state, sandbox_id=sandbox_id, overrides=payload.get("overrides", {}), task_id=str(payload.get("task_id", "S6-REPLAY")))
        return {"message_type": "context_replay_result", "replay_id": result.replay_id, "foundation_id": result.foundation_id, "sandbox_id": result.sandbox_id, "task_id": result.task_id, "state_version": result.state_version, "context": dict(result.context), "comparison": dict(result.comparison)}
    except KeyError as exc:
        raise HTTPException(status_code=404, detail=f"Unknown S6 state: {exc}") from exc
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/sandbox/{sandbox_id}")
async def inspect_sandbox(sandbox_id: str) -> dict:
    try:
        return service().inspect(sandbox_id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.post("/sandbox/{sandbox_id}/promote")
async def promote_sandbox(sandbox_id: str) -> dict:
    try:
        return {"message_type": "context_sandbox_promoted", "sandbox_id": sandbox_id, "state": service().promote(sandbox_id)}
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/sandbox/{sandbox_id}/discard")
async def discard_sandbox(sandbox_id: str) -> dict:
    try:
        service().discard(sandbox_id)
        return {"message_type": "context_sandbox_discarded", "sandbox_id": sandbox_id}
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
