from fastapi.testclient import TestClient

from criterivox.app import app


def test_runtime_health_endpoint_reports_ready() -> None:
    client = TestClient(app)

    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {
        "service": "criterivox",
        "status": "ready",
        "runtime": "python",
    }
