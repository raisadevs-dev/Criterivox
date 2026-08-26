from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from criterivox.web.application.workspace_service import WorkspaceService
from criterivox.web.providers.synthetic import SyntheticProvider


BASE_DIR = Path(__file__).resolve().parent
TEMPLATE_DIR = BASE_DIR / "presentation" / "templates"
STATIC_DIR = BASE_DIR / "presentation" / "static"

app = FastAPI(
    title="Criterivox",
    description="Criterivox S1 user-facing product shell",
    version="0.2.0-s1",
)

app.mount(
    "/static",
    StaticFiles(directory=STATIC_DIR),
    name="static",
)

templates = Jinja2Templates(directory=TEMPLATE_DIR)

provider = SyntheticProvider()
workspace_service = WorkspaceService(provider)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/", response_class=HTMLResponse)
def home(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="home.html",
        context={
            "page": "home",
        },
    )


@app.get("/workspace", response_class=HTMLResponse)
def workspace(request: Request):
    overview = workspace_service.get_workspace_overview()

    return templates.TemplateResponse(
        request=request,
        name="workspace.html",
        context={
            "page": "workspace",
            "overview": overview,
        },
    )