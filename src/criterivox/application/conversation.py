from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

Intent = Literal["status", "continue", "analyze", "unknown"]

@dataclass(frozen=True)
class ConversationInterpretation:
    intent: Intent
    normalized_text: str
    confidence: float
    reply_hint: str | None = None

_STATUS_PHRASES = (
    "status", "current state", "what's happening", "whats happening",
    "how is my analysis", "how's my analysis", "where are we", "what is going on",
)


def interpret_message(message: str) -> ConversationInterpretation:
    """Deterministic, dependency-free first pass for noisy chat.

    This is deliberately not marketed as NLP. It catches common shorthand,
    typos and casing variations before an optional LLM semantic adapter is used.
    """
    text = " ".join(message.strip().split())
    lowered = text.casefold()
    if any(phrase in lowered for phrase in _STATUS_PHRASES):
        return ConversationInterpretation("status", text, 0.92)
    if lowered in {"continue", "go on", "keep going", "proceed", "carry on"}:
        return ConversationInterpretation("continue", text, 0.9)
    return ConversationInterpretation("unknown", text, 0.25)
