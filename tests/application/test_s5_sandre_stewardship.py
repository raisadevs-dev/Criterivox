from criterivox.application.sandre_stewardship import SandreStewardship
from criterivox.domain.data_foundation import DataFoundation


def test_schema_preflight_auto_fills_at_eighty_percent():
    result = SandreStewardship.schema_preflight(
        ["name", "age", "platform", "extra"],
        ["name", "age", "platform", "country"],
    )
    assert result.match_ratio == 0.75
    assert result.auto_fill is False
    assert result.requires_clarification is True


def test_schema_preflight_uses_threshold_for_confirmation_path():
    result = SandreStewardship.schema_preflight(
        ["name", "age", "platform", "country"],
        ["name", "age", "platform", "country", "region"],
    )
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


def test_conflict_merge_requires_field_level_winner():
    steward = SandreStewardship()
    merged, resolutions = steward.merge_conflicts(
        {"purpose": "analysis", "format": "csv"},
        {"purpose": "research", "format": "csv"},
        {"purpose": "chat"},
    )
    assert merged["purpose"] == "research"
    assert resolutions[0].field == "purpose"
