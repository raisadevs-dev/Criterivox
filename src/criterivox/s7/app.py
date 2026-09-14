"""Standalone FastAPI host for the S7 Reasoning Research Bureau.

Run locally with the repository Python environment:
`python -m uvicorn criterivox.s7.app:app --host 127.0.0.1 --port 8017`
This host deliberately does not import Syvax, Home 03, or the presentation layer.
"""
from fastapi import FastAPI
from .api import router

app = FastAPI(title="Criterivox — Reasoning Research Bureau")
app.include_router(router)


@app.get("/health")
def health():
    return {"service": "reasoning-research-bureau", "status": "ready", "syvax_dependency": False}
