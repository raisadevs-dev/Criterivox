from criterivox.application.sandre_stewardship import SandreStewardship
from criterivox.domain.data_foundation import ConfirmationStatus, DataFoundation


def test_schema_preflight_auto_fills_at_eighty_percent():
    result = SandreStewardship.schema_preflight(["name", "age", "platform", "extra"], ["name", "age", "platform", "country"])
    assert result.match_ratio == 0.75
    assert result.auto_fill is False
    assert result.requires_clarification is True


def test_schema_preflight_uses_threshold_for_confirmation_path():
    result = SandreStewardship.schema_preflight(["name", "age", "platform", "country"], ["name", "age", "platform", "country", "region"])
    assert result.match_ratio == 0.8
    assert result.auto_fill is True
    assert result.requires_clarification is False


def test_preview_has_explicit_user_confirmation_question():
    foundation = DataFoundation.create()
    report = SandreStewardship().preview(foundation)
    assert report.question == "Is this what you intended to submit?"


def test_routing_only_allows_known_downstream_agents():
    steward = SandreStewardship()
    assert steward.route("syvax") == "syvax"
    assert steward.route("dharen") == "dharen"
    assert steward.route("kaelen") == "kaelen"


def test_handoff_requires_user_confirmation_or_correction():
    foundation = DataFoundation.create()
    assert SandreStewardship.can_handoff(foundation) is False
    confirmed = foundation.__class__(**{**foundation.to_dict(), "confirmation_status": ConfirmationStatus.USER_CONFIRMED})
    assert SandreStewardship.can_handoff(confirmed) is True


def test_stewardship_logs_are_searchable_by_recipient_and_task():
    foundation = DataFoundation.create()
    steward = SandreStewardship()
    steward.record(foundation, task_ids=("TASK-123",), recipient="syvax", event="SANDRE_HANDOFF_READY")
    assert len(steward.search_logs("syvax")) == 1
    assert len(steward.search_logs("TASK-123")) == 1


def test_conflict_merge_requires_field_level_winner():
    steward = SandreStewardship()
    merged, resolutions = steward.merge_conflicts(
        {"purpose": "analysis", "format": "csv"},
        {"purpose": "research", "format": "csv"},
        {"purpose": "chat"},
    )
    assert merged["purpose"] == "research"
    assert resolutions[0].field == "purpose"


def test_conflict_merge_rejects_unresolved_conflict():
    try:
        SandreStewardship.merge_conflicts({"purpose": "analysis"}, {"purpose": "research"}, {})
    except ValueError as exc:
        assert "explicit winner" in str(exc)
    else:
        raise AssertionError("Unresolved conflicts must not be silently overwritten.")
