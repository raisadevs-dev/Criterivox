from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class CharacterChatProfile:
    character_id: str
    role: str
    responsibility: str
    chips: tuple[str, ...]
    focus: tuple[str, ...]


PROFILES: dict[str, CharacterChatProfile] = {
    "dharen": CharacterChatProfile(
        "dharen", "Context Architect", "Context structuring and contextual handoff",
        ("Structure this context", "Show contextual factors", "What's missing?", "Compare contexts", "Explain this interpretation", "Prepare handoff"),
        ("context", "structure", "relationships", "limitations", "handoff"),
    ),
    "anuka": CharacterChatProfile(
        "anuka", "Adaptive Context Member", "Adaptive context when requirements or hypotheses change",
        ("Something changed", "Find another perspective", "Adapt this context", "What doesn't fit?", "Try another context", "What's different now?"),
        ("changed requirements", "alternative perspectives", "mismatch", "adaptive context"),
    ),
    "kaelen": CharacterChatProfile(
        "kaelen", "Builder / Experimenter", "Context module construction and short-lived environment state",
        ("Build this", "Show active module", "Check environment", "Show build state", "Inspect failure", "Prepare module"),
        ("implementation", "module", "environment", "failure", "scratchpad"),
    ),
    "sandre": CharacterChatProfile(
        "sandre", "Data Steward", "Validated material, provenance, and data quality",
        ("Show validated data", "Check provenance", "Review material set", "What's missing?", "Confirm data", "Prepare handoff"),
        ("material set", "provenance", "data quality", "missingness", "handoff"),
    ),
    "vivren": CharacterChatProfile(
        "vivren", "Context Specialist / Analyst", "Critical reasoning and interpretation challenge",
        ("Challenge this reasoning", "Find the weak point", "Connect the factors", "What assumption is hidden?", "Explain the contradiction", "Review the logic"),
        ("critical reasoning", "logical breakdown", "assumptions", "contradictions", "context"),
    ),
    "tarkis": CharacterChatProfile(
        "tarkis", "Reasoning Specialist / Analyst", "Questions, hypotheses, and alternative explanations",
        ("Why?", "What could be wrong?", "Challenge this", "Form a hypothesis", "What else could explain it?", "Test the assumption"),
        ("questions", "hypotheses", "alternative explanations", "reasoning challenges"),
    ),
}


def profile_for(character_id: str) -> CharacterChatProfile:
    return PROFILES[character_id.strip().lower()]


def response_for(character_id: str, message: str) -> str:
    """Produce a bounded, role-specific response without inventing system state."""
    profile = profile_for(character_id)
    text = message.strip().lower()
    if character_id == "dharen":
        if "missing" in text:
            return "I would first separate what is observed from what is unavailable, then identify which missing context could change the interpretation."
        if "handoff" in text:
            return "I can prepare a contextual handoff that preserves the material identifier, source lineage, context definition, and known limitations."
        return "I would structure the supplied information by contextual dimension, then show the factors and limitations before interpreting it."
    if character_id == "anuka":
        if any(word in text for word in ("changed", "different", "doesn't fit", "does not fit")):
            return "Something no longer fits the current path. I would isolate what changed, keep the earlier context visible, and test an alternative interpretation rather than silently replacing it."
        return "I would look for the part of the current context that no longer matches the situation and propose another perspective without treating it as proven evidence."
    if character_id == "kaelen":
        if "failure" in text or "wrong" in text:
            return "I would inspect the active module and runtime evidence first, preserve the failure telemetry separately from user-facing explanation, and avoid turning a build failure into research knowledge."
        return "I would turn the validated material into a testable module, keep temporary environment state in the scratchpad, and report the build state separately from domain knowledge."
    if character_id == "sandre":
        if "provenance" in text:
            return "I would trace the material set back through its source identifiers and transformation records. The current S5 lineage is traceable, but it is not an immutable ledger."
        if "missing" in text:
            return "I would distinguish not provided, unavailable, not observed, and extraction failure rather than collapsing them into a single missing value."
        return "I would show the validated material, its quality metadata, provenance, and confirmation status before preparing a downstream handoff."
    if character_id == "vivren":
        return "I would challenge the interpretation before accepting it: which contextual factor supports it, which factor is missing, and which assumption could produce the same observation?"
    if character_id == "tarkis":
        if "hypothesis" in text:
            return "A useful hypothesis should be stated as a proposition that can be challenged. I would record what it explains, what evidence would support it, and what observation could weaken it."
        return "Why is that interpretation preferred? I would test an alternative explanation and check whether the available evidence actually distinguishes between them."
    return "The character profile does not define a response domain for this interaction."


__all__ = ["CharacterChatProfile", "PROFILES", "profile_for", "response_for"]
