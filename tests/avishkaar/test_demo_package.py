import csv
import json
from pathlib import Path

ROOT = Path("packages/avishkaar_demo")
CASE = ROOT / "cases" / "CASE-001"


def _load_json(path: Path):
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def test_case_fixture_is_self_contained():
    manifest = _load_json(CASE / "manifest.json")
    assert manifest["case_id"] == "CASE-001"
    assert manifest["human_id"] == "CR-27"

    for item in manifest["inputs"]:
        if item["path_or_inline"].endswith(".txt") or item["path_or_inline"].endswith(".csv"):
            assert (CASE / item["path_or_inline"]).exists()


def test_evidence_fixture_has_explicit_conflict():
    rows = list(csv.DictReader((CASE / "evidence.csv").open(encoding="utf-8", newline="")))
    assert len(rows) >= 1
    conflicts = [row for row in rows if row["conflicts_with"]]
    assert any(row["evidence_id"] == "E-04" for row in conflicts)
    assert any(row["evidence_id"] == "E-06" for row in conflicts)


def test_character_reports_are_independent_and_linked_to_task():
    vivren = _load_json(ROOT / "report-fixtures" / "character" / "CR-27-vivren.json")
    tarkis = _load_json(ROOT / "report-fixtures" / "character" / "CR-27-tarkis.json")
    task = _load_json(ROOT / "report-fixtures" / "task" / "CR-27-research-strategy.json")

    assert vivren["scope"] == "character"
    assert tarkis["scope"] == "character"
    assert vivren["human_id"] == tarkis["human_id"] == task["human_id"] == "CR-27"
    assert vivren["report_id"] in task["child_report_refs"]
    assert tarkis["report_id"] in task["child_report_refs"]
    assert vivren["report_id"] != tarkis["report_id"]


def test_text_and_visualization_share_artifact_references():
    task = _load_json(ROOT / "report-fixtures" / "task" / "CR-27-research-strategy.json")
    visual_sections = [s for s in task["sections"] if "visualization" in s]
    assert visual_sections
    for section in visual_sections:
        assert set(section["visualization"]["derived_from"]).issubset(set(section["artifact_refs"]))
