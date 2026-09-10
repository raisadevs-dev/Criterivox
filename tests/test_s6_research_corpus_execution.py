import json
from pathlib import Path

from criterivox.application.context_engine import ContextEngine
from criterivox.domain.data_foundation import DataFoundation, Provenance, SourceRecord, SourceType

DATA = Path(__file__).parents[1] / "data" / "s6"


def cases(filename: str):
    return [json.loads(line) for line in (DATA / filename).read_text(encoding="utf-8").splitlines() if line.strip()]


def material(case):
    sources = tuple(
        SourceRecord(
            source_id=source_id,
            name=source_id,
            source_type=SourceType.DATASET,
            channel="research-corpus",
            provided_at="2026-09-11T00:00:00+00:00",
            provenance=Provenance(source_id, SourceType.DATASET, source_id),
        )
        for source_id in case.get("source_ids", [])
    )
    return DataFoundation(
        foundation_id=case["material_id"],
        created_at="2026-09-11T00:00:00+00:00",
        sources=sources,
        canonical_data=tuple(case.get("canonical_data", [])),
        supplied_context=dict(case.get("supplied_context", {})),
    )


def test_all_evaluation_cases_against_real_engine():
    engine = ContextEngine()
    for case in cases("context_engine_evaluation.jsonl"):
        expected = case["expected"]
        result = engine.create_from_material_set(
            material(case),
            previous_context=case.get("previous_context"),
            memory_recheck_seconds=case.get("memory_recheck_seconds"),
            memory_recheck_reason=case.get("memory_recheck_reason"),
        )
        count = next(item for item in result.context.items if item.key == "material.record_count")
        if "record_count" in expected:
            assert count.value == expected["record_count"]
        if "record_count_status" in expected:
            assert count.status.value == expected["record_count_status"]
        if "changed_fields" in expected:
            assert result.context_diff.changed_fields == tuple(expected["changed_fields"])
        if "source_count" in expected:
            source_count = sum(node.kind == "SOURCE" for node in result.provenance_graph.nodes)
            assert source_count == expected["source_count"]
        if "required_relations" in expected:
            relations = {edge.relation for edge in result.provenance_graph.edges}
            assert set(expected["required_relations"]) <= relations
        if "memory_status" in expected:
            assert result.memory.status == expected["memory_status"]
        if expected.get("must_not_claim_causal_or_predictive_validity"):
            text = " ".join(result.interpretation.limitations).lower()
            assert "causal" in text and "predictive" in text


def test_training_corpus_has_executable_expected_contracts():
    engine = ContextEngine()
    for case in cases("context_engine_training.jsonl"):
        result = engine.create_from_material_set(
            material(case),
            previous_context=case.get("previous_context"),
            memory_recheck_seconds=case.get("memory_recheck_seconds"),
            memory_recheck_reason=case.get("memory_recheck_reason"),
        )
        expected = case["expected"]
        count = next(item for item in result.context.items if item.key == "material.record_count")
        if "record_count" in expected:
            assert count.value == expected["record_count"]
        if "record_count_status" in expected:
            assert count.status.value == expected["record_count_status"]
        if "changed_fields" in expected:
            assert result.context_diff.changed_fields == tuple(expected["changed_fields"])
        if "removed_dimensions" in expected:
            assert result.context_diff.removed_dimensions == tuple(expected["removed_dimensions"])
        if "supplied_key" in expected:
            assert any(item.key == expected["supplied_key"] for item in result.context.items)
        if "provenance_source_count" in expected:
            assert sum(node.kind == "SOURCE" for node in result.provenance_graph.nodes) == expected["provenance_source_count"]
        if "normalization_operation" in expected:
            assert any(decision.operation == expected["normalization_operation"] for decision in result.normalization)
        if expected.get("uncertainty_present"):
            assert result.interpretation.uncertainty
        if expected.get("interpretation_not_causal"):
            assert "causal" in " ".join(result.interpretation.limitations).lower()
        if "memory_status" in expected:
            assert result.memory.status == expected["memory_status"]
