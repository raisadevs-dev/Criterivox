from __future__ import annotations

import base64
import binascii
from typing import Any

from fastapi import APIRouter
from fastapi.responses import JSONResponse

from ..application.human_residence_work import residence_work

router = APIRouter(prefix="/api/residence", tags=["human-residence"])


def _error(exc: Exception, status: int = 400):
    return JSONResponse({"accepted": False, "error": str(exc)}, status_code=status)


@router.post("/work")
async def create_work(payload: dict[str, Any]):
    try:
        return {"accepted": True, "work": residence_work.create_work(
            owner_id=str(payload.get("owner_id", "human")),
            room_id=str(payload.get("room_id", "private")),
            goal=str(payload.get("goal", "")),
            language=str(payload.get("language", "en")),
            requirements=list(payload.get("requirements", [])),
            constraints=list(payload.get("constraints", [])),
            expected_output=str(payload.get("expected_output", "strategies and options")),
        )}
    except (ValueError, TypeError) as exc:
        return _error(exc)


@router.get("/work")
async def list_work(owner_id: str = "human", room_id: str | None = None):
    return {"accepted": True, "work": residence_work.list(owner_id, room_id)}


@router.get("/work/{work_id}")
async def get_work(work_id: str):
    try:
        return {"accepted": True, "work": residence_work.get(work_id)}
    except KeyError:
        return _error(ValueError("work_not_found"), 404)


@router.post("/work/{work_id}/interpret")
async def interpret_work(work_id: str):
    try:
        return {"accepted": True, "work": residence_work.interpret_work(work_id)}
    except (KeyError, ValueError) as exc:
        return _error(exc)


@router.post("/work/{work_id}/confirm")
async def confirm_work(work_id: str, payload: dict[str, Any]):
    try:
        return {"accepted": True, "work": residence_work.confirm(
            work_id,
            actor=str(payload.get("actor", "human")),
            confirmed=bool(payload.get("confirmed", True)),
            correction=payload.get("correction"),
        )}
    except (KeyError, ValueError) as exc:
        return _error(exc)


@router.post("/work/{work_id}/materials")
async def add_material(work_id: str, payload: dict[str, Any]):
    try:
        encoded = str(payload.get("content_base64", ""))
        raw = base64.b64decode(encoded, validate=True)
        material = residence_work.add_material(
            work_id,
            filename=str(payload.get("filename", "upload")),
            content_type=str(payload.get("content_type", "application/octet-stream")),
            data=raw,
            original_language=payload.get("original_language"),
        )
        return {"accepted": True, "material": material, "work": residence_work.get(work_id)}
    except (ValueError, TypeError, binascii.Error) as exc:
        return _error(exc)


@router.post("/work/{work_id}/take")
async def take_work(work_id: str, payload: dict[str, Any] | None = None):
    try:
        return {"accepted": True, "work": residence_work.take(work_id, str((payload or {}).get("actor", "human")))}
    except (KeyError, ValueError) as exc:
        return _error(exc)


@router.post("/work/{work_id}/challenge")
async def challenge_work(work_id: str, payload: dict[str, Any]):
    try:
        return {"accepted": True, "work": residence_work.challenge(
            work_id,
            actor=str(payload.get("actor", "human")),
            challenge_type=str(payload.get("challenge_type", "PREMISE")),
            text=str(payload.get("text", "")),
        )}
    except (KeyError, ValueError) as exc:
        return _error(exc)


@router.post("/work/{work_id}/decide")
async def decide_work(work_id: str, payload: dict[str, Any]):
    try:
        return {"accepted": True, "work": residence_work.decide(
            work_id,
            actor=str(payload.get("actor", "human")),
            option_id=str(payload.get("option_id", "")),
            modification=payload.get("modification"),
        )}
    except (KeyError, ValueError) as exc:
        return _error(exc)


@router.post("/work/{work_id}/authorize")
async def authorize_work(work_id: str, payload: dict[str, Any] | None = None):
    try:
        return {"accepted": True, "work": residence_work.authorize(work_id, actor=str((payload or {}).get("actor", "human")))}
    except (KeyError, ValueError) as exc:
        return _error(exc)


@router.post("/work/{work_id}/outcome")
async def outcome_work(work_id: str, payload: dict[str, Any]):
    try:
        return {"accepted": True, "work": residence_work.outcome(
            work_id,
            actor=str(payload.get("actor", "human")),
            observed=str(payload.get("observed", "")),
            verified=bool(payload.get("verified", False)),
        )}
    except (KeyError, ValueError) as exc:
        return _error(exc)
