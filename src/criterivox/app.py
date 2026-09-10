"""Criterivox application entry point and S5 stewardship runtime boundary."""

import asyncio
import logging

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from .config import settings
from .domain.analysis import AnalysisTaskSource
from .domain.characters import CharacterState
from .application.analysis_tasks import analysis_tasks
from .application.data_foundation_store import data_foundations
from .application.sandre_stewardship import SandreStewardship
from .application import foundation_runtime_bridge  # noqa: F401
from .infrastructure.runtime import dharen_runtime, handle_application_request, handle_chat_message, parse_analysis_request, runtime_connections
from .logging_config import configure_logging
from .presentation.contract import PresentationContract
from .ui.routes import router

logger = logging.getLogger(__name__)
app = FastAPI(title="Criterivox")
app.mount("/static", StaticFiles(directory="src/criterivox/ui/static"), name="static")
stewardship = SandreStewardship()

@app.get("/health")
def health() -> JSONResponse:
    return JSONResponse({"service": "criterivox", "status": "ready", "runtime": "python"})

app.include_router(router)

async def _safe_request(handler, payload: dict) -> None:
    try:
        await handler(payload)
    except Exception as exc:
        logger.exception("Runtime request failed.")
        await runtime_connections.publish(PresentationContract.from_state("Dharen", CharacterState.WARNING, active=True, prominence=.85, message=f"Runtime could not complete that request: {exc}", event="RUNTIME_ERROR"))

async def _publish_foundation_state(character: str, state: CharacterState, message: str, event: str, foundation, *, preview=None, recipient=None, conflict_fields=(), log_count=None, log_entries=(), conditional_provenance=()) -> None:
    kwargs = dict(foundation_id=foundation.foundation_id, foundation_material_set_id=foundation.foundation_id, foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates), foundation_confirmation=foundation.confirmation_status.value, foundation_recipient=recipient, foundation_log_count=len(stewardship.logs) if log_count is None else log_count, foundation_log_entries=tuple(log_entries), foundation_conflict_fields=tuple(conflict_fields), foundation_conditional_provenance=tuple(conditional_provenance))
    if preview is not None:
        kwargs.update(foundation_preview_question=preview.question, foundation_match_ratio=preview.schema_preflight.match_ratio if preview.schema_preflight else None, foundation_auto_fill=preview.schema_preflight.auto_fill if preview.schema_preflight else False, foundation_intent_guesses=tuple(item.label for item in preview.intent_guesses))
    await runtime_connections.publish(PresentationContract.from_state(character, state, active=True, prominence=.9, message=message, event=event, **kwargs))

async def _safe_data_intake(payload: dict) -> None:
    try:
        foundation = data_foundations.ingest_folder(payload) if payload.get("folder_path") else data_foundations.ingest(payload)
        task_ids = tuple(str(v) for v in payload.get("recent_task_ids", ()) if str(v).strip()) if isinstance(payload.get("recent_task_ids", ()), (list, tuple)) else ()
        prompts = tuple(str(v) for v in payload.get("prompt_history", ()) if str(v).strip()) if isinstance(payload.get("prompt_history", ()), (list, tuple)) else ()
        first = foundation.sources[0] if foundation.sources else None
        guesses = stewardship.predict_intent(source_name=first.name if first else "material", source_type=first.source_type.value if first else "unknown", recent_task_ids=task_ids, prompt_history=prompts)
        preview = stewardship.preview(foundation, intent_guesses=guesses)
        stewardship.record(foundation, task_ids=task_ids, event="MATERIAL_RECEIVED", detail=f"{len(foundation.sources)} source(s) received; {len(foundation.candidates)} candidate(s) extracted.")
        await _publish_foundation_state("sandre", CharacterState.RECEIVE, f"Received {len(foundation.sources)} source(s). Python preserved the selected material before extraction.", "MATERIAL_RECEIVED", foundation, preview=preview)
        await asyncio.sleep(.12)
        await _publish_foundation_state("sandre", CharacterState.WORK, f"Extracted {len(foundation.candidates)} candidate item(s) with source lineage preserved.", "EXTRACTION_COMPLETED", foundation, preview=preview)
        await asyncio.sleep(.12)
        message = f"What is this material, and why are you providing it? Sandre could not establish the required schema match automatically ({preview.schema_preflight.match_ratio:.0%})." if preview.schema_preflight and preview.schema_preflight.requires_clarification else f"Preview ready. {preview.question} Top inferred purpose: {preview.intent_guesses[0].label if preview.intent_guesses else 'unclassified'}."
        await _publish_foundation_state("sandre", CharacterState.COMMUNICATE, message, "USER_CONFIRMATION_REQUIRED", foundation, preview=preview)
    except Exception as exc:
        logger.exception("S5 data intake failed.")
        await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.WARNING, active=True, prominence=.9, message=f"Data intake could not be completed: {exc}", event="EXTRACTION_FAILED"))

async def _safe_data_action(payload: dict) -> None:
    try:
        foundation_id = str(payload.get("foundation_id", ""))
        action = str(payload.get("action", "")).strip().lower()
        if action in {"confirm", "correct", "exclude", "add", "irrelevant", "clarify"}:
            foundation = data_foundations.confirm(foundation_id, action, tuple(payload.get("candidate_ids", ())))
            stewardship.record(foundation, event=f"USER_INFORMATION_{action.upper()}", detail="User review recorded; source remains preserved.")
            await _publish_foundation_state("sandre", CharacterState.COMMUNICATE, f"Recorded user review as {foundation.confirmation_status.value}. The source remains preserved.", f"USER_INFORMATION_{action.upper()}", foundation, preview=stewardship.preview(foundation))
            return
        if action == "approve_intent":
            foundation = data_foundations.get(foundation_id)
            label = stewardship.approve_intent(foundation_id, str(payload.get("intent", "")), payload.get("allowed_intents", ()))
            stewardship.record(foundation, event="INTENT_APPROVED", detail=f"User approved inferred purpose: {label}.")
            await _publish_foundation_state("sandre", CharacterState.COMMUNICATE, f"Recorded your intent as {label}. The heuristic remains a user-approved routing hint, not a research finding.", "INTENT_APPROVED", foundation, preview=stewardship.preview(foundation))
            return
        if action == "provenance_choices":
            foundation = data_foundations.get(foundation_id)
            choices = payload.get("choices")
            if not isinstance(choices, dict):
                raise ValueError("Conditional provenance choices must be an object of Yes/No values.")
            stored = stewardship.set_conditional_provenance(foundation_id, {str(k): bool(v) for k, v in choices.items()})
            stewardship.record(foundation, event="PROVENANCE_CHOICES_RECORDED", detail=f"User explicitly selected {len(stored)} conditional provenance option(s).")
            enabled = tuple(key for key, value in stored.items() if value)
            await _publish_foundation_state("sandre", CharacterState.COMPLETE, f"Recorded {len(stored)} conditional provenance choice(s). Retained: {', '.join(enabled) if enabled else 'none'}.", "PROVENANCE_CHOICES_RECORDED", foundation, conditional_provenance=enabled)
            return
        if action == "handoff":
            recipient = stewardship.route(str(payload.get("recipient", "dharen")))
            foundation = data_foundations.get(foundation_id)
            if not stewardship.can_handoff(foundation):
                raise ValueError("User confirmation is required before downstream handoff.")
            handoff = data_foundations.handoff(foundation_id, recipient)
            stewardship.record(foundation, recipient=recipient, event="SANDRE_HANDOFF_READY", detail=f"Routed curated foundation to {recipient}.")
            await _publish_foundation_state("sandre", CharacterState.HANDOFF, f"Safeguarded foundation {handoff.foundation_id} is ready for {recipient}.", "SANDRE_HANDOFF_READY", foundation, recipient=recipient)
            if recipient == "dharen":
                task = analysis_tasks.create_task(task="Analyze the curated S5 foundation in its supplied research context.", data={"foundation_id": foundation.foundation_id, "canonical_rows": len(foundation.canonical_data)}, context=foundation.supplied_context, source=AnalysisTaskSource.BLOOM, references=tuple(s.source_id for s in foundation.sources), data_foundation=foundation)
                stewardship.record(foundation, task_ids=(task.task_id,), recipient=recipient, event="DHAREN_HANDOFF_READY", detail="Created downstream AnalysisTask from the confirmed foundation.")
                await asyncio.sleep(.15)
                await dharen_runtime.publish_task(task, message="Dharen received the curated S5 foundation from Sandre.", event="DHAREN_HANDOFF_READY")
                asyncio.create_task(analysis_tasks.execute(task.task_id))
            elif recipient == "syvax":
                await runtime_connections.publish(PresentationContract.from_state("syvax", CharacterState.RECEIVE, active=True, prominence=.85, message="Syvax received a Sandre-routed foundation for direct user confirmation.", event="SANDRE_ROUTED_TO_SYVAX", foundation_id=foundation.foundation_id, foundation_material_set_id=foundation.foundation_id, foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates), foundation_confirmation=foundation.confirmation_status.value, foundation_recipient="syvax", foundation_log_count=len(stewardship.logs)))
            else:
                await runtime_connections.publish(PresentationContract.from_state("kaelen", CharacterState.RECEIVE, active=True, prominence=.85, message="Kaelen received the safeguarded S5 handoff package.", event="SANDRE_ROUTED_TO_KAELEN", foundation_id=foundation.foundation_id, foundation_material_set_id=foundation.foundation_id, foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates), foundation_confirmation=foundation.confirmation_status.value, foundation_recipient="kaelen", foundation_log_count=len(stewardship.logs)))
            return
        if action == "log_search":
            entries = stewardship.search_logs(str(payload.get("query", "")))
            latest = data_foundations.get(foundation_id) if foundation_id else None
            if latest:
                formatted = tuple(f"{entry.timestamp} • {entry.event} • {entry.material_set_id} • tasks={','.join(entry.task_ids) or 'none'} • {entry.detail}" for entry in entries[:20])
                await _publish_foundation_state("sandre", CharacterState.COMMUNICATE, f"Found {len(entries)} stewardship log record(s).", "STEWARD_LOG_SEARCH", latest, log_count=len(entries), log_entries=formatted)
            return
        if action == "merge_conflicts":
            home, chat, winners = payload.get("home"), payload.get("chat"), payload.get("winners")
            if not isinstance(home, dict) or not isinstance(chat, dict) or not isinstance(winners, dict):
                raise ValueError("Conflict merge requires home, chat, and per-field winners objects.")
            merged, resolutions = stewardship.merge_conflicts(home, chat, {str(k): str(v) for k, v in winners.items()})
            foundation = data_foundations.get(foundation_id)
            fields = tuple(item.field for item in resolutions)
            stewardship.record(foundation, event="CONFLICTS_RESOLVED", detail=f"Resolved {len(resolutions)} field conflict(s) explicitly.")
            await _publish_foundation_state("sandre", CharacterState.COMPLETE, f"Merged {len(resolutions)} conflicting field(s) using explicit user choices. No hard overwrite was applied.", "CONFLICTS_RESOLVED", foundation, conflict_fields=fields, log_entries=tuple(f"{k}: {v!r}" for k, v in merged.items()))
            return
        raise ValueError("Unsupported S5 data action.")
    except Exception as exc:
        logger.exception("S5 data action failed.")
        await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.WARNING, active=True, prominence=.9, message=f"Sandre could not complete that stewardship action: {exc}", event="DATA_ACTION_FAILED"))

@app.websocket("/runtime/characters")
async def character_runtime(websocket: WebSocket) -> None:
    await runtime_connections.connect(websocket)
    try:
        while True:
            payload = await websocket.receive_json()
            if isinstance(payload, dict) and payload.get("type") == "chat_message":
                asyncio.create_task(_safe_request(handle_chat_message, payload))
            elif isinstance(payload, dict) and payload.get("type") in {"data_intake", "data_folder"}:
                asyncio.create_task(_safe_data_intake(payload))
            elif isinstance(payload, dict) and payload.get("type") == "data_action":
                asyncio.create_task(_safe_data_action(payload))
            elif isinstance(payload, dict) and "intent" in payload:
                asyncio.create_task(_safe_request(handle_application_request, payload))
            else:
                request = parse_analysis_request(payload)
                asyncio.create_task(dharen_runtime.run_analysis(request))
    except WebSocketDisconnect:
        runtime_connections.disconnect(websocket)
    except (ValueError, TypeError):
        await websocket.close(code=1003, reason="Invalid runtime payload")
        runtime_connections.disconnect(websocket)
    except Exception:
        logger.exception("Character runtime connection failed.")
        runtime_connections.disconnect(websocket)

def main() -> None:
    configure_logging()
    logger.info("Criterivox application starting in %s mode.", settings.environment)

if __name__ == "__main__":
    main()
