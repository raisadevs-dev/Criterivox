
from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

from .language_intake import LanguageProfile, detect_language_profile, interpretation_summary


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
    language_profile: LanguageProfile | None = None
    semantic_summary: str | None = None

    def __post_init__(self) -> None:
        if self.language_profile is None:
            object.__setattr__(self, "language_profile", detect_language_profile(self.normalized_text))
        if not self.semantic_summary:
            object.__setattr__(
                self,
                "semantic_summary",
                interpretation_summary(self.intent, self.route_target),
            )


_HISTORY_PHRASES = (
    "what happened",
    "show history",
    "what changed",
    "why did this happen",
    "what happened before",
    "what failed",
    "show the handoff",
)


_NEXT_PHRASES = (
    "what happens next",
    "what's next",
    "whats next",
    "what remains",
    "what are you waiting for",
)


_PAUSE_PHRASES = (
    "pause",
    "hold this",
)


_RESUME_PHRASES = (
    "resume",
    "continue the task",
)


_CANCEL_PHRASES = (
    "stop",
    "cancel this",
    "cancel the task",
)


_CHANGE_PHRASES = (
    "change the requirement",
    "change the goal",
    "new requirement",
    "remove this constraint",
    "use this new information",
)


_STATUS_PHRASES = (
    "status",
    "current state",
    "what's happening",
    "what is happening",
    "whats happening",
    "how is my analysis",
    "how's my analysis",
    "where are we",
    "what is going on",
    "what's going on",
    "whats going on",
)


_HANDOFF_PHRASES = (
    "handoff",
    "hand over",
    "hand it over",
    "delegate",
    "send it to",
    "let dharen handle",
    "ask dharen",
    "give it to dharen",
    "pass this to dharen",
)


_USER_CONTINUE_PHRASES = (
    "i'll do it",
    "i will do it",
    "i'll do this",
    "i will do this",
    "let me do it",
    "i'll handle it",
    "i will handle it",
    "do it myself",
    "i want to do it myself",
    "continue myself",
)


_ANALYZE_PHRASES = (
    "analyze",
    "analysis",
    "analyse",
    "analyzing",
    "analyse this",
    "make sense of",
    "examine",
    "study this data",
    "look at this data",
)


def _matches_phrase(
    lowered: str,
    phrases: tuple[str, ...],
) -> bool:
    """
    Match an intent phrase anywhere in normalized user input.

    The existing architecture uses phrase containment for conversational
    requests, so this helper keeps that behavior centralized.
    """
    return any(
        phrase in lowered
        for phrase in phrases
    )


def _matches_command(
    lowered: str,
    phrases: tuple[str, ...],
) -> bool:
    """
    Match a short command either exactly or at the beginning of a longer
    command.

    Example:
        "pause" -> pause
        "pause this task" -> pause
    """
    return (
        lowered in phrases
        or any(
            lowered.startswith(phrase + " ")
            for phrase in phrases
        )
    )


def interpret_message(
    message: str,
) -> ConversationInterpretation:
    """
    Deterministic first-pass intent and routing interpretation for character
    chat.

    Intent precedence is deliberate:

        pause
        resume
        cancel
        change_request
        history
        next
        current
        handoff
        user_continue
        continue
        analyze
        unknown

    More specific state-changing commands are therefore resolved before
    broader conversational phrases.
    """
    text = " ".join(
        message.strip().split()
    )

    lowered = text.casefold()

    # --------------------------------------------------------------
    # Explicit control commands
    # --------------------------------------------------------------

    if _matches_command(
        lowered,
        _PAUSE_PHRASES,
    ):
        return ConversationInterpretation(
            "pause",
            text,
            0.99,
        )

    if _matches_command(
        lowered,
        _RESUME_PHRASES,
    ):
        return ConversationInterpretation(
            "resume",
            text,
            0.99,
        )

    if _matches_command(
        lowered,
        _CANCEL_PHRASES,
    ):
        return ConversationInterpretation(
            "cancel",
            text,
            0.99,
        )

    # --------------------------------------------------------------
    # Requirement / goal changes
    # --------------------------------------------------------------

    if _matches_phrase(
        lowered,
        _CHANGE_PHRASES,
    ):
        return ConversationInterpretation(
            "change_request",
            text,
            0.96,
        )

    # --------------------------------------------------------------
    # Historical situation
    # --------------------------------------------------------------

    if _matches_phrase(
        lowered,
        _HISTORY_PHRASES,
    ):
        return ConversationInterpretation(
            "history",
            text,
            0.96,
        )

    # --------------------------------------------------------------
    # Recorded next step
    # --------------------------------------------------------------

    if _matches_phrase(
        lowered,
        _NEXT_PHRASES,
    ):
        return ConversationInterpretation(
            "next",
            text,
            0.96,
        )

    # --------------------------------------------------------------
    # Current situation
    # --------------------------------------------------------------

    if _matches_phrase(
        lowered,
        _STATUS_PHRASES,
    ):
        return ConversationInterpretation(
            "current",
            text,
            0.94,
        )

    # --------------------------------------------------------------
    # Explicit character handoff
    # --------------------------------------------------------------

    if _matches_phrase(
        lowered,
        _HANDOFF_PHRASES,
    ):
        return ConversationInterpretation(
            "handoff",
            text,
            0.97,
            route_target="dharen",
            route_reason=(
                "The user explicitly requested that Dharen take the task."
            ),
        )

    # --------------------------------------------------------------
    # Human continuation
    # --------------------------------------------------------------

    if _matches_phrase(
        lowered,
        _USER_CONTINUE_PHRASES,
    ):
        return ConversationInterpretation(
            "user_continue",
            text,
            0.96,
        )

    # --------------------------------------------------------------
    # Generic continuation
    # --------------------------------------------------------------

    if lowered in {
        "continue",
        "go on",
        "keep going",
        "proceed",
        "carry on",
    }:
        return ConversationInterpretation(
            "continue",
            text,
            0.90,
        )

    # --------------------------------------------------------------
    # Analysis
    # --------------------------------------------------------------

    if _matches_phrase(
        lowered,
        _ANALYZE_PHRASES,
    ):
        return ConversationInterpretation(
            "analyze",
            text,
            0.90,
            route_target="dharen",
            route_reason=(
                "Analysis execution belongs to Dharen's "
                "structural-analysis responsibility."
            ),
        )

    # --------------------------------------------------------------
    # Unknown
    # --------------------------------------------------------------

    return ConversationInterpretation(
        "unknown",
        text,
        0.25,
    )
