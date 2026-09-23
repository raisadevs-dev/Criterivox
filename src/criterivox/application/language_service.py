from __future__ import annotations

import asyncio
import json
import os
import urllib.request

from .language_intake import LanguageProfile


class LanguageService:
    """Runtime language bridge for multilingual and code-mixed human input."""

    def __init__(self) -> None:
        self.api_key = os.environ.get("OPENAI_API_KEY", "").strip()
        self.model = os.environ.get("CRITERIVOX_TRANSLATION_MODEL", "gpt-5.6-luna")

    @property
    def enabled(self) -> bool:
        return bool(self.api_key)

    def _call(self, prompt: str) -> str:
        if not self.api_key:
            return ""
        body = json.dumps({
            "model": self.model,
            "input": prompt,
        }).encode("utf-8")
        request = urllib.request.Request(
            "https://api.openai.com/v1/responses",
            data=body,
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Content-Type": "application/json",
            },
            method="POST",
        )
        with urllib.request.urlopen(request, timeout=45) as response:
            payload = json.load(response)
        return str(payload.get("output_text", "")).strip()

    async def to_reasoning_language(self, text: str, profile: LanguageProfile) -> str:
        if profile.primary_language == "en" and not profile.code_mixed:
            return text
        if not self.enabled:
            return text
        prompt = (
            "Normalize this human request into precise English for internal "
            "Criterivox intent extraction. Preserve uncertainty, tentative "
            "preferences, options, constraints, negation, and references. "
            "Do not add facts. Do not answer the request. Return only the "
            "normalized request. The original may contain multiple languages, "
            "transliteration, or code-mixing.\n\n"
            f"Detected profile: {json.dumps(profile.to_dict(), ensure_ascii=False)}\n"
            f"Original: {text}"
        )
        try:
            return await asyncio.to_thread(self._call, prompt) or text
        except Exception:
            return text

    async def to_user_language(self, text: str, profile: LanguageProfile) -> str:
        if not text or (profile.primary_language == "en" and not profile.code_mixed):
            return text
        if not self.enabled:
            return text
        prompt = (
            "Translate this Criterivox response for the human. Preserve the "
            "meaning exactly and return only the response. Match the person's "
            "language form and script: use Devanagari for Hindi Devanagari, "
            "Latin-script Hindi for Hindi-Latin, and natural Hinglish when the "
            "input was Hinglish. For other detected languages, answer in that "
            "language and preserve named entities and technical identifiers. "
            "Do not add explanations about translation.\n\n"
            f"Target profile: {json.dumps(profile.to_dict(), ensure_ascii=False)}\n"
            f"Response: {text}"
        )
        try:
            return await asyncio.to_thread(self._call, prompt) or text
        except Exception:
            return text


language_service = LanguageService()
