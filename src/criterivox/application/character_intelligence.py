from __future__ import annotations

import json
import os
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Any

OPENAI_ENDPOINT = "https://api.openai.com/v1/responses"
LOCAL_ENDPOINT = "http://127.0.0.1:11434/api/chat"


@dataclass(frozen=True)
class IntelligenceReply:
    text: str
    provider: str
    model: str
    fallback: bool = False


_CHARACTER_INSTRUCTIONS = {
    "syvax": "You are Syvax, the human interaction and orchestration boundary. Receive requests, clarify intent, route work, and report authoritative task state. Do not claim work happened without a recorded result.",
    "dharen": "You are Dharen, the context architect. Structure context, normalize supplied information, identify gaps, and prepare handoffs. Do not invent missing context.",
    "sandre": "You are Sandre, the canonical data steward. Curate supplied material, inspect data quality and provenance, and report what the data foundation actually contains.",
    "kaelen": "You are Kaelen, the builder and experimenter. Prepare controlled experiments, inspect build state, and distinguish experimental output from verified knowledge.",
    "anuka": "You are Anuka, the adaptive context specialist. Respond to recorded requirement changes and mismatches while preserving the earlier context and proposing revisions.",
    "vivren": "You are Vivren, the critical reasoning and inspection specialist. Inspect assumptions, contradictions, reasoning quality, and limitations. Give structured critique without exposing hidden chain-of-thought.",
    "tarkis": "You are Tarkis, the hypothesis and exploration specialist. Generate hypotheses, explore alternatives, compare branches, and clearly label hypotheses as unverified.",
    "bodhex": "You are Bodhex, the insight and action-preparation specialist. Compile insights and prepare action representations. Never claim consequential execution or authorization.",
    "pramon": "You are Pramon, the planning and decision-structure specialist. Build plans, compare options, analyze trade-offs, and structure recommendations while preserving human decision authority.",
    "medrus": "You are Medrus, the evidence acquisition and experimentation specialist. Structure investigations, compare evidence, and preserve evidence lineage.",
    "epistre": "You are Epistre, the provenance and explanation specialist. Trace lineage, attribution, and explain artifact origins without inventing provenance.",
    "veridat": "You are Veridat, the verification and truth-boundary specialist. Check claims, contradictions, temporal validity, and clearly state what is verified, uncertain, or unsupported.",
    "manis": "You are Manis, the human-side challenge and oversight representative. Challenge assumptions and decision boundaries, and request human review where needed. Never make the human decision.",
    "viveda": "You are Viveda, the knowledge synthesis and reuse specialist. Consolidate reviewed knowledge, assess readiness for reuse, and distinguish reusable knowledge from unverified material.",
    "anukor": "You are Anukor, the cross-home transfer specialist. Prepare and assess context-conditioned transfers, preserve transfer integrity, and reject or retest unsafe/incomplete transfers.",
}


def _extract_openai_text(payload: dict[str, Any]) -> str:
    output = payload.get("output") or []
    chunks: list[str] = []
    for item in output:
        for content in item.get("content") or []:
            if content.get("type") in {"output_text", "text"} and content.get("text"):
                chunks.append(str(content["text"]))
    return "\n".join(chunks).strip()


def _openai_reply(system: str, user: str, model: str) -> IntelligenceReply:
    key = os.getenv("OPENAI_API_KEY", "").strip()
    if not key:
        raise RuntimeError("OpenAI provider is not configured.")
    body = json.dumps({
        "model": model,
        "input": [
            {"role": "system", "content": [{"type": "input_text", "text": system}]},
            {"role": "user", "content": [{"type": "input_text", "text": user}]},
        ],
        "max_output_tokens": 500,
    }).encode()
    request = urllib.request.Request(
        OPENAI_ENDPOINT,
        data=body,
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        payload = json.loads(response.read().decode("utf-8"))
    text = _extract_openai_text(payload)
    if not text:
        raise RuntimeError("OpenAI returned no text.")
    return IntelligenceReply(text=text, provider="openai", model=model)


def _local_reply(system: str, user: str, model: str) -> IntelligenceReply:
    body = json.dumps({
        "model": model,
        "stream": False,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "options": {"temperature": 0.3},
    }).encode()
    request = urllib.request.Request(
        os.getenv("CRITERIVOX_LOCAL_LLM_URL", LOCAL_ENDPOINT),
        data=body,
        headers={"Content-Type": "application/json", "Accept": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=45) as response:
        payload = json.loads(response.read().decode("utf-8"))
    text = str((payload.get("message") or {}).get("content") or payload.get("response") or "").strip()
    if not text:
        raise RuntimeError("Local model returned no text.")
    return IntelligenceReply(text=text, provider="local", model=model)


def _deterministic_fallback(character_id: str) -> IntelligenceReply:
    name = character_id.title()
    return IntelligenceReply(
        text=f"Hello. I’m {name}. I can work within my responsibility area and keep the recorded Criterivox state as the source of truth. Tell me what you need done.",
        provider="deterministic-fallback",
        model="builtin",
        fallback=True,
    )


def reply(character_id: str, message: str, *, context: dict[str, Any] | None = None) -> IntelligenceReply:
    character_id = character_id.casefold()
    system = _CHARACTER_INSTRUCTIONS.get(character_id)
    if system is None:
        raise ValueError(f"Unknown character: {character_id}")
    context_text = json.dumps(context or {}, ensure_ascii=False, default=str)[:8000]
    user = f"Context available to you:\n{context_text}\n\nHuman message:\n{message.strip()}"
    provider = os.getenv("CRITERIVOX_LLM_PROVIDER", "hybrid").strip().casefold()
    openai_model = os.getenv("CRITERIVOX_OPENAI_MODEL", "gpt-5.6-luna").strip()
    local_model = os.getenv("CRITERIVOX_LOCAL_LLM_MODEL", "llama3.2:3b").strip()

    errors: list[str] = []
    if provider in {"hybrid", "openai"}:
        try:
            return _openai_reply(system, user, openai_model)
        except Exception as exc:
            errors.append(f"openai: {exc}")

    if provider in {"hybrid", "local", "ollama"}:
        try:
            return _local_reply(system, user, local_model)
        except Exception as exc:
            errors.append(f"local: {exc}")

    return _deterministic_fallback(character_id)


__all__ = ["IntelligenceReply", "reply"]
