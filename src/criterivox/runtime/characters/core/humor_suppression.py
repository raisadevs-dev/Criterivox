from __future__ import annotations

from dataclasses import dataclass

from .character import Character
from .humor import HumorEligibility, HumorPolicy, HumorSituation


@dataclass(frozen=True, slots=True)
class AgentHumorProfile:
    """Humor characteristics associated with one Criterivox character."""

    character_id: str
    characteristics: str


class AgentHumorRegistry:
    """Provides agent-specific humor characteristics."""

    def get_profile(self, character: Character) -> AgentHumorProfile:
        """Return the humor profile defined by the character."""

        if not isinstance(character, Character):
            raise TypeError("Character must be a Character.")

        characteristics = character.behavior.humor_characteristics.strip()

        if not characteristics:
            raise ValueError(
                "Character humor characteristics cannot be empty."
            )

        return AgentHumorProfile(
            character_id=character.identity.identifier,
            characteristics=characteristics,
        )


@dataclass(frozen=True, slots=True)
class WaitingHumorRules:
    """Rules governing humor during waiting situations."""

    minimum_waiting_cycles: int = 1
    enabled: bool = True

    def __post_init__(self) -> None:
        if self.minimum_waiting_cycles < 1:
            raise ValueError(
                "Minimum waiting cycles must be at least 1."
            )


class WaitingHumorPolicy:
    """Determines whether waiting humor is currently permitted."""

    def __init__(
        self,
        rules: WaitingHumorRules | None = None,
    ) -> None:
        self.rules = rules or WaitingHumorRules()
        self._policy = HumorPolicy()

    def evaluate(
        self,
        *,
        waiting_cycles: int,
        has_humor_characteristics: bool = True,
        user_intervention_required: bool = False,
        critical_uncertainty: bool = False,
        active_recovery: bool = False,
    ) -> HumorEligibility:
        """Evaluate humor eligibility for a waiting situation."""

        if waiting_cycles < 0:
            raise ValueError("Waiting cycles cannot be negative.")

        if not self.rules.enabled:
            return HumorEligibility.SUPPRESSED

        if waiting_cycles < self.rules.minimum_waiting_cycles:
            return HumorEligibility.SUPPRESSED

        return self._policy.evaluate(
            HumorSituation.WAITING,
            has_humor_characteristics=has_humor_characteristics,
            user_intervention_required=user_intervention_required,
            critical_uncertainty=critical_uncertainty,
            active_recovery=active_recovery,
        )

    def is_eligible(
        self,
        *,
        waiting_cycles: int,
        has_humor_characteristics: bool = True,
        user_intervention_required: bool = False,
        critical_uncertainty: bool = False,
        active_recovery: bool = False,
    ) -> bool:
        """Return whether waiting humor is permitted."""

        return (
            self.evaluate(
                waiting_cycles=waiting_cycles,
                has_humor_characteristics=has_humor_characteristics,
                user_intervention_required=user_intervention_required,
                critical_uncertainty=critical_uncertainty,
                active_recovery=active_recovery,
            )
            is HumorEligibility.ELIGIBLE
        )