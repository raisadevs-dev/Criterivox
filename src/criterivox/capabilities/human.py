from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Mapping
from uuid import uuid4

from .core import DomainEvent, EventBus


class HumanChallengeState(str, Enum):
    RECEIVED = "RECEIVED"
    PREMISE_CORRECTION_REQUIRED = "PREMISE_CORRECTION_REQUIRED"
    SOCRATIC_GATE_ACTIVE = "SOCRATIC_GATE_ACTIVE"
    CHECKPOINT_PAUSE = "CHECKPOINT_PAUSE"
    TOOL_MISUSE_BLOCKED = "TOOL_MISUSE_BLOCKED"
    RESOLVED = "RESOLVED"


@dataclass(frozen=True, slots=True)
class HumanChallenge:
    challenge_id: str
    actor_id: str
    target_ids: tuple[str, ...]
    state: HumanChallengeState
    instruction: str
    metadata: Mapping[str, str] = field(default_factory=dict)


class HumanAuthority:
    """Explicit human-authority gate shared by capabilities.

    It records the intervention as a domain event and never treats a character
    identity as authority. This is deliberately independent of presentation.
    """
    def __init__(self, event_bus: EventBus | None = None) -> None:
        self.event_bus = event_bus or EventBus()
        self.challenges: dict[str, HumanChallenge] = {}

    def challenge(self, actor_id: str, target_ids: tuple[str, ...], instruction: str, *, state: HumanChallengeState = HumanChallengeState.RECEIVED, metadata: Mapping[str, str] | None = None) -> HumanChallenge:
        if not actor_id.strip() or not target_ids or not instruction.strip():
            raise ValueError("Human challenge requires actor, target and instruction.")
        challenge = HumanChallenge(f"HC-{uuid4()}", actor_id, tuple(target_ids), state, instruction.strip(), dict(metadata or {}))
        self.challenges[challenge.challenge_id] = challenge
        self.event_bus.publish(DomainEvent(f"EV-{uuid4()}", "human.challenge", {"challenge_id": challenge.challenge_id, "target_ids": challenge.target_ids, "state": challenge.state.value}, correlation_id=challenge.challenge_id))
        return challenge

    def resolve(self, challenge_id: str, *, actor_id: str) -> HumanChallenge:
        challenge = self.challenges[challenge_id]
        if challenge.actor_id != actor_id:
            raise PermissionError("Only the challenge owner may resolve the challenge.")
        resolved = HumanChallenge(challenge.challenge_id, challenge.actor_id, challenge.target_ids, HumanChallengeState.RESOLVED, challenge.instruction, challenge.metadata)
        self.challenges[challenge_id] = resolved
        self.event_bus.publish(DomainEvent(f"EV-{uuid4()}", "human.challenge.resolved", {"challenge_id": challenge_id}, correlation_id=challenge_id))
        return resolved

    def intercept(self, actor_id: str, target_ids: tuple[str, ...], reason: str, *, state: HumanChallengeState = HumanChallengeState.SOCRATIC_GATE_ACTIVE) -> HumanChallenge:
        return self.challenge(actor_id, target_ids, reason, state=state)


__all__ = ["HumanAuthority", "HumanChallenge", "HumanChallengeState"]
