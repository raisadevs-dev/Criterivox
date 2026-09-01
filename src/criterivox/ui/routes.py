"""Browser-facing UI routes for the Criterivox presentation shell."""

from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

router = APIRouter()

templates = Jinja2Templates(directory="src/criterivox/ui/templates")


@router.get("/", response_class=HTMLResponse)
def home(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="home.html",
        context={"request": request, "title": "Criterivox"},
    )


@router.get("/settings", response_class=HTMLResponse)
def settings_page(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="home.html",
        context={"request": request, "title": "Criterivox Settings"},
    )


def placeholder_page(request: Request, page_name: str):
    return templates.TemplateResponse(
        request=request,
        name="home.html",
        context={
            "request": request,
            "title": f"Criterivox {page_name}",
        },
    )


# Keep the presentation routes explicit. A parameterized catch-all such as
# /{page_name} can compete with infrastructure endpoints (for example
# /health) when FastAPI/Starlette retains included routers as lazy wrappers.
# Explicit routes also make the public UI surface auditable.
def _register_placeholder(page_name: str) -> None:
    router.add_api_route(
        f"/{page_name}",
        lambda request, _page_name=page_name: placeholder_page(
            request, _page_name
        ),
        methods=["GET"],
        response_class=HTMLResponse,
        name=f"{page_name}_page",
    )


for _page in (
    "workspace",
    "data",
    "intelligence",
    "explanations",
    "experiments",
    "knowledge",
):
    _register_placeholder(_page)
