from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

Intent = Literal[
    "status",
    "continue",
    "analyze",
    "handoff",
    "user_continue",
    "unknown",
]

@dataclass(frozen=True)
class ConversationInterpretation:
    intent: Intent
    normalized_text: str
    confidence: float
    reply_hint: str | None = None
    route_target: str | None = None
    route_reason: str | None = None

_STATUS_PHRASES = (
    "status", "current state", "what's happening", "whats happening",
    "how is my analysis", "how's my analysis", "where are we", "what is going on",
)
_HANDOFF_PHRASES = (
    "handoff", "hand over", "hand it over", "delegate", "send it to",
    "let dharen handle", "ask dharen", "give it to dharen", "pass this to dharen",
)
_USER_CONTINUE_PHRASES = (
    "i'll do it", "i will do it", "i'll do this", "i will do this",
    "let me do it", "i'll handle it", "i will handle it", "do it myself",
    "i want to do it myself", "continue myself",
)
_ANALYZE_PHRASES = (
    "analyze", "analysis", "analyse", "analyzing", "analyse this",
    "make sense of", "examine", "study this data", "look at this data",
)


def interpret_message(message: str) -> ConversationInterpretation:
    """Deterministic first-pass intent and routing interpretation for character chat."""
    text = " ".join(message.strip().split())
    lowered = text.casefold()

    if any(phrase in lowered for phrase in _HANDOFF_PHRASES):
        return ConversationInterpretation(
            "handoff", text, .97, route_target="dharen",
            route_reason="The user explicitly requested that Dharen take the task.",
        )
    if any(phrase in lowered for phrase in _USER_CONTINUE_PHRASES):
        return ConversationInterpretation("user_continue", text, .96)
    if any(phrase in lowered for phrase in _STATUS_PHRASES):
        return ConversationInterpretation("status", text, .92)
    if lowered in {"continue", "go on", "keep going", "proceed", "carry on"}:
        return ConversationInterpretation("continue", text, .9)
    if any(phrase in lowered for phrase in _ANALYZE_PHRASES):
        return ConversationInterpretation(
            "analyze", text, .9, route_target="dharen",
            route_reason="Analysis execution belongs to Dharen's structural-analysis responsibility.",
        )
    return ConversationInterpretation("unknown", text, .25)
