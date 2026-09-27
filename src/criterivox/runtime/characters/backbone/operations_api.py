from __future__ import annotations

from typing import Any
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from .operations import OperationEngine

router = APIRouter(prefix="/runtime/operations", tags=["set3-operations"])
ENGINE = OperationEngine()

class OperationRequest(BaseModel):
    message: str
    conversation_id: str = "chat"
    journey_id: str | None = None
    task_id: str | None = None
    requested_by: str = "human"
    context: dict[str, Any] = {}

@router.post("/command")
def command(request: OperationRequest) -> dict[str, Any]:
    try:
        return ENGINE.handle(request.model_dump())
    except RuntimeError as exc:
        code = str(exc)
        status = 409 if code.startswith(("BLOCKED", "NOT_AUTHORIZED")) else 501 if code == "NOT_IMPLEMENTED" else 400
        raise HTTPException(status_code=status, detail=code) from exc

@router.post("/approve/{command_id}")
def approve(command_id: str, actor: str = "human") -> dict[str, Any]:
    try:
        return ENGINE.approve(command_id, actor=actor)
    except KeyError as exc:
        raise HTTPException(status_code=404, detail="Unknown command.") from exc

@router.post("/reject/{command_id}")
def reject(command_id: str, actor: str = "human") -> dict[str, Any]:
    try:
        return ENGINE.reject(command_id, actor=actor).__dict__
    except KeyError as exc:
        raise HTTPException(status_code=404, detail="Unknown command.") from exc

@router.get("/{command_id}")
def inspect(command_id: str) -> dict[str, Any]:
    try:
        return ENGINE.snapshot(command_id)
    except KeyError as exc:
        raise HTTPException(status_code=404, detail="Unknown command.") from exc
