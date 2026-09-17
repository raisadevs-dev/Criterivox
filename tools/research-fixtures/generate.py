#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import random
import sys
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path

try:
    from openpyxl import Workbook
except ImportError:
    Workbook = None

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "generated"


@dataclass
class Fixture:
    fixture_id: str
    scenario: str
    simulated_upstream_component: str
    task: str
    context: dict
    observations: list[dict]
    hypotheses: list[dict]
    contradictions: list[dict]
    human_interventions: list[dict]
    provenance: dict
    limitations: list[str]
    synthetic: bool = True


def ask(prompt: str, default: str = "") -> str:
    value = input(f"{prompt}\n> ").strip()
    return value or default


def ask_bool(prompt: str, default: bool = False) -> bool:
    value = ask(f"{prompt} (yes/no)", "yes" if default else "no").lower()
    return value in {"y", "yes", "true", "1"}


def ask_int(prompt: str, default: int) -> int:
    try:
        return max(1, int(ask(prompt, str(default))))
    except ValueError:
        return default


def make(args: argparse.Namespace) -> list[Fixture]:
    now = datetime.now(timezone.utc).isoformat()
    fixtures = []
    for index in range(args.count):
        observations = [
            {
                "record_id": f"obs-{index + 1:04d}-{record + 1:03d}",
                "observation": f"Synthetic structured observation {record + 1} for {args.task}",
                "source_component": args.component,
            }
            for record in range(args.records)
        ]
        hypotheses = (
            [
                {"hypothesis_id": "H1", "statement": "Synthetic explanation A"},
                {"hypothesis_id": "H2", "statement": "Synthetic explanation B"},
            ]
            if args.hypotheses
            else []
        )
        contradictions = (
            [
                {
                    "contradiction_id": "C1",
                    "description": "Synthetic contradictory observation requiring conflict handling",
                    "related_observation": f"obs-{index + 1:04d}-001",
                }
            ]
            if args.contradictory
            else []
        )
        interventions = (
            [
                {
                    "intervention_id": "I1",
                    "type": "challenge",
                    "instruction": "Reconsider the weakest supported inference",
                }
            ]
            if args.intervention
            else []
        )
        fixtures.append(
            Fixture(
                fixture_id=f"FX-{args.scenario.upper()}-{index + 1:04d}",
                scenario=args.scenario,
                simulated_upstream_component=args.component,
                task=args.task,
                context={"input_kind": args.input_kind, "record_count": args.records},
                observations=observations,
                hypotheses=hypotheses,
                contradictions=contradictions,
                human_interventions=interventions,
                provenance={
                    "generated_at": now,
                    "generator": "Criterivox Test Dataset & Fixture Laboratory",
                    "origin_component": args.component,
                    "synthetic": True,
                },
                limitations=["Synthetic material; not real-world evidence."],
            )
        )
    return fixtures


def write(fixtures: list[Fixture], formats: list[str]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    data = [asdict(fixture) for fixture in fixtures]
    scenario = fixtures[0].scenario

    if "json" in formats:
        target = OUT / "json"
        target.mkdir(exist_ok=True)
        (target / f"{scenario}.json").write_text(json.dumps(data, indent=2), encoding="utf-8")

    if "csv" in formats:
        target = OUT / "csv"
        target.mkdir(exist_ok=True)
        path = target / f"{scenario}.csv"
        fields = list(data[0])
        with path.open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=fields)
            writer.writeheader()
            for row in data:
                writer.writerow(
                    {key: json.dumps(value) if isinstance(value, (dict, list)) else value for key, value in row.items()}
                )

    if "xlsx" in formats:
        if Workbook is None:
            raise RuntimeError("XLSX output requires openpyxl")
        target = OUT / "xlsx"
        target.mkdir(exist_ok=True)
        book = Workbook()
        sheet = book.active
        sheet.title = "fixtures"
        sheet.append(list(data[0]))
        for row in data:
            sheet.append([json.dumps(value) if isinstance(value, (dict, list)) else value for value in row.values()])
        book.save(target / f"{scenario}.xlsx")

    manifests = OUT / "manifests"
    manifests.mkdir(exist_ok=True)
    (manifests / f"{scenario}.manifest.json").write_text(
        json.dumps(
            {
                "synthetic": True,
                "production_ingestion": False,
                "formats": formats,
                "fixture_ids": [fixture.fixture_id for fixture in fixtures],
            },
            indent=2,
        ),
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--non-interactive", action="store_true")
    parser.add_argument("--scenario", default="reasoning")
    parser.add_argument("--component", default="Dharen")
    parser.add_argument("--task")
    parser.add_argument("--input-kind", default="structured observations")
    parser.add_argument("--count", type=int, default=1)
    parser.add_argument("--records", type=int, default=5)
    parser.add_argument("--hypotheses", action="store_true")
    parser.add_argument("--contradictory", action="store_true")
    parser.add_argument("--provenance", action="store_true")
    parser.add_argument("--intervention", action="store_true")
    parser.add_argument("--formats", default="json,csv,xlsx")
    parser.add_argument("--seed", type=int, default=7)
    args = parser.parse_args()
    random.seed(args.seed)

    if not args.non_interactive:
        print("\nCriterivox Research Fixture Generator\n")
        args.task = ask("What are you testing?", "S7 reasoning analysis")
        args.input_kind = ask("What kind of input should simulate the upstream system?", "structured observations")
        args.records = ask_int("How many records?", 50)
        args.hypotheses = ask_bool("Should there be competing hypotheses?", True)
        args.contradictory = ask_bool("Should there be contradictory evidence?", True)
        args.provenance = ask_bool("Should provenance be included?", True)
        args.intervention = ask_bool("Should human intervention be included?", False)
        args.formats = ask("Output formats (JSON, CSV, XLSX)", "JSON, CSV, XLSX")
        args.component = ask("Which Criterivox component should this simulate?", "Dharen")
        args.scenario = ask("Scenario", "reasoning")
        args.count = ask_int("How many fixture cases?", 1)

    args.formats = ",".join(item.strip().lower() for item in args.formats.split(",") if item.strip())
    args.task = args.task or "Analyze supplied structured observations."
    write(make(args), args.formats.split(","))
    print(f"Generated fixtures under {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
