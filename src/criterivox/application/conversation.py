from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

Intent = Literal[
    "status",
    "history",
    "current",
    "next",
    "pause",
    "resume",
    "cancel",
    "change_request",
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

_HISTORY_PHRASES = ("what happened","show history","what changed","why did this happen","what happened before","what failed","show the handoff")
_NEXT_PHRASES = ("what happens next","what's next","whats next","what remains","what are you waiting for")
_PAUSE_PHRASES = ("pause","hold this")
_RESUME_PHRASES = ("resume","continue the task")
_CANCEL_PHRASES = ("stop","cancel this","cancel the task")
_CHANGE_PHRASES = ("change the requirement","change the goal","new requirement","remove this constraint","use this new information")

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

    if lowered in _PAUSE_PHRASES or any(lowered.startswith(p+" ") for p in _PAUSE_PHRASES):
        return ConversationInterpretation("pause", text, .99)
    if lowered in _RESUME_PHRASES:
        return ConversationInterpretation("resume", text, .99)
    if lowered in _CANCEL_PHRASES:
        return ConversationInterpretation("cancel", text, .99)
    if any(phrase in lowered for phrase in _CHANGE_PHRASES):
        return ConversationInterpretation("change_request", text, .96)
    if any(phrase in lowered for phrase in _HISTORY_PHRASES):
        return ConversationInterpretation("history", text, .96)
    if any(phrase in lowered for phrase in _NEXT_PHRASES):
        return ConversationInterpretation("next", text, .96)
    if any(phrase in lowered for phrase in _STATUS_PHRASES):
        return ConversationInterpretation("current", text, .94)
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
