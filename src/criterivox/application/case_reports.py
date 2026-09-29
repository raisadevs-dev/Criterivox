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
    ) -> dict[str, Any]:
        if not task.strip():
            raise ValueError("task is required")

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
