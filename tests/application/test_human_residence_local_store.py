from criterivox.application.human_residence_local_store import HumanResidenceLocalStore


def test_local_human_identity_and_decision_history(tmp_path):
    store = HumanResidenceLocalStore(tmp_path / "human.sqlite3")
    identity = store.signup(
        email="person@example.test",
        password="correct horse battery",
        display_name="Person",
        residence_id="res-1",
        residence_type="private",
    )
    assert store.login(
        email="person@example.test",
        password="correct horse battery",
    )["owner_id"] == identity["owner_id"]

    decision = store.save_decision(
        owner_id=identity["owner_id"],
        residence_id="res-1",
        title="Choose a path",
        goal="Choose a path",
        strategy={"recommendation": "Option B"},
        trace=[{"actor": "dharen", "event": "context"}],
    )
    history = store.list_decisions(identity["owner_id"], "path")
    assert history[0]["decision_id"] == decision["decision_id"]
    assert history[0]["trace"][0]["actor"] == "dharen"
