from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from typing import Any

from fastapi import APIRouter
from fastapi.responses import JSONResponse, Response

from ..research.models import ResearchConsent
from ..research.telemetry import research_evidence
from ..research.export import build_csv_bundle, build_json_export
from ..application.human_residence_work import residence_work

router = APIRouter(prefix="/api/research", tags=["research"])


def _error(exc: Exception, status: int = 400):
    return JSONResponse({"accepted": False, "error": str(exc)}, status_code=status)


def _admin(token: str | None) -> None:
    configured = os.getenv("CRITERIVOX_RESEARCH_ADMIN_TOKEN", "").strip()
    if not configured or token != configured:
        raise PermissionError("research_admin_authorization_required")


@router.post("/session")
async def create_session(payload: dict[str, Any]):
    participant_id = str(payload.get("participant_id", "")).strip()
    if not participant_id:
        return _error(ValueError("participant_id is required"))
    session = research_evidence.start_session(
        participant_id=participant_id,
        study_id=payload.get("study_id"),
        app_version=payload.get("app_version"),
        metadata=dict(payload.get("metadata", {})),
    )
    return {"accepted": True, "session": session.to_dict(), "collection_enabled": research_evidence.enabled}


@router.post("/consent")
async def record_consent(payload: dict[str, Any]):
    participant_id = str(payload.get("participant_id", "")).strip()
    version = str(payload.get("consent_version", "")).strip()
    if not participant_id or not version:
        return _error(ValueError("participant_id and consent_version are required"))
    consent = ResearchConsent(
        participant_id=participant_id,
        consent_version=version,
        usage_analytics=bool(payload.get("usage_analytics", False)),
        interaction_research=bool(payload.get("interaction_research", False)),
        feedback_research=bool(payload.get("feedback_research", False)),
        follow_up_contact=bool(payload.get("follow_up_contact", False)),
        recorded_interview=bool(payload.get("recorded_interview", False)),
        recorded_at=str(payload.get("recorded_at") or datetime.now(timezone.utc).isoformat()),
    )
    research_evidence.register_consent(consent)
    return {"accepted": True, "consent": consent.to_dict(), "collection_enabled": research_evidence.enabled}



@router.post("/attach-work/{work_id}")
async def attach_work(work_id: str, payload: dict[str, Any]):
    try:
        return {"accepted": True, "work": residence_work.attach_research_session(work_id, session_id=str(payload.get("session_id", "")), participant_id=str(payload.get("participant_id", "")))}
    except (KeyError, ValueError) as exc:
        return _error(exc)

@router.get("/summary")
async def summary(x_research_admin_token: str | None = None):
    try:
        _admin(x_research_admin_token)
        return {"accepted": True, "enabled": research_evidence.enabled, "counts": research_evidence.repository.counts()}
    except PermissionError as exc:
        return _error(exc, 403)


@router.get("/sessions")
async def sessions(x_research_admin_token: str | None = None, limit: int = 100):
    try:
        _admin(x_research_admin_token)
        return {"accepted": True, "sessions": research_evidence.repository.list_sessions(limit)}
    except PermissionError as exc:
        return _error(exc, 403)


@router.get("/events")
async def events(x_research_admin_token: str | None = None, session_id: str | None = None, limit: int = 500):
    try:
        _admin(x_research_admin_token)
        return {"accepted": True, "events": research_evidence.repository.list_events(session_id, limit)}
    except PermissionError as exc:
        return _error(exc, 403)


@router.get("/export.json")
async def export_json(x_research_admin_token: str | None = None):
    try:
        _admin(x_research_admin_token)
        return JSONResponse(content=json.loads(build_json_export(research_evidence.repository)))
    except PermissionError as exc:
        return _error(exc, 403)


@router.get("/export.csv.zip")
async def export_csv(x_research_admin_token: str | None = None):
    try:
        _admin(x_research_admin_token)
        return Response(
            content=build_csv_bundle(research_evidence.repository),
            media_type="application/zip",
            headers={"Content-Disposition": "attachment; filename=criterivox-research-export.zip"},
        )
    except PermissionError as exc:
        return _error(exc, 403)
