
from pathlib import Path
import json

from criterivox.application.conversation import interpret_message
from criterivox.application.state_runtime import StateRuntime
from criterivox.domain.state_awareness import SituationLevel, TruthClass
from criterivox.application.home03_store import Home03Store


def runtime():
    return StateRuntime(Home03Store(":memory:"))


def test_intent_classes():
    assert interpret_message("What happened?").intent == "history"
    assert interpret_message("What is happening?").intent == "current"
    assert interpret_message("What's next?").intent == "next"
    assert interpret_message("Pause").intent == "pause"
    assert interpret_message("Resume").intent == "resume"
    assert interpret_message("Stop").intent == "cancel"


def test_journey_task_conversation_are_distinct():
    r = runtime()

    j = r.ensure_journey(
        "T-1",
        "Goal",
        "C-1",
    )

    assert j.journey_id != "T-1"
    assert j.conversation_id == "C-1"
    assert j.task_id == "T-1"


def test_history_uses_recorded_events():
    r = runtime()

    r.ensure_journey(
        "T-1",
        "Goal",
        "C-1",
    )

    r.record_event(
        "T-1",
        "TASK_STARTED",
        actor="dharen",
        new_state="RUNNING",
    )

    s = r.situation(
        "T-1",
        SituationLevel.HISTORY,
    )

    assert s.truth_class is TruthClass.RECORDED_FACT
    assert s.history[0]["type"] == "TASK_STARTED"


def test_missing_checkpoint_does_not_fabricate_current():
    r = runtime()

    r.ensure_journey(
        "T-1",
        "Goal",
        "C-1",
    )

    assert (
        r.situation(
            "T-1",
            SituationLevel.CURRENT,
        ).status
        == "NO_AUTHORITATIVE_RECORD"
    )


def test_next_uses_recorded_remaining_steps():
    r = runtime()

    r.ensure_journey(
        "T-1",
        "Goal",
        "C-1",
    )

    r.checkpoint(
        "T-1",
        "verify",
        "verify",
        ["prepare"],
        ["contradiction review"],
        "veridat",
        "verification",
        "ACTIVE",
    )

    s = r.situation(
        "T-1",
        SituationLevel.NEXT,
    )

    assert s.status == "RECORDED_NEXT_STEP"
    assert s.next["description"] == "contradiction review"


def test_blocked_next_is_not_projected_as_success():
    r = runtime()

    r.ensure_journey(
        "T-1",
        "Goal",
        "C-1",
    )

    r.checkpoint(
        "T-1",
        "verify",
        "verify",
        [],
        ["review"],
        "veridat",
        "verification",
        "BLOCKED",
        "missing evidence",
    )

    s = r.situation(
        "T-1",
        SituationLevel.NEXT,
    )

    assert s.truth_class is TruthClass.BLOCKED
    assert s.next["type"] == "BLOCKED"


def test_multiple_active_tasks_are_ambiguous():
    r = runtime()

    r.ensure_journey(
        "T-1",
        "G1",
        "C1",
    )

    r.ensure_journey(
        "T-2",
        "G2",
        "C2",
    )

    assert r.resolve() == (None, None)


def test_training_and_heldout_are_disjoint_and_valid():
    # tests/test_state_awareness_set2.py
    #
    # parents[0] = tests/
    # parents[1] = repository root
    #
    # Using parents[2] incorrectly escapes the Criterivox repository.
    root = Path(__file__).resolve().parents[1]

    training_path = (
        root
        / "data"
        / "training"
        / "set2_state_awareness.jsonl"
    )

    heldout_path = (
        root
        / "data"
        / "testing"
        / "set2_state_awareness_heldout.jsonl"
    )

    train = [
        json.loads(line)
        for line in training_path.read_text(
            encoding="utf-8"
        ).splitlines()
        if line.strip()
    ]

    test = [
        json.loads(line)
        for line in heldout_path.read_text(
            encoding="utf-8"
        ).splitlines()
        if line.strip()
    ]

    assert len(train) == 10
    assert len(test) == 8

    assert {
        item["id"]
        for item in train
    }.isdisjoint(
        {
            item["id"]
            for item in test
        }
    )
