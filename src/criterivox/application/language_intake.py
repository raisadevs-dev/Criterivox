from __future__ import annotations

from dataclasses import asdict, dataclass
import re


_HINDI_LATIN_MARKERS = {
    "hai", "hain", "mujhe", "mujhse", "mere", "mera", "meri", "aap", "apka",
    "karo", "karna", "kar", "chahiye", "lagta", "lagti", "hisaab", "hisab",
    "kyunki", "kyun", "kya", "kaise", "nahi", "nahin", "thoda", "zyada",
    "wala", "wali", "sahi", "galat", "samajh", "samjha", "dekho", "batao",
    "rakho", "consider", "karunga", "karenge",
}

_ENGLISH_MARKERS = {
    "the", "this", "that", "and", "or", "but", "if", "then", "with",
    "from", "for", "because", "please", "check", "analyze", "analysis",
    "option", "evidence", "result", "task", "continue", "stop",
}

_SCRIPT_RANGES = (
    ("Devanagari", "\u0900-\u097F"),
    ("Bengali", "\u0980-\u09FF"),
    ("Gurmukhi", "\u0A00-\u0A7F"),
    ("Gujarati", "\u0A80-\u0AFF"),
    ("Tamil", "\u0B80-\u0BFF"),
    ("Telugu", "\u0C00-\u0C7F"),
    ("Kannada", "\u0C80-\u0CFF"),
    ("Malayalam", "\u0D00-\u0D7F"),
    ("Arabic", "\u0600-\u06FF"),
    ("Cyrillic", "\u0400-\u04FF"),
    ("Greek", "\u0370-\u03FF"),
    ("Latin", "A-Za-z"),
)


@dataclass(frozen=True)
class LanguageProfile:
    primary_language: str
    secondary_languages: tuple[str, ...]
    scripts: tuple[str, ...]
    code_mixed: bool
    transliterated: bool
    confidence: float
    segments: tuple[dict[str, str], ...]

    def to_dict(self) -> dict[str, object]:
        return asdict(self)


def detect_language_profile(text: str) -> LanguageProfile:
    raw = " ".join(text.strip().split())
    scripts = tuple(
        name
        for name, pattern in _SCRIPT_RANGES
        if re.search(f"[{pattern}]", raw)
    )
    words = re.findall(r"[A-Za-z]+", raw.casefold())
    hindi_hits = sum(word in _HINDI_LATIN_MARKERS for word in words)
    english_hits = sum(word in _ENGLISH_MARKERS for word in words)
    devanagari = "Devanagari" in scripts
    transliterated = bool(hindi_hits and "Latin" in scripts and not devanagari)
    code_mixed = bool(
        (hindi_hits and english_hits)
        or (devanagari and "Latin" in scripts)
    )

    if devanagari:
        primary = "hi"
        secondary = ("en",) if english_hits else ()
    elif transliterated and english_hits:
        primary = "hinglish"
        secondary = ("hi", "en")
    elif transliterated:
        primary = "hi-Latn"
        secondary = ()
    elif english_hits or "Latin" in scripts:
        primary = "en"
        secondary = ()
    elif scripts:
        primary = scripts[0].lower()
        secondary = ()
    else:
        primary = "unknown"
        secondary = ()

    confidence = (
        0.96 if primary in {"en", "hi"}
        else 0.82 if primary != "unknown"
        else 0.20
    )

    return LanguageProfile(
        primary_language=primary,
        secondary_languages=secondary,
        scripts=scripts,
        code_mixed=code_mixed,
        transliterated=transliterated,
        confidence=confidence,
        segments=(
            {
                "text": raw,
                "language": primary,
                "script": ",".join(scripts) or "unknown",
            },
        ),
    )


def interpretation_summary(intent: str, route_target: str | None) -> str:
    summaries = {
        "analyze": "You want Criterivox to analyze the supplied task and context.",
        "handoff": "You want the task handed to Dharen for structural analysis.",
        "change_request": "You are changing a requirement, goal, constraint, or supplied information.",
        "pause": "You want Criterivox to pause the current task.",
        "resume": "You want Criterivox to resume the current task.",
        "cancel": "You want Criterivox to cancel the current task.",
        "history": "You want Criterivox to inspect what happened previously.",
        "next": "You want Criterivox to identify what remains or happens next.",
        "current": "You want Criterivox to report the current task state.",
        "continue": "You want Criterivox to continue the current work.",
        "user_continue": "You intend to continue the task yourself.",
        "unknown": "You supplied a request that Criterivox must interpret before acting on it.",
    }
    result = summaries.get(intent, "Criterivox will interpret this human input before acting.")
    if route_target:
        result += f" The interpreted route is {route_target[:1].upper() + route_target[1:]}."
    return result
