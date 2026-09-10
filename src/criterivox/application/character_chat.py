from __future__ import annotations

from dataclasses import dataclass

from criterivox.application.context_engine import ScratchpadRegistry
from criterivox.application.failure_telemetry import FailureType, TELEMETRY
from criterivox.domain.characters import CharacterState
from criterivox.domain.context_intelligence import ObservabilityTimeline


@dataclass(frozen=True, slots=True)
class CharacterChatProfile:
    character_id: str
    role: str
    responsibility: str
    chips: tuple[str, ...]
    focus: tuple[str, ...]


PROFILES: dict[str, CharacterChatProfile] = {
    "dharen": CharacterChatProfile("dharen", "Context Architect", "Context structuring and contextual handoff", ("Structure this context", "Show contextual factors", "What's missing?", "Compare contexts", "Explain this interpretation", "Prepare handoff"), ("context", "structure", "relationships", "limitations", "handoff")),
    "anuka": CharacterChatProfile("anuka", "Adaptive Context Member", "Adaptive context when requirements or hypotheses change", ("Something changed", "Find another perspective", "Adapt this context", "What doesn't fit?", "Try another context", "What's different now?"), ("changed requirements", "alternative perspectives", "mismatch", "adaptive context")),
    "kaelen": CharacterChatProfile("kaelen", "Builder / Experimenter", "Context module construction and short-lived environment state", ("Build this", "Show active module", "Check environment", "Show build state", "Inspect failure", "Prepare module"), ("implementation", "module", "environment", "failure", "scratchpad")),
    "sandre": CharacterChatProfile("sandre", "Data Steward", "Validated material, provenance, and data quality", ("Show validated data", "Check provenance", "Review material set", "What's missing?", "Confirm data", "Prepare handoff"), ("material set", "provenance", "data quality", "missingness", "handoff")),
    "vivren": CharacterChatProfile("vivren", "Context Specialist / Analyst", "Critical reasoning and interpretation challenge", ("Challenge this reasoning", "Find the weak point", "Connect the factors", "What assumption is hidden?", "Explain the contradiction", "Review the logic"), ("critical reasoning", "logical breakdown", "assumptions", "contradictions", "context")),
    "tarkis": CharacterChatProfile("tarkis", "Reasoning Specialist / Analyst", "Questions, hypotheses, and alternative explanations", ("Why?", "What could be wrong?", "Challenge this", "Form a hypothesis", "What else could explain it?", "Test the assumption"), ("questions", "hypotheses", "alternative explanations", "reasoning challenges")),
}

SCRATCHPADS = ScratchpadRegistry()
OBSERVABILITY = ObservabilityTimeline()


def profile_for(character_id: str) -> CharacterChatProfile:
    return PROFILES[character_id.strip().lower()]


def response_for(character_id: str, message: str) -> str:
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


def _failure_from_message(message: str) -> FailureType | None:
    text = message.lower()
    if any(token in text for token in ("requirement changed", "requirements changed", "new requirement", "changed requirement")):
        return FailureType.REQUIREMENT_CHANGED
    if any(token in text for token in ("hypothesis failed", "hypothesis is wrong", "hypothesis was wrong", "hypothesis failure")):
        return FailureType.HYPOTHESIS_FAILED
    if any(token in text for token in ("context mismatch", "doesn't fit", "does not fit", "wrong context")):
        return FailureType.CONTEXT_MISMATCH
    if any(token in text for token in ("build failed", "build failure")):
        return FailureType.BUILD_FAILED
    if any(token in text for token in ("execution failed", "runtime failure", "runtime failed")):
        return FailureType.EXECUTION_FAILED
    return None


async def handle_character_chat(payload: dict) -> None:
    """Handle independent character conversations on the shared runtime boundary."""
    from criterivox.infrastructure.runtime import runtime_connections
    from criterivox.presentation.contract import PresentationContract

    target = str(payload.get("target_character", "")).strip().lower()
    message = str(payload.get("message", "")).strip()
    task_id = str(payload.get("task_id", "UNBOUND")).strip() or "UNBOUND"
    profile = profile_for(target)
    scratchpad = SCRATCHPADS.for_task(task_id)

    failure_type = _failure_from_message(message)
    failure_event = None
    if failure_type is not None:
        evidence = tuple(str(item.get("name", item)) if isinstance(item, dict) else str(item) for item in payload.get("references", ()) if item)
        failure_event = TELEMETRY.record(task_id=task_id, failure_type=failure_type, character_id=target, summary=message, evidence=evidence)
        scratchpad.put("last_failure_id", failure_event.event_id)
        scratchpad.put("last_failure_type", failure_event.failure_type.value)
        OBSERVABILITY.record(task_id=task_id, character_id=target, action="FAILURE_RECORDED", reason=failure_type.value, failure_id=failure_event.event_id)

    def activity() -> tuple[str, ...]:
        return tuple(f"{event.character_id}: {event.action} • {event.reason}" for event in OBSERVABILITY.for_task(task_id))

    def traces() -> tuple[dict, ...]:
        return tuple(event.to_dict() for event in OBSERVABILITY.for_task(task_id))

    await runtime_connections.publish(PresentationContract.from_state(target, CharacterState.RECEIVE, active=True, prominence=.9, message=f"{profile.role} received the message.", event="CHARACTER_CHAT_RECEIVED", task_id=task_id, activity=activity(), observability_events=traces(), failure_id=failure_event.event_id if failure_event else None, failure_type=failure_event.failure_type.value if failure_event else None))
    OBSERVABILITY.record(task_id=task_id, character_id=target, action="WORK", reason="Process character-bounded request.", failure_id=failure_event.event_id if failure_event else None)
    scratchpad.put("last_message", message)
    scratchpad.put("active_character", target)
    await runtime_connections.publish(PresentationContract.from_state(target, CharacterState.WORK, active=True, prominence=.9, message=f"Working within the {profile.character_id} response domain.", event="CHARACTER_CHAT_WORKING", task_id=task_id, activity=activity(), observability_events=traces(), failure_id=failure_event.event_id if failure_event else None, failure_type=failure_event.failure_type.value if failure_event else None))
    scratchpad.put("response_domain", profile.character_id)
    response = response_for(target, message)
    scratchpad.put("last_response", response)
    OBSERVABILITY.record(task_id=task_id, character_id=target, action="COMMUNICATE", reason="Return role-bounded response.", output=response, failure_id=failure_event.event_id if failure_event else None)
    await runtime_connections.publish(PresentationContract.from_state(target, CharacterState.COMMUNICATE, active=True, prominence=.9, message=response, event="CHARACTER_CHAT_RESPONSE", task_id=task_id, activity=activity(), observability_events=traces(), failure_id=failure_event.event_id if failure_event else None, failure_type=failure_event.failure_type.value if failure_event else None))
    await runtime_connections.publish(PresentationContract.from_state(target, CharacterState.COMPLETE, active=True, prominence=.75, message=f"{profile.role} completed this interaction.", event="CHARACTER_CHAT_COMPLETE", task_id=task_id, activity=activity(), observability_events=traces(), failure_id=failure_event.event_id if failure_event else None, failure_type=failure_event.failure_type.value if failure_event else None))

    if failure_event is not None and target == "kaelen":
        OBSERVABILITY.record(task_id=task_id, character_id="vivren", action="ANALYZE_FAILURE", reason=f"Review {failure_event.failure_type.value}", failure_id=failure_event.event_id)
        await runtime_connections.publish(PresentationContract.from_state("vivren", CharacterState.RECEIVE, active=True, prominence=.9, message="Vivren received the failure telemetry for reasoning review.", event="FAILURE_REVIEW_RECEIVED", task_id=task_id, activity=activity(), observability_events=traces(), failure_id=failure_event.event_id, failure_type=failure_event.failure_type.value))
        await runtime_connections.publish(PresentationContract.from_state("vivren", CharacterState.COMMUNICATE, active=True, prominence=.9, message="Vivren is separating the observed breakdown from assumptions and identifying what context may explain it.", event="FAILURE_BREAKDOWN_ANALYSIS", task_id=task_id, activity=activity(), observability_events=traces(), failure_id=failure_event.event_id, failure_type=failure_event.failure_type.value))
        OBSERVABILITY.record(task_id=task_id, character_id="anuka", action="ADAPTIVE_INTERVENTION", reason="Conditional response to recorded failure.", failure_id=failure_event.event_id)
        scratchpad.put("adaptive_intervention", {"failure_id": failure_event.event_id, "source": "vivren", "status": "PROPOSED"})
        await runtime_connections.publish(PresentationContract.from_state("anuka", CharacterState.RECEIVE, active=True, prominence=.9, message="Anuka was activated because the workflow recorded a change or failure condition. Earlier context remains preserved.", event="ADAPTIVE_INTERVENTION_RECEIVED", task_id=task_id, activity=activity(), observability_events=traces(), failure_id=failure_event.event_id, failure_type=failure_event.failure_type.value))
        await runtime_connections.publish(PresentationContract.from_state("anuka", CharacterState.COMMUNICATE, active=True, prominence=.9, message="Anuka proposes revisiting the changed context without silently replacing the failed path.", event="ADAPTIVE_INTERVENTION_PROPOSED", task_id=task_id, activity=activity(), observability_events=traces(), failure_id=failure_event.event_id, failure_type=failure_event.failure_type.value))

    OBSERVABILITY.record(task_id=task_id, character_id=target, action="IDLE", reason="Interaction completed.")
    await runtime_connections.publish(PresentationContract.from_state(target, CharacterState.IDLE, active=False, prominence=.25, message=None, event="CHARACTER_IDLE", task_id=task_id, activity=activity(), observability_events=traces(), failure_id=failure_event.event_id if failure_event else None, failure_type=failure_event.failure_type.value if failure_event else None))


def sign_off_task_scratchpad(task_id: str) -> tuple[str, ...]:
    return SCRATCHPADS.sign_off(task_id)


__all__ = ["CharacterChatProfile", "PROFILES", "SCRATCHPADS", "OBSERVABILITY", "handle_character_chat", "profile_for", "response_for", "sign_off_task_scratchpad"]
