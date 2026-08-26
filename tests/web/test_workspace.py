from fastapi.testclient import TestClient

from criterivox.web.app import app


client = TestClient(app)


def test_home_page_loads() -> None:
    response = client.get("/")

    assert response.status_code == 200
    assert "Criterivox" in response.text


def test_workspace_uses_application_data() -> None:
    response = client.get("/workspace")

    assert response.status_code == 200
    assert "Criterivox Research Workspace" in response.text
    assert "Synthetic Content Dataset" in response.text