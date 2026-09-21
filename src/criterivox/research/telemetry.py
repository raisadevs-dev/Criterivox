from __future__ import annotations

import os
import uuid
from typing import Any

from .models import ResearchConsent, ResearchEvent, ResearchSession
from .repository import ResearchRepository


class ResearchEvidence:
    """Consent-gated research instrumentation.

    Research collection is OFF unless CRITERIVOX_RESEARCH_ENABLED is true.
    Even when enabled, interaction events require the participant's
    interaction_research consent.
    """

    def __init__(self, repository: ResearchRepository | None = None, enabled: bool | None = None) -> None:
        self.repository = repository or ResearchRepository(
            os.getenv("CRITERIVOX_RESEARCH_DB", "data/research/criterivox_research.sqlite3")
        )
        self.enabled = (
            enabled if enabled is not None
            else os.getenv("CRITERIVOX_RESEARCH_ENABLED", "false").casefold() == "true"
        )

    def register_consent(self, consent: ResearchConsent) -> None:
        if not self.enabled:
            return
        self.repository.upsert_participant(consent.participant_id, consent.recorded_at)
        self.repository.record_consent(consent)

    def start_session(
        self,
        *,
        participant_id: str,
        study_id: str | None = None,
        app_version: str | None = None,
        metadata: dict[str, Any] | None = None,
    ) -> ResearchSession:
        session = ResearchSession(
            session_id=f"RS-{uuid.uuid4().hex[:12].upper()}",
            participant_id=participant_id,
            study_id=study_id,
            app_version=app_version,
            started_at=_now(),
            metadata=metadata or {},
        )
        if self.enabled:
            self.repository.record_session(session)
        return session

    def record(
        self,
        *,
        session_id: str,
        participant_id: str,
        event_type: str,
        purpose: str = "interaction_research",
        workflow_stage: str | None = None,
        payload: dict[str, Any] | None = None,
    ) -> bool:
        if not self.enabled:
            return False
        event = ResearchEvent(
            event_id=f"RE-{uuid.uuid4().hex[:12].upper()}",
            session_id=session_id,
            participant_id=participant_id,
            event_type=event_type,
            purpose=purpose,
            timestamp=_now(),
            workflow_stage=workflow_stage,
            payload=payload or {},
        )
        return self.repository.record_event(event)


def _now() -> str:
    from datetime import datetime, timezone
    return datetime.now(timezone.utc).isoformat()


research_evidence = ResearchEvidence()
