import csv
from pathlib import Path

from criterivox.application.context_engine import ContextEngine
from criterivox.domain.data_foundation import DataFoundation, SourceRecord, SourceType

DATA = Path(__file__).parents[1] / "data" / "s6" / "acceptance"


def rows(name: str):
    with (DATA / name).open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def material(row: dict[str, str]) -> DataFoundation:
    source_id = row["source_id"]
    context = {
        key: value
        for key, value in row.items()
        if key in {"platform", "surface", "period", "window", "region", "locale", "audience", "segment", "language_mode"}
        and value not in (None, "")
    }
    records = row.get("records") or row.get("items_seen")
    canonical = tuple({"row": index} for index in range(int(records))) if records else ()
    return DataFoundation(
        foundation_id=f"DF-{row['case_id']}",
        created_at="2026-09-11T00:00:00+00:00",
        sources=(
            SourceRecord(
                source_id=source_id,
                name=source_id,
                source_type=SourceType.DATASET,
                channel="acceptance",
                provided_at="2026-09-11T00:00:00+00:00",
            ),
        ),
        canonical_data=canonical,
        supplied_context=context,
    )


def test_user_acceptance_datasets_build_context_without_silent_zero():
    engine = ContextEngine()
    for filename in (
        "01_cross_platform_context.csv",
        "02_context_shift_and_memory.csv",
        "03_missing_and_uncertain_context.csv",
        "04_provenance_and_handoff.csv",
    ):
        for row in rows(filename):
            result = engine.create_from_material_set(material(row))
            count = next(item for item in result.context.items if item.key == "material.record_count")
            if not (row.get("records") or row.get("items_seen")):
                assert count.value is None
                assert count.status.value == "UNKNOWN"
            else:
                assert count.value >= 0
            assert result.provenance_graph.nodes
            assert result.evidence_debt.completeness_percent >= 0
            assert result.evidence_debt.completeness_percent <= 100


def test_unseen_datasets_preserve_missingness_and_provenance():
    engine = ContextEngine()
    for filename in (
        "unseen_01_schema_variation.csv",
        "unseen_02_sparse_context.csv",
        "unseen_03_temporal_shift.csv",
    ):
        for row in rows(filename):
            result = engine.create_from_material_set(material(row))
            assert any(node.kind == "SOURCE" for node in result.provenance_graph.nodes)
            count = next(item for item in result.context.items if item.key == "material.record_count")
            if not (row.get("items_seen") or ""):
                assert count.value is None
                assert count.status.value == "UNKNOWN"
            assert "causal" in " ".join(result.interpretation.limitations)
