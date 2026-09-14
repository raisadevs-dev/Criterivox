from fastapi.testclient import TestClient

from criterivox.s7.app import app


def test_standalone_health_and_websocket_preflight():
    client = TestClient(app)

    health = client.get("/health")
    assert health.status_code == 200
    assert health.json()["syvax_dependency"] is False

    bureau_health = client.get("/api/s7/health")
    assert bureau_health.status_code == 200
    assert bureau_health.json()["standalone"] is True

    with client.websocket_connect("/api/s7/ws") as websocket:
        websocket.send_json({"type": "ping"})
        message = websocket.receive_json()
        assert message["type"] == "pong"
        assert message["bureau"] == "Reasoning Research Bureau"


def test_http_session_round_trip_and_human_challenge():
    client = TestClient(app)

    created = client.post(
        "/api/s7/sessions",
        json={
            "task": "Evaluate the supplied claim.",
            "context": {"facts": ["Observation exists"], "sources": ["fixture-api-01"]},
        },
    )
    assert created.status_code == 200
    snapshot = created.json()
    assert snapshot["status"] == "COMPLETED"
    assert snapshot["artifacts"]

    reasoning = next(a for a in snapshot["artifacts"] if a["kind"] == "reasoning")
    challenged = client.post(
        f"/api/s7/sessions/{snapshot['session_id']}/challenge",
        json={
            "artifact_id": reasoning["artifact_id"],
            "challenge": "Add the missing contextual constraint before continuing.",
        },
    )
    assert challenged.status_code == 200
    updated = challenged.json()
    assert updated["branch_id"] != "main"
    assert any(a["kind"] == "human_intervention" for a in updated["artifacts"])
    assert any(e["event_type"] == "HUMAN_CHALLENGE" for e in updated["events"])
