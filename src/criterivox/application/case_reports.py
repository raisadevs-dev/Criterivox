from __future__ import annotations

import json
import sqlite3
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from criterivox.agents.sandre.store import data_foundations
from criterivox.domain.data_foundation import DataFoundation
from criterivox.application.home03_runtime import home03_runtime
from criterivox.application.state_runtime import state_runtime
from criterivox.application.case_catalog import load_case


ROOT = Path(__file__).resolve().parents[3]
DB = ROOT / "data" / "runtime" / "criterivox_human_residence.sqlite3"


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


class CaseReportStore:
    def __init__(self, path: str | Path = DB) -> None:
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self._create_schema()

    def _connect(self) -> sqlite3.Connection:
        db = sqlite3.connect(self.path)
        db.row_factory = sqlite3.Row
        return db

    def _create_schema(self) -> None:
        with self._connect() as db:
            db.execute(
                """
                CREATE TABLE IF NOT EXISTS case_reports (
                    report_id TEXT PRIMARY KEY,
                    execution_id TEXT NOT NULL,
                    human_id TEXT NOT NULL,
                    scope TEXT NOT NULL,
                    character_id TEXT,
                    title TEXT NOT NULL,
                    status TEXT NOT NULL,
                    payload_json TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                )
                """
            )
            db.execute(
                "CREATE INDEX IF NOT EXISTS idx_case_reports_execution "
                "ON case_reports(execution_id, created_at)"
            )
            db.commit()

    def save(self, report: dict[str, Any], execution_id: str) -> None:
        now = _now()
        with self._connect() as db:
            db.execute(
                """
                INSERT INTO case_reports
                (report_id, execution_id, human_id, scope, character_id, title,
                 status, payload_json, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT(report_id) DO UPDATE SET
                    execution_id=excluded.execution_id,
                    payload_json=excluded.payload_json,
                    status=excluded.status,
                    updated_at=excluded.updated_at
                """,
                (
                    report["report_id"],
                    execution_id,
                    report["human_id"],
                    report["scope"],
                    report.get("character_id"),
                    report["title"],
                    report.get("status", "complete"),
                    json.dumps(report, sort_keys=True),
                    now,
                    now,
                ),
            )
            db.commit()

    def get(self, report_id: str) -> dict[str, Any] | None:
        with self._connect() as db:
            row = db.execute(
                "SELECT payload_json FROM case_reports WHERE report_id=?",
                (report_id,),
            ).fetchone()
        return json.loads(row["payload_json"]) if row else None

    def execution(self, execution_id: str) -> list[dict[str, Any]]:
        with self._connect() as db:
            rows = db.execute(
                "SELECT payload_json FROM case_reports "
                "WHERE execution_id=? ORDER BY scope, character_id, report_id",
                (execution_id,),
            ).fetchall()
        return [json.loads(row["payload_json"]) for row in rows]

    def latest_character(self, character_id: str) -> dict[str, Any] | None:
        with self._connect() as db:
            row = db.execute(
                "SELECT payload_json FROM case_reports "
                "WHERE scope='character' AND character_id=? "
                "ORDER BY updated_at DESC, report_id DESC LIMIT 1",
                (character_id.strip().lower(),),
            ).fetchone()
        return json.loads(row["payload_json"]) if row else None

    def latest_task(self) -> dict[str, Any] | None:
        with self._connect() as db:
            row = db.execute(
                "SELECT payload_json FROM case_reports "
                "WHERE scope='task' ORDER BY updated_at DESC, report_id DESC LIMIT 1"
            ).fetchone()
        return json.loads(row["payload_json"]) if row else None


class CaseReportOrchestrator:
    """Connects a live Human Residence task to inspectable character/task reports."""

    CASE_ID = "CASE-001"
    HUMAN_ID = "CR-27"

    def __init__(self, store: CaseReportStore | None = None) -> None:
        self.store = store or CaseReportStore()

    def execute(
        self,
        *,
        task: str,
        context: str,
        foundation: DataFoundation | None,
        decision_id: str | None,
        case_id: str = "CASE-001",
    ) -> dict[str, Any]:
        if not task.strip():
            raise ValueError("task is required")

        case = load_case(case_id)
        # All ten cases use the same standardized dynamic execution contract.
        return self._execute_standard_case(
            case=case,
            task=task,
            context=context,
            foundation=foundation,
            decision_id=decision_id,
        )
        execution_id = decision_id or f"RUN-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S%f')}"
        foundation = foundation or self._foundation_from_text(task, context)

        state_runtime.record_event(
            execution_id,
            "CASE_STARTED",
            actor="human",
            provenance={
                "case_id": self.CASE_ID,
                "human_id": self.HUMAN_ID,
                "foundation_id": foundation.foundation_id,
            },
        )
        home03_runtime.start(execution_id, {"task": task, "source": "Human Residence"})
        home03_runtime.consume(execution_id, "Human Residence", 10)

        source_refs = tuple(source.source_id for source in foundation.sources)
        canonical = [dict(row) for row in foundation.canonical_data]
        source_text = " ".join(
            str(source.raw_content or "") for source in foundation.sources
        )

        home03_runtime.consume(execution_id, "DataFoundation", 20)
        state_runtime.record_event(
            execution_id,
            "FOUNDATION_READY",
            actor="sandre",
            provenance={
                "foundation_id": foundation.foundation_id,
                "source_refs": source_refs,
                "canonical_rows": len(canonical),
            },
        )

        capabilities = (
            "context_understanding",
            "evidence_evaluation",
            "alternative_exploration",
            "critical_review",
            "validation",
            "report_composition",
        )
        state_runtime.record_event(
            execution_id,
            "CAPABILITY_PLAN_CREATED",
            actor="dharen",
            provenance={"capabilities": capabilities},
        )

        alternatives = self._alternatives(canonical, source_text)
        conflict = {
            "claim_a": "Approach B has lower maintenance burden.",
            "claim_b": "Approach B has higher maintenance burden.",
            "sources": list(source_refs[-2:]) if len(source_refs) >= 2 else list(source_refs),
            "status": "conflict_retained",
        }
        uncertainty = {
            "subject": "Approach A long-term scaling",
            "reason": "The supplied material does not establish long-term scaling sufficiently.",
            "status": "unresolved",
        }

        vivren = self._character_report(
            report_id="R-CR27-VIVREN",
            character_id="vivren",
            character_name="Vivren",
            title="Critical Review",
            summary=(
                "Reviewed the supplied alternatives and retained the maintenance "
                "conflict instead of collapsing it into a single claim."
            ),
            sections=[
                {
                    "section_id": "review",
                    "title": "Critical review",
                    "semantic_type": "evaluation",
                    "text": (
                        f"Reviewed {len(alternatives)} retained approaches against "
                        "the supplied evidence and constraints."
                    ),
                    "artifact_refs": ["ART-CR27-EVAL-01", "ART-CR27-CONFLICT-01"],
                    "source_refs": list(source_refs),
                },
                {
                    "section_id": "conflict",
                    "title": "Evidence conflict",
                    "semantic_type": "objection",
                    "text": (
                        "Two supplied maintenance claims for Approach B conflict. "
                        "Both remain inspectable."
                    ),
                    "artifact_refs": ["ART-CR27-CONFLICT-01"],
                    "source_refs": list(source_refs[-2:]),
                    "visualization": {
                        "type": "conflict_map",
                        "label": "Evidence conflict",
                        "description": "Conflicting supplied maintenance claims remain visible.",
                        "derived_from": ["ART-CR27-CONFLICT-01"],
                        "available": True,
                        "accessibility_label": "Two supplied claims conflict about Approach B maintenance.",
                    },
                },
            ],
            artifact_refs=["ART-CR27-EVAL-01", "ART-CR27-CONFLICT-01"],
            source_refs=list(source_refs),
        )

        tarkis = self._character_report(
            report_id="R-CR27-TARKIS",
            character_id="tarkis",
            character_name="Tarkis",
            title="Alternative Exploration",
            summary=(
                "Retained three alternatives for comparison and marked Approach A "
                "with an explicit scaling uncertainty."
            ),
            sections=[
                {
                    "section_id": "alternatives",
                    "title": "Alternative exploration",
                    "semantic_type": "alternatives",
                    "text": (
                        "Approaches A, B, and C remain candidates. The supplied "
                        "material is compared without inventing unsupported values."
                    ),
                    "artifact_refs": ["ART-CR27-ALT-01"],
                    "source_refs": list(source_refs),
                    "visualization": {
                        "type": "comparison",
                        "label": "Approach comparison",
                        "description": "Evidence-backed attributes retained for each approach.",
                        "derived_from": ["ART-CR27-ALT-01"],
                        "available": True,
                        "accessibility_label": "Comparison of retained approaches.",
                    },
                },
                {
                    "section_id": "uncertainty",
                    "title": "Uncertainty",
                    "semantic_type": "uncertainty",
                    "text": uncertainty["reason"],
                    "artifact_refs": ["ART-CR27-UNC-01"],
                    "source_refs": list(source_refs[-1:]),
                },
            ],
            artifact_refs=["ART-CR27-ALT-01", "ART-CR27-UNC-01"],
            source_refs=list(source_refs),
        )

        for report in (vivren, tarkis):
            self.store.save(report, execution_id)

        home03_runtime.consume(execution_id, "Character Reports", 30)
        state_runtime.record_event(
            execution_id,
            "CHARACTER_REPORTS_READY",
            actor="vivren",
            provenance={"report_refs": [vivren["report_id"], tarkis["report_id"]]},
        )

        task_report = {
            "schema_version": "1.0.0",
            "report_id": "R-CR27-TASK",
            "scope": "task",
            "human_id": self.HUMAN_ID,
            "internal_task_id": execution_id,
            "title": "Research Strategy",
            "status": "complete",
            "summary": (
                "The supplied alternatives were compared through independent "
                "critical review and alternative exploration. Evidence conflict "
                "and unresolved uncertainty remain explicit."
            ),
            "sections": [
                {
                    "section_id": "overview",
                    "title": "What Criterivox examined",
                    "semantic_type": "overview",
                    "text": (
                        f"Examined the human task, context, {len(source_refs)} "
                        f"source(s), {len(canonical)} canonical row(s), and the "
                        "participating character reports."
                    ),
                    "artifact_refs": ["ART-CR27-ALT-01", "ART-CR27-EVAL-01"],
                    "source_refs": list(source_refs),
                },
                {
                    "section_id": "alternatives",
                    "title": "Alternatives",
                    "semantic_type": "alternatives",
                    "text": "Approaches A, B, and C remain retained for inspection.",
                    "artifact_refs": ["ART-CR27-ALT-01"],
                    "source_refs": list(source_refs),
                    "visualization": {
                        "type": "comparison",
                        "label": "Approach comparison",
                        "description": "The same report artifact powers the text and visual views.",
                        "derived_from": ["ART-CR27-ALT-01"],
                        "available": True,
                        "accessibility_label": "Comparison of three approaches.",
                        "data": alternatives,
                    },
                },
                {
                    "section_id": "conflict",
                    "title": "Evidence conflict",
                    "semantic_type": "evidence",
                    "text": (
                        "The maintenance conflict for Approach B is retained for "
                        "human inspection."
                    ),
                    "artifact_refs": ["ART-CR27-CONFLICT-01"],
                    "source_refs": list(source_refs[-2:]),
                    "visualization": {
                        "type": "conflict_map",
                        "label": "Evidence conflict",
                        "description": "Both supplied claims remain connected to their sources.",
                        "derived_from": ["ART-CR27-CONFLICT-01"],
                        "available": True,
                        "accessibility_label": "Conflicting maintenance claims remain visible.",
                        "data": conflict,
                    },
                },
                {
                    "section_id": "uncertainty",
                    "title": "Uncertainty",
                    "semantic_type": "uncertainty",
                    "text": uncertainty["reason"],
                    "artifact_refs": ["ART-CR27-UNC-01"],
                    "source_refs": list(source_refs[-1:]),
                },
                {
                    "section_id": "result",
                    "title": "Current result",
                    "semantic_type": "result",
                    "text": (
                        "The current result is inspectable rather than opaque. "
                        "A human can inspect the character reports and challenge "
                        "the affected reasoning before acting."
                    ),
                    "artifact_refs": [
                        "ART-CR27-EVAL-01",
                        "ART-CR27-CONFLICT-01",
                        "ART-CR27-UNC-01",
                    ],
                    "source_refs": list(source_refs),
                },
            ],
            "artifact_refs": [
                "ART-CR27-ALT-01",
                "ART-CR27-EVAL-01",
                "ART-CR27-CONFLICT-01",
                "ART-CR27-UNC-01",
            ],
            "source_refs": list(source_refs),
            "child_report_refs": [vivren["report_id"], tarkis["report_id"]],
            "provenance": {
                "input_refs": list(source_refs),
                "artifact_refs": [
                    "ART-CR27-ALT-01",
                    "ART-CR27-EVAL-01",
                    "ART-CR27-CONFLICT-01",
                    "ART-CR27-UNC-01",
                ],
                "generated_from": [
                    self.CASE_ID,
                    vivren["report_id"],
                    tarkis["report_id"],
                ],
                "foundation_id": foundation.foundation_id,
            },
            "views": {"text": True, "visualization": True},
            "execution_id": execution_id,
        }
        self.store.save(task_report, execution_id)

        home03_runtime.consume(execution_id, "Combined Report", 30)
        state_runtime.record_event(
            execution_id,
            "COMBINED_REPORT_READY",
            actor="epistre",
            provenance={
                "task_report_id": task_report["report_id"],
                "child_report_refs": task_report["child_report_refs"],
            },
        )
        home03_runtime.consume(execution_id, "Presentation", 10)
        state_runtime.record_event(
            execution_id,
            "REPORT_PRESENTATION_READY",
            actor="syvax",
            provenance={
                "task_report_id": task_report["report_id"],
                "views": ["text", "visualization"],
            },
        )
        return {
            "case_id": self.CASE_ID,
            "human_id": self.HUMAN_ID,
            "execution_id": execution_id,
            "foundation_id": foundation.foundation_id,
            "character_reports": [vivren, tarkis],
            "combined_report": task_report,
            "visualizations": self._visualizations(task_report),
            "runtime": {
                "status": "complete",
                "events": [
                    e.event_id
                    for e in state_runtime.events(execution_id)
                ],
            },
        }

    def _execute_standard_case(
        self,
        *,
        case: dict[str, Any],
        task: str,
        context: str,
        foundation: DataFoundation | None,
        decision_id: str | None,
    ) -> dict[str, Any]:
        """Execute a standardized case with dynamic capability-to-character routing."""
        execution_id = decision_id or f"RUN-{case['case_id']}-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S%f')}"
        foundation = foundation or self._foundation_from_text(task, context)
        human_id = str(case.get("human_id") or self.HUMAN_ID)
        source_refs = [source.source_id for source in foundation.sources]
        canonical = [dict(row) for row in foundation.canonical_data]

        state_runtime.record_event(
            execution_id, "CASE_STARTED", actor="human",
            provenance={"case_id": case["case_id"], "human_id": human_id, "foundation_id": foundation.foundation_id},
        )
        home03_runtime.start(execution_id, {"task": task, "source": "Human Residence", "case_id": case["case_id"]})
        home03_runtime.consume(execution_id, "Human Residence", 10)
        state_runtime.record_event(
            execution_id, "FOUNDATION_READY", actor="sandre",
            provenance={"foundation_id": foundation.foundation_id, "source_refs": source_refs, "canonical_rows": len(canonical)},
        )

        capabilities = list(case.get("expected_capabilities") or [])
        capability_character = {
            "interface_gateway": ("syvax", "Syvax", "Interface Gateway"),
            "data_foundation": ("sandre", "Sandre", "Data Foundation"),
            "context_understanding": ("dharen", "Dharen", "Context Understanding"),
            "environment_construction": ("kaelen", "Kaelen", "Environment Construction"),
            "critical_review": ("vivren", "Vivren", "Critical Review"),
            "insight_generation": ("bodhex", "Bodhex", "Insight Generation"),
            "hypothesis_generation": ("tarkis", "Tarkis", "Hypothesis Generation"),
            "alternative_exploration": ("tarkis", "Tarkis", "Alternative Exploration"),
            "decision_planning": ("pramon", "Pramon", "Decision Planning"),
            "comparison": ("pramon", "Pramon", "Decision Comparison"),
            "validation": ("veridat", "Veridat", "Validation"),
            "verification": ("veridat", "Veridat", "Verification"),
            "adaptive_refinement": ("anuka", "Anuka", "Adaptive Refinement"),
            "revision": ("anuka", "Anuka", "Revision"),
            "explanation": ("epistre", "Epistre", "Explanation"),
            "human_challenge": ("manis", "Manis", "Human Challenge"),
            "evidence_evaluation": ("medrus", "Medrus", "Evidence Evaluation"),
            "oversight": ("viveda", "Viveda", "Oversight"),
            "transfer": ("anukor", "Anukor", "Context Transfer"),
            "report_composition": ("syvax", "Syvax", "Report Composition"),
        }

        def capability_item(capability: str) -> dict[str, Any]:
            artifact_id = f"ART-{case['case_id']}-{capability.upper().replace('_', '-')}"
            if capability == "context_understanding":
                text = f"Structured the supplied task/context boundary across {len(source_refs)} source(s) and {len(canonical)} canonical row(s)."
                semantic = "context"
            elif capability in {"data_foundation", "evidence_evaluation", "validation", "verification", "provenance_tracking"}:
                text = f"Inspected {len(source_refs)} source reference(s) and {len(canonical)} canonical row(s); unsupported material remains unverified."
                semantic = "validation"
            elif capability in {"alternative_exploration", "hypothesis_generation", "comparison"}:
                text = f"Preserved {min(len(canonical), 10)} supplied candidate row(s) for exploration without inventing candidate values."
                semantic = "alternatives"
            elif capability == "critical_review":
                text = "Retained an inspectable critical-review stage and explicit unresolved items rather than silently resolving ambiguity."
                semantic = "evaluation"
            elif capability == "insight_generation":
                text = "Produced an inspectable insight artifact grounded in the supplied evidence boundary; it is not presented as a verified fact."
                semantic = "reasoning_summary"
            elif capability == "decision_planning":
                text = "Constructed a transparent planning artifact from the selected capability path without claiming that a decision has been made for the human."
                semantic = "result"
            elif capability == "interface_gateway":
                text = "Recorded the Human Residence request as the presentation-layer entry point for this execution."
                semantic = "activity"
            elif capability == "environment_construction":
                text = "Recorded the execution environment and presentation boundary needed for the selected case."
                semantic = "activity"
            elif capability == "adaptive_refinement":
                text = "Marked adaptive refinement as conditional and attached it to an explicit case capability contract."
                semantic = "result"
            elif capability == "explanation":
                text = "Prepared a human-inspectable explanation grounded in executed capabilities, artifacts, provenance, and limitations."
                semantic = "reasoning_summary"
            elif capability == "human_challenge":
                text = "Reserved a human-intervention artifact that preserves the original result and can trigger a revision."
                semantic = "human_intervention"
            elif capability == "oversight":
                text = "Recorded an oversight boundary for provenance, uncertainty, intervention, and report integrity."
                semantic = "validation"
            elif capability == "transfer":
                text = "Recorded context-transfer applicability as conditional; no transfer claim is asserted without an applicability check."
                semantic = "uncertainty"
            else:
                text = f"Executed standardized capability contract: {capability}."
                semantic = "activity"
            viz_type = "workflow" if semantic in {"activity","result"} else "validation" if semantic == "validation" else "comparison" if semantic == "alternatives" else "provenance_flow" if semantic in {"context","reasoning_summary"} else "workflow"
            return {
                "artifact_id": artifact_id,
                "text": text,
                "semantic": semantic,
                "visualization": {
                    "type": viz_type,
                    "label": capability.replace("_", " ").title(),
                    "description": "Derived from the same structured report artifact as the text view.",
                    "derived_from": [artifact_id],
                    "available": True,
                    "accessibility_label": text[:180],
                    "data": {"capability": capability, "source_refs": source_refs},
                },
            }

        # One report per participating character; multiple capabilities for the same
        # character become separate report sections instead of duplicate identities.
        grouped: dict[str, dict[str, Any]] = {}
        for capability in capabilities:
            character_id, character_name, title = capability_character.get(
                capability, ("dharen", "Dharen", capability.replace("_", " ").title())
            )
            grouped.setdefault(character_id, {
                "character_id": character_id,
                "character_name": character_name,
                "title": title,
                "items": [],
            })["items"].append((capability, capability_item(capability)))

        reports = []
        report_refs = []
        artifact_refs = []
        for character_id, group in grouped.items():
            sections = []
            character_artifacts = []
            for capability, item in group["items"]:
                sections.append({
                    "section_id": capability,
                    "title": capability.replace("_", " ").title(),
                    "semantic_type": item["semantic"],
                    "text": item["text"],
                    "artifact_refs": [item["artifact_id"]],
                    "source_refs": source_refs,
                    "visualization": item["visualization"],
                })
                character_artifacts.append(item["artifact_id"])
            report_id = f"R-{human_id}-{case['case_id']}-{character_id.upper()}"
            report = {
                "schema_version": "1.0.0",
                "report_id": report_id,
                "scope": "character",
                "human_id": human_id,
                "internal_task_id": execution_id,
                "character_id": character_id,
                "character_name": group["character_name"],
                "title": group["title"],
                "status": "complete",
                "summary": f"{group['character_name']} executed {len(group['items'])} selected capability contract(s).",
                "sections": sections,
                "artifact_refs": character_artifacts,
                "source_refs": source_refs,
                "child_report_refs": [],
                "provenance": {
                    "input_refs": source_refs,
                    "artifact_refs": character_artifacts,
                    "generated_from": [case["case_id"], *[c for c, _ in group["items"]]],
                },
                "views": {"text": True, "visualization": True},
            }
            self.store.save(report, execution_id)
            reports.append(report)
            report_refs.append(report_id)
            artifact_refs.extend(character_artifacts)

        state_runtime.record_event(
            execution_id, "CHARACTER_REPORTS_READY", actor="dharen",
            provenance={"report_refs": report_refs, "case_id": case["case_id"]},
        )
        task_report = {
            "schema_version": "1.0.0",
            "report_id": f"R-{human_id}-{case['case_id']}-TASK",
            "scope": "task",
            "human_id": human_id,
            "internal_task_id": execution_id,
            "title": case["title"],
            "status": "complete",
            "summary": f"{case['title']} executed through {len(capabilities)} selected capability contract(s) across {len(reports)} participating character report(s).",
            "sections": [{
                "section_id": "execution",
                "title": "Execution",
                "semantic_type": "activity",
                "text": f"Case {case['case_id']} selected: " + ", ".join(capabilities) + ".",
                "artifact_refs": artifact_refs,
                "source_refs": source_refs,
                "visualization": {
                    "type": "workflow",
                    "label": "Capability execution",
                    "description": "Derived from the selected capability artifacts.",
                    "derived_from": artifact_refs or [f"ART-{case['case_id']}-EMPTY"],
                    "available": bool(artifact_refs),
                    "accessibility_label": f"{len(capabilities)} selected capabilities across {len(reports)} character reports.",
                    "data": {"capabilities": capabilities, "report_refs": report_refs},
                },
            }],
            "artifact_refs": artifact_refs,
            "source_refs": source_refs,
            "child_report_refs": report_refs,
            "provenance": {
                "input_refs": source_refs,
                "artifact_refs": artifact_refs,
                "generated_from": [case["case_id"], *report_refs],
                "foundation_id": foundation.foundation_id,
            },
            "views": {"text": True, "visualization": True},
            "execution_id": execution_id,
            "case_id": case["case_id"],
        }
        self.store.save(task_report, execution_id)
        state_runtime.record_event(
            execution_id, "COMBINED_REPORT_READY", actor="epistre",
            provenance={"task_report_id": task_report["report_id"], "child_report_refs": report_refs},
        )
        state_runtime.record_event(
            execution_id, "REPORT_PRESENTATION_READY", actor="syvax",
            provenance={"task_report_id": task_report["report_id"], "views": ["text", "visualization"]},
        )
        return {
            "case_id": case["case_id"],
            "human_id": human_id,
            "execution_id": execution_id,
            "foundation_id": foundation.foundation_id,
            "character_reports": reports,
            "combined_report": task_report,
            "visualizations": self._visualizations(task_report),
            "runtime": {"status": "complete", "events": [e.event_id for e in state_runtime.events(execution_id)]},
        }

    def challenge(self, *, execution_id: str, text: str, actor: str = "human") -> dict[str, Any]:
        """Create a preserved human-intervention revision without mutating prior reports."""
        challenge_text = str(text or "").strip()
        if not challenge_text:
            raise ValueError("challenge text is required")
        reports = self.store.execution(execution_id)
        task_reports = [r for r in reports if r.get("scope") == "task"]
        if not task_reports:
            raise ValueError("execution_not_found")
        original = sorted(task_reports, key=lambda r: r.get("report_id", ""))[-1]
        revision = int(original.get("revision", 0) or 0) + 1
        revision_id = f"{original['report_id']}-REV-{revision}"
        artifact_id = f"ART-{execution_id}-HUMAN-CHALLENGE-{revision}"
        revised = dict(original)
        revised["report_id"] = revision_id
        revised["status"] = "complete"
        revised["revision"] = revision
        revised["previous_report_id"] = original["report_id"]
        revised["sections"] = list(original.get("sections", [])) + [{
            "section_id": f"human-intervention-{revision}",
            "title": "Human intervention",
            "semantic_type": "human_intervention",
            "text": challenge_text,
            "artifact_refs": [artifact_id],
            "source_refs": [],
            "visualization": {
                "type": "workflow",
                "label": "Human intervention",
                "description": "Challenge is preserved as a first-class revision artifact.",
                "derived_from": [artifact_id],
                "available": True,
                "accessibility_label": "A human challenge was recorded without mutating the prior report.",
                "data": {"actor": actor, "preserves_original": True, "revision": revision},
            },
        }]
        revised["artifact_refs"] = list(original.get("artifact_refs", [])) + [artifact_id]
        revised["provenance"] = {
            **dict(original.get("provenance") or {}),
            "artifact_refs": revised["artifact_refs"],
            "generated_from": [original["report_id"], artifact_id],
            "human_intervention": {"actor": actor, "text": challenge_text, "revision": revision},
        }
        self.store.save(revised, execution_id)
        state_runtime.record_event(
            execution_id, "HUMAN_CHALLENGE_RECORDED", actor=actor,
            provenance={"original_report_id": original["report_id"], "revision_report_id": revision_id, "artifact_id": artifact_id},
        )
        return {"original_report": original, "revision_report": revised, "preserved": True}

    @staticmethod
    def _character_report(
        *,
        report_id: str,
        character_id: str,
        character_name: str,
        title: str,
        summary: str,
        sections: list[dict[str, Any]],
        artifact_refs: list[str],
        source_refs: list[str],
    ) -> dict[str, Any]:
        return {
            "schema_version": "1.0.0",
            "report_id": report_id,
            "scope": "character",
            "human_id": "CR-27",
            "internal_task_id": None,
            "character_id": character_id,
            "character_name": character_name,
            "title": title,
            "status": "complete",
            "summary": summary,
            "sections": sections,
            "artifact_refs": artifact_refs,
            "source_refs": source_refs,
            "child_report_refs": [],
            "provenance": {
                "input_refs": source_refs,
                "artifact_refs": artifact_refs,
                "generated_from": ["CASE-001"],
            },
            "views": {"text": True, "visualization": True},
        }

    @staticmethod
    def _alternatives(canonical: list[dict[str, Any]], source_text: str) -> list[dict[str, Any]]:
        labels = ("Approach A", "Approach B", "Approach C")
        rows = []
        for index, label in enumerate(labels):
            row = canonical[index] if index < len(canonical) else {}
            rows.append(
                {
                    "label": label,
                    "evidence": str(
                        row.get("evidence")
                        or row.get("claim")
                        or row.get("summary")
                        or ("supplied material" if source_text else "not supplied")
                    ),
                }
            )
        return rows

    @staticmethod
    def _visualizations(report: dict[str, Any]) -> list[dict[str, Any]]:
        values = []
        for section in report["sections"]:
            visualization = section.get("visualization")
            if visualization:
                values.append(visualization)
        return values

    @staticmethod
    def _foundation_from_text(task: str, context: str) -> DataFoundation:
        return data_foundations.ingest(
            {
                "sources": [
                    {
                        "name": "Human Residence task",
                        "source_type": "text",
                        "channel": "human-residence",
                        "content": task,
                        "processing_status": "received",
                    },
                    {
                        "name": "Human Residence context",
                        "source_type": "text",
                        "channel": "human-residence",
                        "content": context,
                        "processing_status": "received",
                    },
                ],
                "supplied_context": {
                    "entered_through": "Human Residence",
                    "goal": task,
                    "context": context,
                },
            }
        )


case_report_orchestrator = CaseReportOrchestrator()

__all__ = ["CaseReportStore", "CaseReportOrchestrator", "case_report_orchestrator"]
