from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

router = APIRouter()

templates = Jinja2Templates(
    directory="src/criterivox/ui/templates"
)


@router.get("/", response_class=HTMLResponse)
def home(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="home.html",
        context={
            "request": request,
            "title": "Criterivox",
        },
    )


@router.get("/settings", response_class=HTMLResponse)
def settings_page(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="home.html",
        context={
            "request": request,
            "title": "Criterivox Settings",
        },
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


@router.get("/{page_name}", response_class=HTMLResponse)
def placeholder(request: Request, page_name: str):
    allowed_pages = {
        "workspace",
        "data",
        "intelligence",
        "explanations",
        "experiments",
        "knowledge",
    }

    if page_name not in allowed_pages:
        return HTMLResponse(
            "Page not found",
            status_code=404,
        )

    return placeholder_page(request, page_name)