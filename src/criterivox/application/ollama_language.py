from __future__ import annotations

import json
import os
import urllib.error
import urllib.request
from typing import Any


class OllamaLanguageLayer:
    """Optional local language layer. It is never the authority or evidence source."""

    def __init__(self, base_url: str | None = None, model: str | None = None) -> None:
        self.base_url = (base_url or os.getenv("OLLAMA_BASE_URL", "http://127.0.0.1:11434")).rstrip("/")
        self.model = model or os.getenv("OLLAMA_MODEL", "llama3.2:3b")

    def available(self, timeout: float = 0.6) -> bool:
        try:
            request = urllib.request.Request(self.base_url + "/api/tags", method="GET")
            with urllib.request.urlopen(request, timeout=timeout) as response:
                return 200 <= response.status < 300
        except (OSError, urllib.error.URLError):
            return False

    def synthesize(self, *, situation: str, structured: dict[str, Any], timeout: float = 8.0) -> str | None:
        if not self.available():
            return None
        prompt = (
            "Rewrite the supplied structured Criterivox situation into concise human-readable decision support. "
            "Do not invent evidence, people, facts, tool use, or outcomes. Distinguish reported facts from uncertainty. "
            "Do not identify or profile people from photographs. Return plain text with WHAT I UNDERSTAND, "
            "WHAT MATTERS, WHAT YOU CAN DO NEXT, WHY, and WHAT I'M NOT SURE ABOUT. "
            f"SITUATION: {situation}\nSTRUCTURED: {json.dumps(structured, ensure_ascii=False)}"
        )
        body = json.dumps({
            "model": self.model,
            "prompt": prompt,
            "stream": False,
            "options": {"temperature": 0.1},
        }).encode()
        request = urllib.request.Request(
            self.base_url + "/api/generate",
            data=body,
            headers={"content-type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=timeout) as response:
                if not 200 <= response.status < 300:
                    return None
                payload = json.loads(response.read().decode("utf-8"))
                text = payload.get("response")
                return str(text).strip() if text else None
        except (OSError, urllib.error.URLError, ValueError, json.JSONDecodeError):
            return None
