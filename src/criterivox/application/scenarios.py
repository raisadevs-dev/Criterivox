from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class DemonstrationTrace:
    """Trace of one Criterivox end-to-end demonstration scenario."""

    scenario: str
    steps: tuple[str, ...]

    def contains(self, step: str) -> bool:
        return step in self.steps

    def index(self, step: str) -> int:
        return self.steps.index(step)


_ANALYSIS_FLOW = (
    "user_intent",
    "bloom",
    "event",
    "agent",
    "attention",
    "state",
    "communication",
    "result",
    "quiet",
)

_EXPLANATION_FLOW = (
    "user_intent",
    "bloom",
    "event",
    "agent",
    "attention",
    "state",
    "communication",
    "result",
    "quiet",
)

_HANDOFF_FLOW = (
    "user_intent",
    "bloom",
    "event",
    "sender",
    "handoff",
    "receiver",
    "attention",
    "state",
    "communication",
    "result",
    "quiet",
)

_WAITING_FLOW = (
    "user_intent",
    "bloom",
    "event",
    "agent",
    "attention",
    "waiting",
    "communication",
    "quiet",
)

_HUMOR_FLOW = (
    "user_intent",
    "bloom",
    "event",
    "agent",
    "attention",
    "state",
    "communication",
    "humor",
    "result",
    "quiet",
)

_WARNING_RECOVERY_FLOW = (
    "user_intent",
    "bloom",
    "event",
    "agent",
    "attention",
    "warning",
    "recovery",
    "communication",
    "result",
    "quiet",
)

_COMPLETION_QUIET_FLOW = (
    "user_intent",
    "bloom",
    "event",
    "agent",
    "attention",
    "state",
    "communication",
    "complete",
    "quiet",
)


def analysis_flow() -> DemonstrationTrace:
    return DemonstrationTrace("analysis", _ANALYSIS_FLOW)


def explanation_flow() -> DemonstrationTrace:
    return DemonstrationTrace("explanation", _EXPLANATION_FLOW)


def handoff_flow() -> DemonstrationTrace:
    return DemonstrationTrace("agent_handoff", _HANDOFF_FLOW)


def waiting_flow() -> DemonstrationTrace:
    return DemonstrationTrace("waiting", _WAITING_FLOW)


def humor_flow() -> DemonstrationTrace:
    return DemonstrationTrace("contextual_humor", _HUMOR_FLOW)


def warning_recovery_flow() -> DemonstrationTrace:
    return DemonstrationTrace(
        "warning_recovery",
        _WARNING_RECOVERY_FLOW,
    )


def completion_quiet_flow() -> DemonstrationTrace:
    """Return the completion-to-quiet demonstration trace."""

    return DemonstrationTrace(
        "completion_quiet",
        _COMPLETION_QUIET_FLOW,
    )


def all_demonstration_flows() -> tuple[DemonstrationTrace, ...]:
    """Return every Phase 13 demonstration scenario."""

    return (
        analysis_flow(),
        explanation_flow(),
        handoff_flow(),
        waiting_flow(),
        humor_flow(),
        warning_recovery_flow(),
        completion_quiet_flow(),
    )