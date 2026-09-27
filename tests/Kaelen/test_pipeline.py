from criterivox.Kaelen.pipeline import KaelenPipeline


def test_pipeline_builds_inspectable_dag():
    result = KaelenPipeline().execute(
        [{"id": "1", "name": "a"}],
        expected_schema=["id", "name", "score"],
        casts={"id": "int"},
    )
    assert result["status"] == "ready"
    assert result["canonical_data"] == [{"id": 1, "name": "a", "score": None}]
    assert result["dag"]["nodes"] == [
        "ingest", "profile", "validate", "normalize", "patch", "handoff"
    ]


def test_pipeline_handoff_is_structured():
    result = KaelenPipeline().handoff_package([{"a": 1}])
    assert result["kind"] == "kaelen.normalized_pipeline_handoff"
    assert result["status"] == "ready"
