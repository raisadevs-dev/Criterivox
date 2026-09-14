#!/usr/bin/env python3
"""Criterivox Test Dataset & Fixture Laboratory.

Generates synthetic upstream stimuli for integration/acceptance tests. These files
simulate structured requests that internal Criterivox components could emit; they
are not a production S7 ingestion path and never perform S7 reasoning.
"""
from __future__ import annotations

import argparse
import csv
import json
import random
import sys
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

try:
    from openpyxl import Workbook
except ImportError:  # XLSX generation is optional at runtime.
    Workbook = None

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "generated"


@dataclass
class Fixture:
    fixture_id: str
    scenario: str
    upstream_component: str
    task: str
    context: dict[str, Any]
    provenance: dict[str, Any]
    expected_conditions: list[str]


def ask(prompt: str, default: str = "") -> str:
    suffix = f" [{default}]" if default else ""
    value = input(f"{prompt}{suffix}: ").strip()
    return value or default


def ask_int(prompt: str, default: int) -> int:
    try:
        return max(1, int(ask(prompt, str(default))))
    except ValueError:
        return default


def fixture_from_answers(scenario: str, component: str, task: str, count: int) -> list[Fixture]:
    now = datetime.now(timezone.utc).isoformat()
    result: list[Fixture] = []
    for index in range(1, count + 1):
        context: dict[str, Any] = {
            "request_id": f"fixture-{scenario}-{index:03d}",
            "source_component": component,
            "observations": [
                {"id": "obs-1", "statement": "Observation supplied by an upstream component."},
                {"id": "obs-2", "statement": "Second observation intentionally available for comparison."},
            ],
            "constraints": ["Use only supplied context", "Preserve provenance"],
        }
        expected: list[str] = ["create_reasoning_artifact", "preserve_provenance"]
        if scenario in {"hypothesis", "contradiction"}:
            context["candidate_hypotheses"] = [
                {"id": "H1", "statement": "The first supplied explanation."},
                {"id": "H2", "statement": "An alternative explanation."},
            ]
            expected.append("explore_or_compare_hypotheses")
        if scenario == "contradiction":
            context["observations"].append({"id": "obs-3", "statement": "Contradictory observation against obs-1."})
            expected.append("surface_disagreement_without_fabrication")
        if scenario == "insufficient_context":
            context = {"request_id": context["request_id"], "source_component": component}
            expected = ["stop_for_missing_information", "identify_missing_context"]
        if scenario == "intervention":
            context["human_intervention"] = {"type": "challenge", "instruction": "Reconsider the weakest supported step."}
            expected.append("create_new_branch_from_intervention")
        result.append(Fixture(f"FX-{scenario.upper()}-{index:03d}", scenario, component, task, context, {"generated_at": now, "generator": "Criterivox Test Dataset & Fixture Laboratory", "synthetic": True}, expected))
    return result


def write_json(fixtures: list[Fixture], path: Path) -> None:
    path.write_text(json.dumps([asdict(item) for item in fixtures], indent=2), encoding="utf-8")


def write_csv(fixtures: list[Fixture], path: Path) -> None:
    fields = ["fixture_id", "scenario", "upstream_component", "task", "context", "provenance", "expected_conditions"]
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for item in fixtures:
            row = asdict(item)
            row["context"] = json.dumps(row["context"], separators=(",", ":"))
            row["provenance"] = json.dumps(row["provenance"], separators=(",", ":"))
            row["expected_conditions"] = json.dumps(row["expected_conditions"])
            writer.writerow(row)


def write_xlsx(fixtures: list[Fixture], path: Path) -> None:
    if Workbook is None:
        raise RuntimeError("XLSX output requires openpyxl. Install the project dependencies first.")
    book = Workbook()
    sheet = book.active
    sheet.title = "fixtures"
    fields = ["fixture_id", "scenario", "upstream_component", "task", "context_json", "provenance_json", "expected_conditions"]
    sheet.append(fields)
    for item in fixtures:
        sheet.append([item.fixture_id, item.scenario, item.upstream_component, item.task, json.dumps(item.context), json.dumps(item.provenance), json.dumps(item.expected_conditions)])
    book.save(path)


def write_manifest(fixtures: list[Fixture], path: Path, formats: list[str]) -> None:
    manifest = {
        "laboratory": "Criterivox Test Dataset & Fixture Laboratory",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "synthetic": True,
        "production_ingestion": False,
        "formats": formats,
        "fixture_ids": [item.fixture_id for item in fixtures],
    }
    path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate reusable Criterivox research fixtures.")
    parser.add_argument("--non-interactive", action="store_true", help="Use safe defaults without prompts.")
    parser.add_argument("--scenario", choices=["reasoning", "hypothesis", "contradiction", "insufficient_context", "intervention"], default=None)
    parser.add_argument("--component", default=None, help="Simulated upstream component, e.g. Dharen, Anuka, Syvax, Tarkis.")
    parser.add_argument("--task", default=None)
    parser.add_argument("--count", type=int, default=None)
    parser.add_argument("--formats", default=None, help="Comma-separated: json,csv,xlsx")
    parser.add_argument("--seed", type=int, default=7)
    args = parser.parse_args()
    random.seed(args.seed)

    if args.non_interactive:
        scenario = args.scenario or "reasoning"
        component = args.component or "Dharen"
        task = args.task or "Analyze the supplied observations and identify supported conclusions."
        count = args.count or 5
        formats = [x.strip() for x in (args.formats or "json,csv,xlsx").split(",")]
    else:
        print("\nCriterivox Test Dataset & Fixture Laboratory")
        print("Synthetic fixtures simulate internal upstream requests. They are test stimuli, not a production S7 ingestion mechanism.\n")
        scenario = args.scenario or ask("Scenario (reasoning/hypothesis/contradiction/insufficient_context/intervention)", "reasoning")
        component = args.component or ask("Simulated upstream component", "Dharen")
        task = args.task or ask("Analytical task", "Analyze the supplied observations and identify supported conclusions.")
        count = args.count or ask_int("Number of fixtures", 5)
        formats = [x.strip().lower() for x in (args.formats or ask("Formats (json,csv,xlsx)", "json,csv,xlsx")).split(",")]

    fixtures = fixture_from_answers(scenario, component, task, count)
    OUT.mkdir(parents=True, exist_ok=True)
    if "json" in formats:
        write_json(fixtures, OUT / f"{scenario}.json")
    if "csv" in formats:
        write_csv(fixtures, OUT / f"{scenario}.csv")
    if "xlsx" in formats:
        write_xlsx(fixtures, OUT / f"{scenario}.xlsx")
    write_manifest(fixtures, OUT / f"{scenario}.manifest.json", formats)
    print(f"Generated {len(fixtures)} fixture(s) in {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
