from __future__ import annotations

import html
import re
import urllib.parse
import urllib.request
from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class ResearchResult:
    query: str
    source_url: str
    title: str
    snippet: str
    fetched: bool
    content_excerpt: str | None = None

    def as_dict(self) -> dict[str, Any]:
        return {
            "query": self.query,
            "source_url": self.source_url,
            "title": self.title,
            "snippet": self.snippet,
            "fetched": self.fetched,
            "content_excerpt": self.content_excerpt,
        }


class PublicWebResearchProvider:
    """Small dependency-free public-web acquisition provider.

    It uses a public search endpoint and then fetches only the returned HTTP(S)
    pages. It is intentionally bounded: no credentials, private systems,
    purchases, external actions, or hidden browsing are supported.
    """

    def __init__(self, *, timeout: float = 8.0, max_results: int = 5) -> None:
        self.timeout = timeout
        self.max_results = max(1, min(max_results, 10))

    @staticmethod
    def _request(url: str, timeout: float) -> str:
        request = urllib.request.Request(
            url,
            headers={
                "User-Agent": "Criterivox/0.1 public-research",
                "Accept": "text/html,application/xhtml+xml",
            },
        )
        with urllib.request.urlopen(request, timeout=timeout) as response:
            charset = response.headers.get_content_charset() or "utf-8"
            return response.read(1_000_000).decode(charset, errors="replace")

    def search(self, query: str) -> list[ResearchResult]:
        query = query.strip()
        if not query:
            return []
        endpoint = "https://html.duckduckgo.com/html/?" + urllib.parse.urlencode({"q": query})
        try:
            page = self._request(endpoint, self.timeout)
        except Exception:
            return []

        results: list[ResearchResult] = []
        pattern = re.compile(
            r'<a[^>]+class="result__a"[^>]+href="([^"]+)"[^>]*>(.*?)</a>',
            re.I | re.S,
        )
        snippets = re.findall(
            r'<a[^>]+class="result__snippet"[^>]*>(.*?)</a>',
            page,
            re.I | re.S,
        )
        for index, match in enumerate(pattern.finditer(page)):
            raw_url = html.unescape(match.group(1))
            title = re.sub(r"<[^>]+>", "", html.unescape(match.group(2))).strip()
            parsed = urllib.parse.urlparse(raw_url)
            if parsed.scheme not in {"http", "https"}:
                continue
            # DuckDuckGo sometimes returns a redirect wrapper.
            target = urllib.parse.parse_qs(parsed.query).get("uddg", [raw_url])[0]
            snippet = (
                re.sub(r"<[^>]+>", "", html.unescape(snippets[index])).strip()
                if index < len(snippets)
                else ""
            )
            results.append(
                ResearchResult(
                    query=query,
                    source_url=target,
                    title=title,
                    snippet=snippet,
                    fetched=False,
                )
            )
            if len(results) >= self.max_results:
                break
        return results

    def acquire(self, query: str) -> list[ResearchResult]:
        results = self.search(query)
        acquired: list[ResearchResult] = []
        for result in results:
            try:
                body = self._request(result.source_url, self.timeout)
                text = re.sub(r"<(script|style)[^>]*>.*?</\1>", " ", body, flags=re.I | re.S)
                text = re.sub(r"<[^>]+>", " ", text)
                text = re.sub(r"\s+", " ", html.unescape(text)).strip()
                acquired.append(
                    ResearchResult(
                        query=result.query,
                        source_url=result.source_url,
                        title=result.title,
                        snippet=result.snippet,
                        fetched=True,
                        content_excerpt=text[:4000] if text else None,
                    )
                )
            except Exception:
                acquired.append(result)
        return acquired


def analyze_information_need(
    *,
    goal: str,
    materials: list[dict[str, Any]],
) -> dict[str, Any]:
    extracted = [m for m in materials if m.get("extracted_text")]
    if extracted:
        return {
            "state": "AVAILABLE",
            "reason": "Usable human-supplied material is available.",
            "missing": [],
            "recommended_research": False,
            "research_question": goal.strip(),
        }
    return {
        "state": "NEEDS_INFORMATION",
        "reason": "No usable supplied material is available for evidence-grounded work.",
        "missing": ["External or connected evidence relevant to the goal."],
        "recommended_research": True,
        "research_question": goal.strip(),
    }
