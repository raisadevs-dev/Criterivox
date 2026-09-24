from __future__ import annotations

import json
import os
import urllib.parse
import urllib.request
import uuid
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any


class ExternalResearchError(RuntimeError):
    pass


@dataclass(frozen=True)
class ResearchResult:
    title: str
    url: str
    snippet: str
    display_url: str = ""

    def to_dict(self) -> dict[str, str]:
        return {"title": self.title, "url": self.url, "snippet": self.snippet, "display_url": self.display_url or self.url}


@dataclass(frozen=True)
class ResearchRun:
    run_id: str
    query: str
    requested_by_email: str
    provider: str
    results: tuple[ResearchResult, ...]
    created_at: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "run_id": self.run_id,
            "query": self.query,
            "requested_by_email": self.requested_by_email,
            "provider": self.provider,
            "results": [item.to_dict() for item in self.results],
            "created_at": self.created_at,
        }


class GoogleResearchProvider:
    """Google Programmable Search JSON API adapter.

    Credentials stay server-side. The Human Residence email identifies the
    requesting human in the audit trail; it is not a Google API credential.
    """

    endpoint = "https://www.googleapis.com/customsearch/v1"

    def __init__(self, api_key: str | None = None, cx: str | None = None) -> None:
        self.api_key = api_key or os.getenv("CRITERIVOX_GOOGLE_API_KEY", "").strip()
        self.cx = cx or os.getenv("CRITERIVOX_GOOGLE_CX", "").strip()

    @property
    def configured(self) -> bool:
        return bool(self.api_key and self.cx)

    def search(self, query: str, *, requested_by_email: str, limit: int = 8) -> ResearchRun:
        query = " ".join(query.split())[:500]
        if not query:
            raise ExternalResearchError("External research requires a non-empty query.")
        if not self.configured:
            raise ExternalResearchError(
                "Google research is not configured. Set CRITERIVOX_GOOGLE_API_KEY and CRITERIVOX_GOOGLE_CX."
            )
        params = urllib.parse.urlencode({
            "key": self.api_key,
            "cx": self.cx,
            "q": query,
            "num": max(1, min(limit, 10)),
        })
        request = urllib.request.Request(
            f"{self.endpoint}?{params}",
            headers={"Accept": "application/json", "User-Agent": "Criterivox/1.0"},
        )
        try:
            with urllib.request.urlopen(request, timeout=15) as response:
                payload = json.loads(response.read().decode("utf-8"))
        except Exception as exc:
            raise ExternalResearchError(f"Google research request failed: {exc}") from exc

        raw_items = payload.get("items") or []
        results = tuple(
            ResearchResult(
                title=str(item.get("title", "")),
                url=str(item.get("link", "")),
                snippet=str(item.get("snippet", "")),
                display_url=str(item.get("displayLink", item.get("link", ""))),
            )
            for item in raw_items
            if item.get("link")
        )
        return ResearchRun(
            run_id=f"research-{uuid.uuid4().hex[:16]}",
            query=query,
            requested_by_email=requested_by_email,
            provider="google-programmable-search",
            results=results,
            created_at=datetime.now(timezone.utc).isoformat(),
        )



class OpenAIResearchProvider:
    """OpenAI Responses API web-search adapter.

    This is separate from character conversation. It is used only when the
    human authorizes external evidence acquisition.
    """

    endpoint = "https://api.openai.com/v1/responses"

    def __init__(self, api_key: str | None = None, model: str | None = None) -> None:
        self.api_key = api_key or os.getenv("OPENAI_API_KEY", "").strip()
        self.model = model or os.getenv("CRITERIVOX_OPENAI_MODEL", "gpt-5.6-luna").strip()

    @property
    def configured(self) -> bool:
        return bool(self.api_key and self.model)

    def search(self, query: str, *, requested_by_email: str, limit: int = 8) -> ResearchRun:
        query = " ".join(query.split())[:500]
        if not query:
            raise ExternalResearchError("External research requires a non-empty query.")
        if not self.configured:
            raise ExternalResearchError("OpenAI research is not configured. Set OPENAI_API_KEY.")
        body = json.dumps({
            "model": self.model,
            "tools": [{"type": "web_search"}],
            "input": f"Search the web for authoritative evidence relevant to: {query}. Return concise source-backed findings.",
        }).encode()
        request = urllib.request.Request(
            self.endpoint,
            data=body,
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
                "Accept": "application/json",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                payload = json.loads(response.read().decode("utf-8"))
        except Exception as exc:
            raise ExternalResearchError(f"OpenAI research request failed: {exc}") from exc

        results: list[ResearchResult] = []
        for item in payload.get("output") or []:
            for content_item in item.get("content") or []:
                for annotation in content_item.get("annotations") or []:
                    url = str(annotation.get("url") or "").strip()
                    if not url:
                        continue
                    results.append(ResearchResult(
                        title=str(annotation.get("title") or url),
                        url=url,
                        snippet=str(content_item.get("text") or "")[:1000],
                        display_url=url,
                    ))
                    if len(results) >= limit:
                        break
                if len(results) >= limit:
                    break
            if len(results) >= limit:
                break

        return ResearchRun(
            run_id=f"research-{uuid.uuid4().hex[:16]}",
            query=query,
            requested_by_email=requested_by_email,
            provider="openai-web-search",
            results=tuple(results),
            created_at=datetime.now(timezone.utc).isoformat(),
        )


google_research = GoogleResearchProvider()
openai_research = OpenAIResearchProvider()


def configured_research_providers() -> dict[str, bool]:
    return {
        "google": google_research.configured,
        "openai": openai_research.configured,
    }
