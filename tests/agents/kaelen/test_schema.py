from criterivox.agents.kaelen.schema import SchemaDriftHealer, SchemaTransformer


def test_schema_transform_maps_aliases_and_casts():
    result = SchemaTransformer().transform(
        [{"old": "4"}],
        ["new"],
        aliases={"old": "new"},
        casts={"new": "int"},
    )
    assert result["rows"] == [{"new": 4}]
    assert result["mapping"] == {"old": "new"}
    assert result["reversible"] is True


def test_schema_drift_reports_added_removed():
    result = SchemaDriftHealer().diff(["id", "old"], ["id", "new"])
    assert result["added"] == ["new"]
    assert result["removed"] == ["old"]
    assert result["drift"] is True
