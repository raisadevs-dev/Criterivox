from __future__ import annotations

from dataclasses import dataclass
import re
from typing import Any

from .conversation import ConversationInterpretation, interpret_message
from .language_intake import LanguageProfile, detect_language_profile


CHARACTER_ALIASES: dict[str, tuple[str, ...]] = {
    "syvax": ("syvax",),
    "sandre": ("sandre",),
    "kaelen": ("kaelen",),
    "dharen": ("dharen",),
    "anuka": ("anuka",),
    "vivren": ("vivren", "viveran"),
    "tarkis": ("tarkis",),
    "pramon": ("pramon",),
    "bodhex": ("bodhex",),
    "medrus": ("medrus",),
    "epistre": ("epistre",),
    "veridat": ("veridat",),
    "manis": ("manis",),
    "viveda": ("viveda",),
    "anukor": ("anukor",),
}

HOME_IDS: dict[str, str] = {
    "syvax": "gateway",
    "sandre": "data",
    "kaelen": "data",
    "dharen": "context",
    "anuka": "context",
    "vivren": "reasoning",
    "tarkis": "reasoning",
    "pramon": "decision",
    "bodhex": "decision",
    "manis": "decision",
    "medrus": "evidence",
    "epistre": "evidence",
    "veridat": "evidence",
    "viveda": "knowledge",
    "anukor": "network",
}


@dataclass(frozen=True)
class GlobalChatIntent:
    intent: str
    normalized_text: str
    confidence: float
    character_id: str | None
    route_reason: str
    language_profile: LanguageProfile
    source_interpretation: ConversationInterpretation

    @property
    def is_report_request(self) -> bool:
        return self.intent == "report"


_REPORT_PHRASES = (
    "show report",
    "open report",
    "view report",
    "give me the report",
    "get the report",
    "read the report",
    "show me the report",
    "character report",
    "your report",
    "their report",
    "report for",
    "report from",
    "what did you report",
    "what did you find",
)

_STATUS_PHRASES = (
    "status",
    "current status",
    "what is happening",
    "what's happening",
    "whats happening",
    "where are we",
    "what is going on",
    "what's going on",
    "how is it going",
)


def _contains_any(text: str, phrases: tuple[str, ...]) -> bool:
    return any(phrase in text for phrase in phrases)


def _character_from_text(text: str) -> str | None:
    lowered = text.casefold()
    for character_id, aliases in CHARACTER_ALIASES.items():
        if any(re.search(rf"\b{re.escape(alias)}\b", lowered) for alias in aliases):
            return character_id
    return None


def _report_character(text: str, explicit_target: str | None) -> str | None:
    mentioned = _character_from_text(text)
    if mentioned:
        return mentioned
    if explicit_target and explicit_target != "syvax":
        return explicit_target
    return None


def interpret_global_chat(
    message: str,
    *,
    explicit_target: str | None = None,
) -> GlobalChatIntent:
    raw = " ".join(message.strip().split())
    profile = detect_language_profile(raw)
    # The existing reasoning-language service performs optional normalization
    # before this function in the runtime. This module remains deterministic
    # and dependency-light so it can also be tested independently.
    base = interpret_message(raw)
    lowered = raw.casefold()

    if _contains_any(lowered, _REPORT_PHRASES):
        character = _report_character(raw, explicit_target)
        if character:
            reason = f"Report request explicitly identifies {character}."
        else:
            reason = "Report request targets the latest combined task report."
        return GlobalChatIntent(
            intent="report",
            normalized_text=raw,
            confidence=0.98 if character else 0.94,
            character_id=character,
            route_reason=reason,
            language_profile=profile,
            source_interpretation=base,
        )

    if _contains_any(lowered, _STATUS_PHRASES) or base.intent in {"status", "current", "next", "history"}:
        character = _character_from_text(raw)
        return GlobalChatIntent(
            intent=base.intent if base.intent != "unknown" else "status",
            normalized_text=raw,
            confidence=max(base.confidence, 0.90),
            character_id=character,
            route_reason=(
                f"Status request names {character}."
                if character
                else "Status request uses the current task/runtime as its context."
            ),
            language_profile=profile,
            source_interpretation=base,
        )

    character = _character_from_text(raw)
    return GlobalChatIntent(
        intent=base.intent,
        normalized_text=raw,
        confidence=base.confidence,
        character_id=character or base.route_target,
        route_reason=(
            f"Character {character} was explicitly named."
            if character
            else base.route_reason or "Existing conversation intent routing applies."
        ),
        language_profile=profile,
        source_interpretation=base,
    )


def home_for_character(character_id: str) -> str | None:
    return HOME_IDS.get(character_id.strip().lower())


def public_report_reference(report: dict[str, Any]) -> dict[str, Any]:
    character_id = str(report.get("character_id") or "").strip().lower() or None
    return {
        "report_id": report.get("report_id"),
        "report_title": report.get("title"),
        "report_summary": report.get("summary"),
        "report_scope": report.get("scope"),
        "report_character_id": character_id,
        "report_home_id": home_for_character(character_id) if character_id else None,
        "report_views": report.get("views", {}),
    }


__all__ = [
    "GlobalChatIntent",
    "CHARACTER_ALIASES",
    "HOME_IDS",
    "interpret_global_chat",
    "home_for_character",
    "public_report_reference",
]
