from criterivox.application.data_foundation import DataFoundationService
from criterivox.application.data_intake import ingest_sources
from criterivox.domain.data_foundation import ConfirmationStatus, SourceType


def test_ingest_preserves_source_and_candidate_provenance():
    foundation = DataFoundationService().ingest(name="sample.txt", channel="file", source_type=SourceType.FILE, raw_content="alpha\n beta ", supplied_context={"purpose": "synthetic"})
    assert len(foundation.sources) == 1
    assert foundation.sources[0].raw_content == "alpha\n beta "
    assert len(foundation.candidates) == 2
    assert foundation.candidates[0].provenance.source_id == foundation.sources[0].source_id
    assert foundation.transformation_count if False else len(foundation.transformations) > 0
    assert foundation.confirmation_status is ConfirmationStatus.SYSTEM_EXTRACTED


def test_collection_preserves_multiple_sources():
    foundation = ingest_sources({"sources": [
        {"name": "a.txt", "source_type": "file", "channel": "file", "content": "one"},
        {"name": "b.txt", "source_type": "file", "channel": "file", "content": "two"},
    ]})
    assert len(foundation.sources) == 2
    assert foundation.sources[0].provenance.source_id == foundation.sources[0].source_id
    assert foundation.sources[0].parent_source_id is not None
    assert foundation.sources[1].parent_source_id is not None


def test_handoff_requires_confirmation():
    service = DataFoundationService()
    foundation = service.ingest(name="sample.txt", channel="file", raw_content="one")
    try:
        service.handoff(foundation)
    except ValueError as exc:
        assert "confirmation" in str(exc).lower()
    else:
        raise AssertionError("unconfirmed data must not be handed off")


def test_confirmation_enables_handoff_without_mutating_raw_source():
    service = DataFoundationService()
    foundation = service.ingest(name="sample.txt", channel="file", raw_content=" original ")
    confirmed = service.confirm(foundation, action="confirm")
    handoff = service.handoff(confirmed)
    assert handoff.confirmation_status is ConfirmationStatus.USER_CONFIRMED
    assert handoff.canonical_data[0]["content"] == "original"
    assert foundation.raw_data[0]["content"] == " original "
