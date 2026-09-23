from __future__ import annotations

import sqlite3

import pytest

from criterivox.application.research_instrumentation import (
    ResearchInstrumentationStore,
    ResearchQuestionAnalyzer,
)


def make_store(tmp_path):
    return ResearchInstrumentationStore(tmp_path / "research.sqlite3")


def test_research_data_requires_consent(tmp_path):
    store = make_store(tmp_path)
    participant = store.register_participant(
        display_name="Research Participant", email="participant@example.test"
    )
    session = store.start_session(participant_id=participant.participant_id)

    with pytest.raises(PermissionError):
        store.record_event(
            session_id=session.session_id,
            participant_id=participant.participant_id,
            event_type="challenge",
            research_scope="research",
        )


def test_operational_event_does_not_require_research_consent(tmp_path):
    store = make_store(tmp_path)
    session = store.start_session()

    event_id = store.record_event(
        session_id=session.session_id,
        event_type="page_view",
        research_scope="operational",
    )

    assert event_id.startswith("event-")


def test_outcome_requires_explicit_follow_up_consent(tmp_path):
    store = make_store(tmp_path)
    participant = store.register_participant(
        display_name="Research Participant", email="participant@example.test"
    )
    session = store.start_session(participant_id=participant.participant_id)
    store.record_consent(
        participant_id=participant.participant_id,
        consent_version="v1",
        research_data=True,
    )

    with pytest.raises(PermissionError):
        store.record_outcome(
            session_id=session.session_id,
            participant_id=participant.participant_id,
            success_state="succeeded",
        )


def test_research_events_and_outcomes_are_queryable(tmp_path):
    store = make_store(tmp_path)
    participant = store.register_participant(
        display_name="Research Participant", email="participant@example.test"
    )
    store.record_consent(
        participant_id=participant.participant_id,
        consent_version="v1",
        research_data=True,
        outcome_follow_up=True,
    )
    session = store.start_session(
        participant_id=participant.participant_id, language_mode="mr"
    )
    store.record_event(
        session_id=session.session_id,
        participant_id=participant.participant_id,
        event_type="challenge",
        payload={"target": "finding"},
        research_scope="research",
    )
    store.record_outcome(
        session_id=session.session_id,
        participant_id=participant.participant_id,
        success_state="succeeded",
        helped_score=9,
        improvement_request="Keep the explanation trace visible.",
    )

    counts = ResearchQuestionAnalyzer(store).event_counts()
    summary = ResearchQuestionAnalyzer(store).outcome_summary()

    assert counts["challenge"] == 1
    assert summary["outcomes"] == 1
    assert summary["succeeded"] == 1
    assert summary["average_helped_score"] == 9
