"""Criterivox application entry point and S6 context runtime boundary."""

import asyncio
import hashlib
import json
import logging

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from .config import settings
from .domain.analysis import AnalysisTaskSource
from .domain.characters import CharacterState
from .domain.context_intelligence import ObservabilityTimeline
from .application.analysis_tasks import analysis_tasks
from .application.character_chat import PROFILES, handle_character_chat, sign_off_task_scratchpad
from .application.context_engine import ContextEngine
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
context_engine = ContextEngine()
observability = ObservabilityTimeline()
_context_snapshots: dict[str, dict[str, object]] = {}

@app.get("/health")
def health() -> JSONResponse:
    return JSONResponse({"service": "criterivox", "status": "ready", "runtime": "python", "s6_context_engine": "active"})

app.include_router(router)

async def _safe_request(handler, payload: dict) -> None:
    try:
        await handler(payload)
    except Exception as exc:
        logger.exception("Runtime request failed.")
        await runtime_connections.publish(PresentationContract.from_state("dharen", CharacterState.WARNING, active=True, prominence=.85, message=f"Runtime could not complete that request: {exc}", event="RUNTIME_ERROR"))

def _graph_payload(graph) -> dict:
    return {"nodes": [{"id": node.node_id, "label": node.label, "kind": node.kind} for node in graph.nodes], "edges": [{"source": edge.source, "target": edge.target, "relation": edge.relation} for edge in graph.edges], "traceability_status": "IMPLEMENTED", "immutability_status": "UNKNOWN"}

def _diff_payload(diff) -> dict:
    return {"added": list(diff.added_dimensions), "removed": list(diff.removed_dimensions), "unchanged": list(diff.unchanged_dimensions), "changed": list(diff.changed_fields), "semantic_equivalence_claimed": False}

async def _safe_context_build(payload: dict) -> None:
    try:
        foundation_id = str(payload.get("foundation_id", "")).strip()
        if not foundation_id: raise ValueError("A validated S5 foundation identifier is required.")
        foundation = data_foundations.get(foundation_id)
        supplied = payload.get("user_intent_context", {})
        if not isinstance(supplied, dict): raise ValueError("user_intent_context must be an object.")
        previous_context = _context_snapshots.get(foundation_id)
        memory_seconds_value = supplied.get("memory_recheck_seconds")
        memory_seconds = int(memory_seconds_value) if memory_seconds_value is not None else None
        memory_reason = str(supplied.get("memory_recheck_reason", "")).strip() or None
        result = context_engine.create_from_material_set(foundation, user_intent_context=supplied, previous_context=previous_context, memory_recheck_seconds=memory_seconds, memory_recheck_reason=memory_reason)
        context = result.context; lineage = context.lineage; dimensions = tuple(sorted({item.dimension.value for item in context.items})); missing = tuple(d.value for d in context.missing_dimensions()); baseline = result.baselines[0]; task_id = str(payload.get("task_id", f"CTX-TASK-{foundation_id}")); _context_snapshots[foundation_id] = {item.key: item.value for item in context.items}; events = []
        def trace(action: str, reason: str, *, output: str | None = None) -> None: events.append(observability.record(task_id=task_id, character_id="dharen", action=action, reason=reason, context_id=context.context_id, output=output))
        trace("RECEIVE", "Received validated S5 foundation for contextual structuring.")
        common = {"foundation_id": foundation_id, "foundation_material_set_id": foundation_id, "task_id": task_id, "context_id": context.context_id, "context_dimensions": dimensions, "context_missing_dimensions": missing, "context_normalization_count": len(result.normalization), "context_baseline_id": baseline.baseline_id, "context_baseline_status": baseline.status.value, "provenance_graph": _graph_payload(result.provenance_graph), "context_diff": _diff_payload(result.context_diff), "evidence_completeness": result.evidence_debt.completeness_percent, "evidence_debt_level": result.evidence_debt.level.value, "evidence_tags": result.evidence_debt.tags, "memory_status": result.memory.status, "memory_recheck_at": result.memory.expires_at.isoformat() if result.memory.expires_at else None, "memory_recheck_reason": memory_reason, "observability_events": tuple(item.to_dict() for item in events), "activity": tuple(f"{item.character_id}: {item.action} • {item.reason}" for item in events), "lineage_snapshot": {"material_set_id": lineage.material_set_id if lineage else None, "created_at": lineage.created_at if lineage else None, "source_ids": list(lineage.source_ids) if lineage else [], "immutable": lineage.immutable if lineage else False}}
        await runtime_connections.publish(PresentationContract.from_state("dharen", CharacterState.RECEIVE, active=True, prominence=.9, message=f"Dharen received foundation {foundation_id} for contextual structuring.", event="CONTEXT_BUILD_RECEIVED", **common)); await asyncio.sleep(.1); trace("WORK", "Structured dimensions while preserving S5 lineage."); common["observability_events"] = tuple(item.to_dict() for item in events); common["activity"] = tuple(f"{item.character_id}: {item.action} • {item.reason}" for item in events); await runtime_connections.publish(PresentationContract.from_state("dharen", CharacterState.WORK, active=True, prominence=.9, message="Dharen is structuring contextual dimensions and preserving the S5 lineage reference.", event="CONTEXT_BUILD_WORKING", **common)); await asyncio.sleep(.1); trace("COMMUNICATE", "Context build completed and is ready for inspection.", output=result.interpretation.interpretation); common.update({"context_interpretation_id": result.interpretation.interpretation_id, "context_uncertainty": result.interpretation.uncertainty, "context_limitations": result.interpretation.limitations, "observability_events": tuple(item.to_dict() for item in events), "activity": tuple(f"{item.character_id}: {item.action} • {item.reason}" for item in events)}); await runtime_connections.publish(PresentationContract.from_state("dharen", CharacterState.COMMUNICATE, active=True, prominence=.9, message=result.interpretation.interpretation, event="CONTEXT_BUILD_COMPLETE", **common))
    except Exception as exc:
        logger.exception("S6 context build failed."); await runtime_connections.publish(PresentationContract.from_state("dharen", CharacterState.WARNING, active=True, prominence=.9, message=f"Context construction could not be completed: {exc}", event="CONTEXT_BUILD_FAILED"))

async def _foundation_sync(payload: dict) -> dict:
    if not isinstance(payload, dict): raise ValueError("Foundation synchronization payload must be an object.")
    envelope = dict(payload); envelope.pop("type", None); foundation = data_foundations.restore_replace(envelope, authoritative=True); serialized = data_foundations.serialize(foundation.foundation_id); payload_hash = hashlib.sha256(json.dumps(serialized["foundation"], default=str, sort_keys=True, separators=(",", ":")).encode()).hexdigest(); return {"type": "foundation_sync_ack", "foundation_id": foundation.foundation_id, "revision": data_foundations.revision(foundation.foundation_id), "status": "accepted", "payload_hash": payload_hash, "authoritative": True}

async def _safe_foundation_sync(payload: dict) -> None:
    try:
        ack = await _foundation_sync(payload)
        await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.RECEIVE, active=True, prominence=.88, message=f"Browser foundation {ack['foundation_id']} was restored as the authoritative S5 copy.", event="FOUNDATION_SYNC_ACCEPTED", foundation_id=ack["foundation_id"], foundation_revision=ack["revision"], foundation_payload_hash=ack["payload_hash"], foundation_authoritative=True))
        foundation = data_foundations.get(ack["foundation_id"])
        if foundation.confirmation_status.value in {"user-confirmed", "user-corrected"} and foundation.handoff_ready:
            task = analysis_tasks.create_task(task="Resume the curated S5 foundation after browser recovery.", data={"foundation_id": foundation.foundation_id, "canonical_rows": len(foundation.canonical_data)}, context=foundation.supplied_context, source=AnalysisTaskSource.BLOOM, references=tuple(s.source_id for s in foundation.sources), data_foundation=foundation)
            await runtime_connections.publish(PresentationContract.from_state("dharen", CharacterState.RECEIVE, active=True, prominence=.95, message="Dharen is rehydrating S6 context from the recovered browser-resident foundation.", event="S6_FOUNDATION_RECOVERY_HANDOFF", foundation_id=foundation.foundation_id, task_id=task.task_id, foundation_revision=ack["revision"]))
            asyncio.create_task(dharen_runtime.publish_task(task, message="Dharen resumed the recovered browser foundation.", event="S6_FOUNDATION_RECOVERY_HANDOFF"))
        else:
            await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.COMMUNICATE, active=True, prominence=.82, message="Browser foundation restored. User confirmation/handoff state is preserved; downstream S6 activation remains gated until the foundation is ready.", event="FOUNDATION_SYNC_RESTORED", foundation_id=foundation.foundation_id, foundation_revision=ack["revision"], foundation_confirmation=foundation.confirmation_status.value, foundation_handoff_ready=foundation.handoff_ready))
    except ValueError as exc:
        await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.WARNING, active=True, prominence=.88, message=f"Browser foundation recovery was rejected: {exc}", event="FOUNDATION_SYNC_REJECTED", foundation_id=payload.get("foundation_id"), foundation_revision=payload.get("revision"), foundation_authoritative=False)); raise

foundation_sync = _foundation_sync

async def _publish_foundation_state(character: str, state: CharacterState, message: str, event: str, foundation, *, preview=None, recipient=None, conflict_fields=(), log_count=None, log_entries=(), conditional_provenance=()) -> None:
    raw = {"message_type": "foundation_state", "schema_version": 1, "foundation_id": foundation.foundation_id, "revision": data_foundations.revision(foundation.foundation_id), "foundation": foundation.to_dict(), "event": event}
    await _publish_raw(raw)
    kwargs = dict(foundation_id=foundation.foundation_id, foundation_material_set_id=foundation.foundation_id, foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates), foundation_confirmation=foundation.confirmation_status.value, foundation_recipient=recipient, foundation_log_count=len(stewardship.logs) if log_count is None else log_count, foundation_log_entries=tuple(log_entries), foundation_conflict_fields=tuple(conflict_fields), foundation_conditional_provenance=tuple(conditional_provenance))
    if preview is not None: kwargs.update(foundation_preview_question=preview.question, foundation_match_ratio=preview.schema_preflight.match_ratio if preview.schema_preflight else None, foundation_auto_fill=preview.schema_preflight.auto_fill if preview.schema_preflight else False, foundation_intent_guesses=tuple(item.label for item in preview.intent_guesses))
    await runtime_connections.publish(PresentationContract.from_state(character, state, active=True, prominence=.9, message=message, event=event, **kwargs))

async def _publish_raw(payload: dict) -> None:
    message = json.dumps(payload, default=str); dead = []
    for client in tuple(runtime_connections.clients):
        try: await client.send_text(message)
        except Exception: dead.append(client)
    for client in dead: runtime_connections.disconnect(client)

async def _safe_data_intake(payload: dict) -> None:
    try:
        foundation = data_foundations.ingest_folder(payload) if payload.get("folder_path") else data_foundations.ingest(payload)
        task_ids = tuple(str(v) for v in payload.get("recent_task_ids", ()) if str(v).strip()) if isinstance(payload.get("recent_task_ids", ()), (list, tuple)) else (); prompts = tuple(str(v) for v in payload.get("prompt_history", ()) if str(v).strip()) if isinstance(payload.get("prompt_history", ()), (list, tuple)) else (); first = foundation.sources[0] if foundation.sources else None; guesses = stewardship.predict_intent(source_name=first.name if first else "material", source_type=first.source_type.value if first else "unknown", recent_task_ids=task_ids, prompt_history=prompts); preview = stewardship.preview(foundation, intent_guesses=guesses); stewardship.record(foundation, task_ids=task_ids, event="MATERIAL_RECEIVED", detail=f"{len(foundation.sources)} source(s) received; {len(foundation.candidates)} candidate(s) extracted."); await _publish_foundation_state("sandre", CharacterState.RECEIVE, f"Received {len(foundation.sources)} source(s). Python preserved the selected material before extraction.", "MATERIAL_RECEIVED", foundation, preview=preview); await asyncio.sleep(.12); await _publish_foundation_state("sandre", CharacterState.WORK, f"Extracted {len(foundation.candidates)} candidate item(s) with source lineage preserved.", "EXTRACTION_COMPLETED", foundation, preview=preview); await asyncio.sleep(.12); message = f"What is this material, and why are you providing it? Sandre could not establish the required schema match automatically ({preview.schema_preflight.match_ratio:.0%})." if preview.schema_preflight and preview.schema_preflight.requires_clarification else f"Preview ready. {preview.question} Top inferred purpose: {preview.intent_guesses[0].label if preview.intent_guesses else 'unclassified'}."; await _publish_foundation_state("sandre", CharacterState.COMMUNICATE, message, "USER_CONFIRMATION_REQUIRED", foundation, preview=preview)
    except Exception as exc:
        logger.exception("S5 data intake failed."); await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.WARNING, active=True, prominence=.9, message=f"Data intake could not be completed: {exc}", event="EXTRACTION_FAILED"))

async def _safe_data_action(payload: dict) -> None:
    try:
        foundation_id = str(payload.get("foundation_id", "")); action = str(payload.get("action", "")).strip().lower()
        if action in {"confirm", "correct", "exclude", "add", "irrelevant", "clarify"}:
            foundation = data_foundations.confirm(foundation_id, action, tuple(payload.get("candidate_ids", ()))); stewardship.record(foundation, event=f"USER_INFORMATION_{action.upper()}", detail="User review recorded; source remains preserved."); await _publish_foundation_state("sandre", CharacterState.COMMUNICATE, f"Recorded user review as {foundation.confirmation_status.value}. The source remains preserved.", f"USER_INFORMATION_{action.upper()}", foundation, preview=stewardship.preview(foundation)); return
        if action == "approve_intent":
            foundation = data_foundations.get(foundation_id); label = stewardship.approve_intent(foundation_id, str(payload.get("intent", "")), payload.get("allowed_intents", ())); stewardship.record(foundation, event="INTENT_APPROVED", detail=f"User approved inferred purpose: {label}."); await _publish_foundation_state("sandre", CharacterState.COMMUNICATE, f"Recorded your intent as {label}. The heuristic remains a user-approved routing hint, not a research finding.", "INTENT_APPROVED", foundation, preview=stewardship.preview(foundation)); return
        if action == "provenance_choices":
            foundation = data_foundations.get(foundation_id); choices = payload.get("choices");
            if not isinstance(choices, dict): raise ValueError("Conditional provenance choices must be an object of Yes/No values.")
            stored = stewardship.set_conditional_provenance(foundation_id, {str(k): bool(v) for k, v in choices.items()}); stewardship.record(foundation, event="PROVENANCE_CHOICES_RECORDED", detail=f"User explicitly selected {len(stored)} conditional provenance option(s)."); enabled = tuple(key for key, value in stored.items() if value); await _publish_foundation_state("sandre", CharacterState.COMPLETE, f"Recorded {len(stored)} conditional provenance choice(s). Retained: {', '.join(enabled) if enabled else 'none'}.", "PROVENANCE_CHOICES_RECORDED", foundation, conditional_provenance=enabled); return
        if action == "handoff":
            recipient = stewardship.route(str(payload.get("recipient", "dharen"))); foundation = data_foundations.get(foundation_id)
            if not stewardship.can_handoff(foundation): raise ValueError("User confirmation is required before downstream handoff.")
            handoff = data_foundations.handoff(foundation_id, recipient); stewardship.record(foundation, recipient=recipient, event="SANDRE_HANDOFF_READY", detail=f"Routed curated foundation to {recipient}."); await _publish_foundation_state("sandre", CharacterState.HANDOFF, f"Safeguarded foundation {handoff.foundation_id} is ready for {recipient}.", "SANDRE_HANDOFF_READY", foundation, recipient=recipient)
            if recipient == "dharen":
                task = analysis_tasks.create_task(task="Analyze the curated S5 foundation in its supplied research context.", data={"foundation_id": foundation.foundation_id, "canonical_rows": len(foundation.canonical_data)}, context=foundation.supplied_context, source=AnalysisTaskSource.BLOOM, references=tuple(s.source_id for s in foundation.sources), data_foundation=foundation); stewardship.record(foundation, task_ids=(task.task_id,), recipient=recipient, event="DHAREN_HANDOFF_READY", detail="Created downstream AnalysisTask from the confirmed foundation."); await asyncio.sleep(.15); await dharen_runtime.publish_task(task, message="Dharen received the curated S5 foundation from Sandre.", event="DHAREN_HANDOFF_READY"); asyncio.create_task(analysis_tasks.execute(task.task_id))
            elif recipient == "syvax": await runtime_connections.publish(PresentationContract.from_state("syvax", CharacterState.RECEIVE, active=True, prominence=.85, message="Syvax received a Sandre-routed foundation for direct user confirmation.", event="SANDRE_ROUTED_TO_SYVAX", foundation_id=foundation.foundation_id, foundation_material_set_id=foundation.foundation_id, foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates), foundation_confirmation=foundation.confirmation_status.value, foundation_recipient="syvax", foundation_log_count=len(stewardship.logs)))
            else: await runtime_connections.publish(PresentationContract.from_state("kaelen", CharacterState.RECEIVE, active=True, prominence=.85, message="Kaelen received the safeguarded S5 handoff package.", event="SANDRE_ROUTED_TO_KAELEN", foundation_id=foundation.foundation_id, foundation_material_set_id=foundation.foundation_id, foundation_source_count=len(foundation.sources), foundation_candidate_count=len(foundation.candidates), foundation_confirmation=foundation.confirmation_status.value, foundation_recipient="kaelen", foundation_log_count=len(stewardship.logs)))
            return
        raise ValueError(f"Unsupported data action: {action}")
    except Exception as exc:
        logger.exception("S5 data action failed."); await runtime_connections.publish(PresentationContract.from_state("sandre", CharacterState.WARNING, active=True, prominence=.9, message=f"Data action could not be completed: {exc}", event="DATA_ACTION_FAILED"))

@app.websocket("/runtime/characters")
async def character_runtime(websocket: WebSocket) -> None:
    await runtime_connections.connect(websocket)
    try:
        while True:
            payload = await websocket.receive_json()
            if isinstance(payload, dict) and payload.get("type") == "foundation_sync":
                try:
                    await websocket.send_json(await _foundation_sync(payload)); await _safe_foundation_sync(payload)
                except ValueError as exc:
                    await websocket.send_json({"type": "foundation_sync_ack", "foundation_id": payload.get("foundation_id"), "revision": payload.get("revision", 0), "status": "rejected", "reason": str(exc), "authoritative": False})
            elif isinstance(payload, dict) and payload.get("type") == "chat_message": asyncio.create_task(_safe_request(handle_chat_message, payload))
            elif isinstance(payload, dict) and payload.get("type") in {"data_intake", "data_folder"}: asyncio.create_task(_safe_data_intake(payload))
            elif isinstance(payload, dict) and payload.get("type") == "data_action": asyncio.create_task(_safe_data_action(payload))
            elif isinstance(payload, dict) and payload.get("type") == "context_build": asyncio.create_task(_safe_context_build(payload))
            elif isinstance(payload, dict) and "intent" in payload: asyncio.create_task(_safe_request(handle_application_request, payload))
            else: asyncio.create_task(_safe_request(dharen_runtime.run_analysis, parse_analysis_request(payload)))
    except WebSocketDisconnect: runtime_connections.disconnect(websocket)
    except (ValueError, TypeError): await websocket.close(code=1003, reason="Invalid runtime payload"); runtime_connections.disconnect(websocket)
    except Exception: logger.exception("Character runtime connection failed."); runtime_connections.disconnect(websocket)

def main() -> None:
    configure_logging(); logger.info("Criterivox application starting in %s mode.", settings.environment)

if __name__ == "__main__": main()
