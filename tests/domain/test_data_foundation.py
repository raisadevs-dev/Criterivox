from criterivox.domain.data_foundation import (
    ConfirmationStatus, DataFoundation, DataHandoff, Missingness, SourceType,
)


def test_foundation_has_stable_identity_and_explicit_layers():
    item = DataFoundation.create()
    assert item.foundation_id.startswith("DF-")
    assert item.raw_data == ()
    assert item.canonical_data == ()
    assert item.confirmation_status is ConfirmationStatus.UNCERTAIN


def test_handoff_requires_ready_foundation():
    item = DataFoundation.create()
    try:
        DataHandoff.from_foundation(item, "kaelen")
    except ValueError as exc:
        assert "not ready" in str(exc)
    else:
        raise AssertionError("handoff must require readiness")


def test_source_type_and_missingness_are_explicit():
    assert SourceType.FOLDER_COLLECTION.value == "folder_collection"
    assert Missingness.NOT_PROVIDED.value == "not_provided"
