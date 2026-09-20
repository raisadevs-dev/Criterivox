from __future__ import annotations

import asyncio
from pathlib import Path

from criterivox.application.human_residence_work import ResidenceWorkEngine


def test_residence_confirmation_material_ready_take_challenge_decision(tmp_path: Path):
    engine = ResidenceWorkEngine(
        path=tmp_path / "work.json",
        material_root=tmp_path / "materials",
    )
    work = engine.create_work(owner_id="human", room_id="private", goal="Compare these options in Marathi", language="mr")
    interpreted = engine.interpret_work(work["work_id"])
    assert interpreted["status"] == "AWAITING_CONFIRMATION"
    assert interpreted["interpretation"]["language"] == "mr"

    material = engine.add_material(
        work["work_id"],
        filename="notes.csv",
        content_type="text/csv",
        data=b"option,value\nA,10\nB,20\n",
    )
    assert material["extraction_status"] == "EXTRACTED"

    confirmed = engine.confirm(work["work_id"])
    assert confirmed["journey_id"]
    asyncio.run(asyncio.sleep(0.25))
    ready = engine.get(work["work_id"])
    assert ready["status"] == "READY_FOR_HUMAN"
    assert ready["ready_items"]

    review = engine.take(work["work_id"])
    assert review["status"] == "UNDER_REVIEW"
    challenged = engine.challenge(work["work_id"], challenge_type="PREMISE", text="Show the evidence.")
    assert challenged["status"] in {"REWORKING", "WORKING", "READY_FOR_HUMAN"}

    decision = engine.decide(work["work_id"], option_id="OPT-1")
    assert decision["status"] == "DECISION_READY"
    authorized = engine.authorize(work["work_id"])
    assert authorized["status"] == "AUTHORIZED"


def test_residence_correction_reenters_confirmation(tmp_path: Path):
    engine = ResidenceWorkEngine(path=tmp_path / "work.json", material_root=tmp_path / "materials")
    work = engine.create_work(owner_id="human", room_id="private", goal="old goal")
    engine.interpret_work(work["work_id"])
    corrected = engine.confirm(work["work_id"], confirmed=False, correction="new goal")
    assert corrected["status"] == "AWAITING_CONFIRMATION"
    assert corrected["interpretation"]["goal"] == "new goal"


def test_residence_xlsx_is_not_silently_accepted_as_text(tmp_path: Path):
    engine = ResidenceWorkEngine(path=tmp_path / "work.json", material_root=tmp_path / "materials")
    work = engine.create_work(owner_id="human", room_id="private", goal="inspect spreadsheet")
    material = engine.add_material(
        work["work_id"],
        filename="table.xlsx",
        content_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        data=b"not a valid xlsx",
    )
    assert material["extraction_status"] == "EXTRACTION_FAILED"


def test_residence_requires_authorization_before_public_research(tmp_path: Path):
    engine = ResidenceWorkEngine(path=tmp_path / "work.json", material_root=tmp_path / "materials")
    work = engine.create_work(owner_id="human", room_id="private", goal="Find public information about a research topic")
    engine.interpret_work(work["work_id"])
    with __import__("pytest").raises(ValueError, match="research_requires_human_authorization"):
        engine.run_research(work["work_id"])


def test_residence_public_research_is_recorded_and_bounded(tmp_path: Path, monkeypatch):
    from criterivox.application.information_acquisition import ResearchResult
    from criterivox.application import human_residence_work as module

    engine = ResidenceWorkEngine(path=tmp_path / "work.json", material_root=tmp_path / "materials")
    work = engine.create_work(owner_id="human", room_id="private", goal="Find public information about a research topic")
    engine.interpret_work(work["work_id"])
    engine.confirm(work["work_id"])

    class FakeProvider:
        def acquire(self, query):
            return [ResearchResult(
                query=query,
                source_url="https://example.com/research",
                title="Public source",
                snippet="Evidence excerpt.",
                fetched=True,
                content_excerpt="Evidence excerpt.",
            )]

    monkeypatch.setattr(module, "PublicWebResearchProvider", FakeProvider)
    result = engine.authorize_research(work["work_id"], scope="public_web")
    assert result["research"]["authorization"] == "AUTHORIZED"
    assert result["research"]["state"] == "READY_FOR_STRATEGY"
    assert result["information_need"]["state"] == "READY_FOR_STRATEGY"
    assert result["research"]["sources"][0]["provenance_status"] == "ACQUIRED_PUBLIC_WEB"
