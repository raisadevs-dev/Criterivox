from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
CASE_ROOT = ROOT / "packages" / "avishkaar_demo" / "cases"


def test_all_standard_cases_have_the_same_contract_shape():
    manifests = []
    for index in range(1, 11):
        case_id = f"CASE-{index:03d}"
        path = CASE_ROOT / case_id / "manifest.json"
        assert path.is_file(), case_id
        data = json.loads(path.read_text(encoding="utf-8"))
        manifests.append(data)
        assert data["schema_version"] == "1.1.0"
        assert data["case_id"] == case_id
        assert isinstance(data["expected_capabilities"], list)
        assert data["expected_capabilities"]
        assert data["execution"]["capability_selection"] == "dynamic"
        assert data["execution"]["preserve_character_reports"] is True
        assert data["execution"]["combined_report"] is True
        assert data["execution"]["report_views"] == ["text", "visualization"]
        assert data["evaluation_contract"]["answer_key"] is False

    assert [m["case_id"] for m in manifests] == [f"CASE-{i:03d}" for i in range(1, 11)]


def test_case_index_lists_exactly_ten_cases():
    index = json.loads(
        (CASE_ROOT / "index.json").read_text(encoding="utf-8")
    )
    assert index["contract_version"] == "1.1.0"
    assert index["cases"] == [f"CASE-{i:03d}" for i in range(1, 11)]
