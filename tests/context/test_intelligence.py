from datetime import datetime, timedelta, timezone

from criterivox.domain.context_intelligence import (
    EvidenceDebtLevel,
    ContextMemoryPolicy,
    build_provenance_graph,
    calculate_evidence_debt,
    diff_contexts,
)


def test_provenance_graph_preserves_context_chain() -> None:
    graph = build_provenance_graph(
        foundation_id="F-1",
        context_id="CTX-1",
        interpretation_id="INT-1",
        source_ids=("SRC-1", "SRC-2"),
    )

    assert {node.node_id for node in graph.nodes} == {
        "SRC-1",
        "SRC-2",
        "F-1",
        "CTX-1",
        "INT-1",
    }
    assert ("F-1", "CTX-1", "STRUCTURED_AS") in {
        (edge.source, edge.target, edge.relation) for edge in graph.edges
    }


def test_context_diff_is_explicit() -> None:
    result = diff_contexts(
        ["content", "temporal"],
        ["content", "environment"],
        previous_fields={"audience": "unknown", "records": 3},
        current_fields={"audience": "students", "records": 3},
    )

    assert result.added_dimensions == ("environment",)
    assert result.removed_dimensions == ("temporal",)
    assert result.unchanged_dimensions == ("content",)
    assert result.changed_fields == ("audience",)


def test_evidence_debt_exposes_completeness_and_tags() -> None:
    result = calculate_evidence_debt(
        [
            {"status": "OBSERVED"},
            {"status": "ASSUMED"},
            {"status": "UNKNOWN"},
        ],
        missing_context_count=1,
        uncertainty_count=1,
    )

    assert 0 <= result.completeness_percent <= 100
    assert result.level in {
        EvidenceDebtLevel.HIGH,
        EvidenceDebtLevel.MEDIUM,
        EvidenceDebtLevel.LOW,
    }
    assert "ASSUMPTION_OR_HYPOTHESIS" in result.tags
    assert "MISSING_CONTEXT" in result.tags


def test_context_memory_expiration_is_configurable_and_not_implicit() -> None:
    created = datetime(2026, 1, 1, tzinfo=timezone.utc)
    policy = ContextMemoryPolicy.from_created_at(
        created,
        ttl=timedelta(days=30),
        now=datetime(2026, 1, 15, tzinfo=timezone.utc),
    )

    assert policy.status == "ACTIVE"
    assert policy.expires_at == datetime(2026, 1, 31, tzinfo=timezone.utc)
    assert ContextMemoryPolicy.disabled().status == "UNKNOWN"
