import json
from pathlib import Path

from criterivox.application.context_engine import ContextEngine
from criterivox.domain.data_foundation import DataFoundation, Provenance, SourceRecord, SourceType

DATA = Path(__file__).parents[1] / "data" / "s6"


def load_jsonl(name: str):
    return [json.loads(line) for line in (DATA / name).read_text(encoding="utf-8").splitlines() if line.strip()]


def make_material(case):
    sources = tuple(
        SourceRecord(
            source_id=source_id,
            name=source_id,
            source_type=SourceType.REFERENCE,
            channel="test",
            provided_at="2026-09-11T00:00:00+00:00",
            provenance=Provenance(source_id, SourceType.REFERENCE, source_id),
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


def test_training_corpus_has_expected_cases():
    cases = load_jsonl("context_engine_training.jsonl")
    assert len(cases) >= 15
    assert all(case["case_id"].startswith("S6-TR-") for case in cases)


def test_missing_data_is_not_silently_zero():
    case = next(c for c in load_jsonl("context_engine_training.jsonl") if c["label"] == "missing-not-zero")
    result = ContextEngine().create_from_material_set(make_material(case))
    item = next(i for i in result.context.items if i.key == "material.record_count")
    assert item.value is None
    assert item.status.value == "UNKNOWN"


def test_provenance_and_interpretation_boundaries():
    case = next(c for c in load_jsonl("context_engine_training.jsonl") if c["label"] == "provenance-chain")
    result = ContextEngine().create_from_material_set(make_material(case))
    assert {node.kind for node in result.provenance_graph.nodes} >= {"SOURCE", "FOUNDATION", "CONTEXT", "INTERPRETATION"}
    assert {edge.relation for edge in result.provenance_graph.edges} >= {"EXTRACTED_INTO", "STRUCTURED_AS", "INTERPRETED_AS"}
    assert any("causal" in limitation for limitation in result.interpretation.limitations)


def test_context_diff_preserves_structural_change():
    case = next(c for c in load_jsonl("context_engine_training.jsonl") if c["label"] == "structural-diff")
    result = ContextEngine().create_from_material_set(make_material(case), previous_context=case["previous_context"])
    assert result.context_diff.changed_fields == ("supplied.period",)
    assert result.context_diff.removed_dimensions == ("supplied.region",)


def test_training_memory_case_is_active():
    case = next(c for c in load_jsonl("context_engine_training.jsonl") if c["label"] == "memory-active")
    result = ContextEngine().create_from_material_set(
        make_material(case),
        memory_recheck_seconds=case["memory_recheck_seconds"],
        memory_recheck_reason=case["memory_recheck_reason"],
    )
    assert result.memory.status == "ACTIVE"


def test_failure_corpus_contract_is_explicit():
    cases = load_jsonl("context_engine_failure_cases.jsonl")
    assert len(cases) >= 4
    assert any(c["expected"] == "ValueError" for c in cases)
