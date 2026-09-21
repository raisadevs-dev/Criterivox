from __future__ import annotations

import json
from pathlib import Path

from criterivox.research.models import ResearchConsent
from criterivox.research.repository import ResearchRepository
from criterivox.research.telemetry import ResearchEvidence


def test_research_storage_is_consent_gated(tmp_path: Path):
    repo = ResearchRepository(tmp_path / "research.sqlite3")
    evidence = ResearchEvidence(repo, enabled=True)
    evidence.register_consent(ResearchConsent(
        participant_id="P-001",
        consent_version="v1",
        interaction_research=True,
        recorded_at="2026-09-21T00:00:00+00:00",
    ))
    session = evidence.start_session(participant_id="P-001", study_id="S1", app_version="test")
    assert evidence.record(
        session_id=session.session_id,
        participant_id="P-001",
        event_type="GOAL_SUBMITTED",
        payload={"workflow_stage": "intake"},
    )
    assert repo.counts()["events"] == 1


def test_research_event_is_not_recorded_without_matching_consent(tmp_path: Path):
    repo = ResearchRepository(tmp_path / "research.sqlite3")
    evidence = ResearchEvidence(repo, enabled=True)
    session = evidence.start_session(participant_id="P-002")
    assert not evidence.record(
        session_id=session.session_id,
        participant_id="P-002",
        event_type="GOAL_SUBMITTED",
    )
    assert repo.counts()["events"] == 0


def test_exports_are_reproducible_json_and_csv(tmp_path: Path):
    from criterivox.research.export import build_csv_bundle, build_json_export
    repo = ResearchRepository(tmp_path / "research.sqlite3")
    evidence = ResearchEvidence(repo, enabled=True)
    evidence.register_consent(ResearchConsent(
        participant_id="P-003",
        consent_version="v1",
        interaction_research=True,
        recorded_at="2026-09-21T00:00:00+00:00",
    ))
    session = evidence.start_session(participant_id="P-003")
    evidence.record(session_id=session.session_id, participant_id="P-003", event_type="DECISION_RECORDED")
    exported = json.loads(build_json_export(repo))
    assert exported["format_version"] == "1.0"
    assert len(exported["tables"]["events"]) == 1
    bundle = build_csv_bundle(repo)
    assert bundle[:2] == b"PK"
