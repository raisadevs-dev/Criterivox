import asyncio

from criterivox.application.data_foundation_store import DataFoundationStore


def test_store_confirm_then_handoff_preserves_foundation_identity():
    store = DataFoundationStore()
    foundation = store.ingest({"sources": [{"name": "notes.txt", "source_type": "text", "channel": "text", "content": "first finding\nsecond finding"}]})
    confirmed = store.confirm(foundation.foundation_id, "confirm")
    handoff = store.handoff(confirmed.foundation_id)
    assert handoff.foundation_id == foundation.foundation_id
    assert handoff.recipient == "dharen"
    assert handoff.source_ids == (foundation.sources[0].source_id,)


def test_store_rejects_unknown_foundation():
    store = DataFoundationStore()
    try:
        store.get("DF-NOT-FOUND")
    except ValueError as exc:
        assert "Unknown" in str(exc)
    else:
        raise AssertionError("unknown foundation should be rejected")
