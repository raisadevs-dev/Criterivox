
from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Iterable, Mapping
from uuid import uuid4

from criterivox.application.home03_store import home03_store
from criterivox.domain.state_awareness import (
    Checkpoint,
    ExecutionEvent,
    Journey,
    NextType,
    SituationAwarenessResponse,
    SituationLevel,
    TruthClass,
)


def now() -> str:
    """Return an authoritative UTC timestamp."""
    return datetime.now(timezone.utc).isoformat()


class StateRuntime:
    """
    Runtime service for authoritative state-awareness information.

    Important guarantees:
    - does not fabricate a current state without a checkpoint
    - does not fabricate history without recorded events
    - does not project a future step as completed
    - resolves a conversation only when exactly one journey is present
    - treats multiple active journeys as ambiguous
    - derives "next" only from recorded remaining_steps
    """

    def __init__(self, store=home03_store):
        self.store = store

    # ------------------------------------------------------------------
    # Journey lifecycle
    # ------------------------------------------------------------------

    def ensure_journey(
        self,
        task_id: str,
        goal: str,
        conversation_id: str | None = None,
    ) -> Journey:
        """
        Return the existing journey for task_id, or create one.

        Existing authoritative state always wins over newly supplied values.
        """
        existing = self.store.get_state_journey_by_task(task_id)

        if existing:
            return Journey(**existing)

        timestamp = now()

        journey_id = f"J-{uuid4().hex[:10].upper()}"
        conversation_id = (
            conversation_id
            or f"C-{uuid4().hex[:10].upper()}"
        )

        row = {
            "journey_id": journey_id,
            "conversation_id": conversation_id,
            "task_id": task_id,
            "goal": goal,
            "status": "CREATED",
            "created_at": timestamp,
            "updated_at": timestamp,
            "context_reference": None,
        }

        self.store.state_journey(row)

        return Journey(**row)

    def update_journey(
        self,
        task_id: str,
        **fields: Any,
    ) -> None:
        """
        Update only explicitly supplied journey fields.

        The store is responsible for filtering fields that are not part of
        the durable journey schema.
        """
        if not fields:
            return

        self.store.update_state_journey(
            task_id,
            fields,
        )

    # ------------------------------------------------------------------
    # Event recording
    # ------------------------------------------------------------------

    def record_event(
        self,
        task_id: str,
        event_type: str,
        actor: str = "system",
        capability: str | None = None,
        previous_state: str | None = None,
        new_state: str | None = None,
        caused_by: str | None = None,
        parent_event: str | None = None,
        input_refs: Iterable[str] = (),
        output_refs: Iterable[str] = (),
        status: str = "RECORDED",
        provenance: Mapping[str, Any] | None = None,
    ) -> ExecutionEvent:
        """
        Record an authoritative execution/state event.

        If the task has no journey yet, a journey is created. This is a
        durable runtime operation, not an inference of task completion.
        """
        journey = self.ensure_journey(
            task_id=task_id,
            goal="",
        )

        timestamp = now()

        event = {
            "event_id": f"EV-{uuid4().hex[:12].upper()}",
            "journey_id": journey.journey_id,
            "task_id": task_id,
            "timestamp": timestamp,
            "event_type": event_type,
            "actor": actor,
            "capability": capability,
            "input_refs": list(input_refs),
            "output_refs": list(output_refs),
            "previous_state": previous_state,
            "new_state": new_state,
            "caused_by": caused_by,
            "parent_event": parent_event,
            "status": status,
            "provenance": dict(provenance or {}),
        }

        self.store.state_event(event)

        # A recorded event may advance durable journey status only when
        # new_state was explicitly supplied. Never infer a state transition.
        if new_state is not None:
            journey_status = new_state
        else:
            journey_status = journey.status

        self.store.update_state_journey(
            task_id,
            {
                "status": journey_status,
                "updated_at": timestamp,
            },
        )

        return ExecutionEvent(**event)

    # ------------------------------------------------------------------
    # Checkpoints
    # ------------------------------------------------------------------

    def checkpoint(
        self,
        task_id: str,
        current_step: str | None,
        active_step: str | None,
        completed_steps: Iterable[str] = (),
        remaining_steps: Iterable[str] = (),
        active_character: str | None = None,
        active_capability: str | None = None,
        state: str = "UNKNOWN",
        blocked_reason: str | None = None,
        waiting_for: str | None = None,
        context_version: int = 0,
        artifact_refs: Iterable[str] = (),
        event_refs: Iterable[str] = (),
    ) -> Checkpoint:
        """
        Persist an authoritative state checkpoint.

        `remaining_steps` is the only source used by `situation(..., NEXT)`
        to identify the recorded next step.
        """
        journey = self.ensure_journey(
            task_id=task_id,
            goal="",
        )

        timestamp = now()
        checkpoint_id = f"CP-{uuid4().hex[:10].upper()}"

        row = {
            "checkpoint_id": checkpoint_id,
            "journey_id": journey.journey_id,
            "task_id": task_id,
            "timestamp": timestamp,
            "current_step": current_step,
            "completed_steps": list(completed_steps),
            "active_step": active_step,
            "remaining_steps": list(remaining_steps),
            "active_character": active_character,
            "active_capability": active_capability,
            "state": state,
            "blocked_reason": blocked_reason,
            "waiting_for": waiting_for,
            "context_version": context_version,
            "artifact_refs": list(artifact_refs),
            "event_refs": list(event_refs),
        }

        self.store.state_checkpoint(row)

        self.store.update_state_journey(
            task_id,
            {
                "updated_at": timestamp,
            },
        )

        return Checkpoint(**row)

    def latest_checkpoint(
        self,
        task_id: str,
    ) -> Checkpoint | None:
        row = self.store.latest_state_checkpoint(task_id)

        if row is None:
            return None

        return Checkpoint(**row)

    # ------------------------------------------------------------------
    # Event retrieval
    # ------------------------------------------------------------------

    def events(
        self,
        task_id: str,
    ) -> tuple[ExecutionEvent, ...]:
        rows = self.store.state_events(task_id)

        return tuple(
            ExecutionEvent(**row)
            for row in rows
        )

    # ------------------------------------------------------------------
    # Journey resolution
    # ------------------------------------------------------------------

    def resolve(
        self,
        task_id: str | None = None,
        conversation_id: str | None = None,
    ) -> tuple[str | None, str | None]:
        """
        Resolve a journey/task pair.

        Rules:
        1. Explicit task_id is authoritative.
        2. Explicit conversation_id resolves only if exactly one journey
           belongs to it.
        3. Without either identifier, resolve only when exactly one active
           journey exists.
        4. Multiple candidates remain ambiguous.
        """
        if task_id is not None:
            journey = self.store.get_state_journey_by_task(task_id)

            if journey is None:
                return None, task_id

            return (
                journey.get("journey_id"),
                task_id,
            )

        if conversation_id is not None:
            rows = self.store.state_journeys_by_conversation(
                conversation_id
            )

            if len(rows) == 1:
                return (
                    rows[0]["journey_id"],
                    rows[0]["task_id"],
                )

            # Zero or multiple journeys cannot be safely resolved.
            return None, None

        rows = self.store.active_state_journeys()

        if len(rows) == 1:
            return (
                rows[0]["journey_id"],
                rows[0]["task_id"],
            )

        # No active journey or multiple active journeys.
        return None, None

    # ------------------------------------------------------------------
    # Situation awareness
    # ------------------------------------------------------------------

    def situation(
        self,
        task_id: str,
        level: SituationLevel,
    ) -> SituationAwarenessResponse:
        """
        Produce a situation-awareness response from durable records only.

        No checkpoint:
            CURRENT and NEXT cannot be fabricated.

        No events:
            HISTORY cannot be fabricated.

        Remaining steps:
            NEXT uses the first recorded remaining step only.

        Blocked checkpoint:
            NEXT reports BLOCKED rather than inventing a future action.
        """
        journey = self.store.get_state_journey_by_task(task_id)

        checkpoint = self.latest_checkpoint(task_id)
        events = self.events(task_id)

        # No authoritative journey means no authoritative situation.
        if journey is None:
            return SituationAwarenessResponse(
                level=level,
            )

        source_ids: list[str] = [
            f"journey:{journey['journey_id']}"
        ]

        source_ids.extend(
            f"event:{event.event_id}"
            for event in events[-20:]
        )

        if checkpoint is not None:
            source_ids.append(
                f"checkpoint:{checkpoint.checkpoint_id}"
            )

        # Preserve order while removing duplicates.
        sources = tuple(
            dict.fromkeys(source_ids)
        )

        # --------------------------------------------------------------
        # HISTORY
        # --------------------------------------------------------------

        if level is SituationLevel.HISTORY:
            if not events:
                return SituationAwarenessResponse(
                    level=level,
                    uncertainty=(
                        "NO_AUTHORITATIVE_EVENT_RECORD",
                    ),
                    sources=sources,
                )

            history = tuple(
                {
                    "event_id": event.event_id,
                    "type": event.event_type,
                    "actor": event.actor,
                    "timestamp": event.timestamp,
                    "previous_state": event.previous_state,
                    "new_state": event.new_state,
                    "caused_by": event.caused_by,
                    "status": event.status,
                }
                for event in events[-20:]
            )

            return SituationAwarenessResponse(
                level=level,
                history=history,
                sources=sources,
                truth_class=TruthClass.RECORDED_FACT,
                status="RECORDED",
            )

        # --------------------------------------------------------------
        # CURRENT
        # --------------------------------------------------------------

        if level is SituationLevel.CURRENT:
            if checkpoint is None:
                return SituationAwarenessResponse(
                    level=level,
                    uncertainty=(
                        "NO_AUTHORITATIVE_CHECKPOINT",
                    ),
                    sources=sources,
                )

            current = {
                "checkpoint_id": checkpoint.checkpoint_id,
                "step": checkpoint.current_step,
                "active_step": checkpoint.active_step,
                "character": checkpoint.active_character,
                "capability": checkpoint.active_capability,
                "state": checkpoint.state,
                "completed_steps": list(
                    checkpoint.completed_steps
                ),
                "remaining_steps": list(
                    checkpoint.remaining_steps
                ),
                "blocked_reason": checkpoint.blocked_reason,
                "waiting_for": checkpoint.waiting_for,
            }

            blocking = None

            if (
                checkpoint.blocked_reason
                or checkpoint.waiting_for
            ):
                blocking = {
                    "reason": checkpoint.blocked_reason,
                    "waiting_for": checkpoint.waiting_for,
                }

            return SituationAwarenessResponse(
                level=level,
                current=current,
                blocking=blocking,
                sources=sources,
                truth_class=TruthClass.RECORDED_FACT,
                status="RECORDED",
            )

        # --------------------------------------------------------------
        # NEXT
        # --------------------------------------------------------------

        if checkpoint is None:
            return SituationAwarenessResponse(
                level=level,
                uncertainty=(
                    "NO_AUTHORITATIVE_CHECKPOINT",
                ),
                sources=sources,
            )

        remaining = list(
            checkpoint.remaining_steps
        )

        # A blocked journey must never expose the first remaining step as
        # executable/next. The authoritative fact is that progress is
        # blocked.
        if (
            checkpoint.blocked_reason
            or checkpoint.waiting_for
        ):
            description = (
                checkpoint.blocked_reason
                or f"waiting for {checkpoint.waiting_for}"
            )

            next_value = {
                "type": NextType.BLOCKED.value,
                "description": description,
            }

            truth_class = TruthClass.BLOCKED
            status = "BLOCKED"

        elif remaining:
            # This is deliberately a recorded next step, not a prediction.
            next_value = {
                "type": NextType.RECORDED_NEXT_STEP.value,
                "description": remaining[0],
            }

            truth_class = TruthClass.PROJECTION
            status = "RECORDED_NEXT_STEP"

        else:
            next_value = {
                "type": NextType.NO_REMAINING_STEPS.value,
                "description": "No remaining recorded steps.",
            }

            truth_class = TruthClass.RECORDED_FACT
            status = "NO_REMAINING_STEPS"

        return SituationAwarenessResponse(
            level=level,
            next=next_value,
            sources=sources,
            truth_class=truth_class,
            status=status,
        )

    # ------------------------------------------------------------------
    # Pause / resume
    # ------------------------------------------------------------------

    def pause(
        self,
        task_id: str,
        reason: str = "Human requested pause.",
    ):
        self.record_event(
            task_id=task_id,
            event_type="HUMAN_INTERRUPTION",
            actor="human",
            new_state="PAUSING",
            provenance={
                "reason": reason,
            },
        )

        from criterivox.application.home03_runtime import (
            home03_runtime,
        )

        return home03_runtime.pause(
            task_id,
            reason,
        )

    def resume(
        self,
        task_id: str,
    ):
        from criterivox.application.home03_runtime import (
            home03_runtime,
        )

        result = home03_runtime.resume(task_id)

        self.record_event(
            task_id=task_id,
            event_type="TASK_RESUMED",
            actor="human",
            new_state="RESUMED",
        )

        return result


state_runtime = StateRuntime()
