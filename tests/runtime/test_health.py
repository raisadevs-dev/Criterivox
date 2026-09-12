from fastapi.testclient import TestClient

from criterivox.app import app


def test_runtime_health_endpoint_reports_ready() -> None:
    client = TestClient(app)
    response = client.get("/health")
    assert response.status_code == 200
    payload = response.json()
    assert payload["service"] == "criterivox"
    assert payload["status"] == "ready"
    assert payload["runtime"] == "python"
    assert payload["s6_context_engine"] == "active"
