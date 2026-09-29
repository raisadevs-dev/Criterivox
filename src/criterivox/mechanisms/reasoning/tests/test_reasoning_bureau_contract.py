from criterivox.s7.orchestrator import ReasoningResearchBureau
from criterivox.s7.reasoning_pipeline import PHASES


def test_s7_exposes_all_public_reasoning_phases_and_graph():
    bureau = ReasoningResearchBureau()
    session = bureau.start(
        "Compare two possible explanations for the supplied observation.",
        {"observation": "synthetic observation", "source": "fixture"},
    )
    snapshot = bureau.snapshot(session.session_id)
    assert len(PHASES) == 10
    assert len(snapshot["reasoning_graph"]["nodes"]) == 10
    assert len(snapshot["reasoning_graph"]["edges"]) == 9
    assert "Critical Intelligence Chamber" in snapshot["rooms"].values()
    assert "Hypothesis Exploration Chamber" in snapshot["rooms"].values()


def test_s7_stops_on_insufficient_context():
    bureau = ReasoningResearchBureau()
    session = bureau.start("Assess this claim", {})
    snapshot = bureau.snapshot(session.session_id)
    assert snapshot["status"] == "waiting_for_information"
    assert "structured context" in snapshot["missing_information"]
    assert any(a["kind"] == "limitation" for a in snapshot["artifacts"])


def test_human_challenge_creates_branch_and_recomputes_evaluation():
    bureau = ReasoningResearchBureau()
    session = bureau.start("Compare two hypotheses", {"observation": "A"})
    before = bureau.snapshot(session.session_id)
    target = next(a for a in before["artifacts"] if a["kind"] == "reasoning")
    after = bureau.challenge(session.session_id, target["artifact_id"], "This reasoning needs to account for an alternative observation.")
    snapshot = bureau.snapshot(after.session_id)
    assert snapshot["branch_id"] != "main"
    assert any(a["kind"] == "human_intervention" for a in snapshot["artifacts"])
    assert any(e["event_type"] == "HUMAN_CHALLENGE" for e in snapshot["events"])
    assert len([a for a in snapshot["artifacts"] if a["kind"] == "evaluation"]) >= 2
