"""Standalone FastAPI host for the S7 Reasoning Research Bureau."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api import router

app = FastAPI(title="Criterivox — Reasoning Research Bureau")

# The standalone Flutter S7 presentation is served by Chrome on a different
# localhost port. S7 is intentionally local-only here, so permissive localhost
# CORS is appropriate while preserving the bureau boundary.
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:\d+)?$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)


@app.get("/health")
def health():
    return {
        "service": "reasoning-research-bureau",
        "status": "ready",
        "syvax_dependency": False,
    }
