from criterivox.application.data_foundation_store import DataFoundationStore
from criterivox.domain.data_foundation import ConfirmationStatus, DataFoundation


def test_serialized_foundation_round_trip_and_replace():
    source = DataFoundation.create()
    store = DataFoundationStore(items={source.foundation_id: source}, revisions={source.foundation_id: 3})
    envelope = store.serialize(source.foundation_id)

    recovered = DataFoundationStore()
    restored = recovered.restore_replace(envelope)

    assert restored.to_dict() == source.to_dict()
    assert recovered.revision(source.foundation_id) == 3
    assert recovered.get(source.foundation_id).confirmation_status is ConfirmationStatus.UNCERTAIN


def test_restore_rejects_stale_revision():
    source = DataFoundation.create()
    store = DataFoundationStore(items={source.foundation_id: source}, revisions={source.foundation_id: 4})
    stale = {"schema_version": 1, "foundation_id": source.foundation_id, "revision": 3, "foundation": source.to_dict()}

    try:
        store.restore_replace(stale)
    except ValueError as exc:
        assert "Stale foundation revision" in str(exc)
    else:
        raise AssertionError("stale foundation recovery must be rejected")


def test_equal_revision_is_idempotent():
    source = DataFoundation.create()
    store = DataFoundationStore(items={source.foundation_id: source}, revisions={source.foundation_id: 2})
    envelope = store.serialize(source.foundation_id)

    restored = store.restore_replace(envelope)

    assert restored.to_dict() == source.to_dict()
    assert store.revision(source.foundation_id) == 2
