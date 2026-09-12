from criterivox.human.collaboration_engine import CollaborationEngine


def test_a_to_g_collaboration_flow(tmp_path, monkeypatch):
    import criterivox.human.collaboration_engine as module
    monkeypatch.setattr(module, "ROOT", tmp_path)
    monkeypatch.setattr(module, "STORE", tmp_path / "sessions.json")
    monkeypatch.setattr(module, "LEARNING_STORE", tmp_path / "learning.json")
    engine = CollaborationEngine()
    created = engine.create("res-1", "owner-1", "Owner")
    sid = created["session"]["session_id"]

    engine.add_member(sid, "owner-1", "Resident 1", "resident", "resident-1")
    guest = engine.add_member(sid, "owner-1", "Guest", "guest", "guest-1")
    assert "vote" not in guest["permissions"]

    # C: raw chat -> Syvax classification -> candidate -> human confirmation -> Dharen diff
    candidate = engine.classify_context(sid, "resident-1", "The budget limit must stay below 100", confirm=False)
    assert candidate["status"] == "candidate"
    confirmed = engine.confirm_context(sid, "resident-1", candidate["id"], True)
    assert confirmed["context_diff"]["dharen"]["frame_action"] == "CONTEXT_ADD"

    # D: adaptive consensus and Manis friction
    engine.vote(sid, "resident-1", "Option A")
    c = engine.consensus(sid)
    assert c["manis_friction"] is False
    engine.configure(sid, "owner-1", risk_level="high", required_signatories=1)
    c = engine.consensus(sid)
    assert c["threshold"] == 80
    assert c["manis_friction"] is True
    engine.challenge(sid, "resident-1", "What evidence would make us reject Option A?")

    # E: Owner + N designated Residents -> receipt -> Bodhex dispatch
    action = {"option": "Option A", "reason": "approved collaboration action"}
    engine.owner_sign(sid, "owner-1", action)
    locked = engine.dispatch_status(sid)
    assert locked["unlocked"] is False
    engine.sign(sid, "resident-1", action)
    unlocked = engine.dispatch_status(sid)
    assert unlocked["unlocked"] is True
    dispatch = engine.dispatch(sid, "owner-1", action)
    assert dispatch["target"] == "Bodhex"
    assert dispatch["receipt"]

    # F: outcome -> attribution
    outcome = engine.outcome(sid, "owner-1", "Observed result", "Option A", ["owner-1", "resident-1"])
    assert outcome["outcome_id"]

    # G: Medrus/Viveda analysis -> proposal -> human approval
    proposal = engine.learning_proposal(sid, "owner-1", outcome["outcome_id"])
    assert proposal["status"] == "PENDING_HUMAN_APPROVAL"
    approved = engine.approve_learning(proposal["proposal_id"], "owner-1")
    assert approved["status"] == "APPROVED"


def test_guest_cannot_vote_or_execute(tmp_path, monkeypatch):
    import criterivox.human.collaboration_engine as module
    monkeypatch.setattr(module, "ROOT", tmp_path)
    monkeypatch.setattr(module, "STORE", tmp_path / "sessions.json")
    monkeypatch.setattr(module, "LEARNING_STORE", tmp_path / "learning.json")
    engine = CollaborationEngine()
    created = engine.create("res-1", "owner-1", "Owner")
    sid = created["session"]["session_id"]
    engine.add_member(sid, "owner-1", "Guest", "guest", "guest-1")
    try:
        engine.vote(sid, "guest-1", "Option A")
        assert False, "guest vote must be rejected"
    except PermissionError:
        pass
    try:
        engine.dispatch(sid, "guest-1", {"option": "Option A"})
        assert False, "guest dispatch must be rejected"
    except PermissionError:
        pass
