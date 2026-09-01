from __future__ import annotations

from dataclasses import dataclass

from .character import Character
from .humor import HumorEligibility, HumorPolicy, HumorSituation


@dataclass(frozen=True, slots=True)
class HumorCandidate:
    """A deterministic humor candidate for a character."""

    character_id: str
    situation: HumorSituation
    characteristics: str


class ContextualHumorSelector:
    """Selects whether a character may provide contextual humor."""

    def __init__(self) -> None:
        self._policy = HumorPolicy()

    def select(
        self,
        character: Character,
        situation: HumorSituation,
        *,
        user_intervention_required: bool = False,
        critical_uncertainty: bool = False,
        active_recovery: bool = False,
    ) -> HumorCandidate | None:
        """Return a humor candidate when humor is permitted."""

        if not isinstance(character, Character):
            raise TypeError("Character must be a Character.")

        if not isinstance(situation, HumorSituation):
            raise TypeError("Situation must be a HumorSituation.")

        eligible = self._policy.is_eligible(
            situation,
            has_humor_characteristics=bool(
                character.behavior.humor_characteristics.strip()
            ),
            user_intervention_required=user_intervention_required,
            critical_uncertainty=critical_uncertainty,
            active_recovery=active_recovery,
        )

        if not eligible:
            return None

        return HumorCandidate(
            character_id=character.identity.identifier,
            situation=situation,
            characteristics=character.behavior.humor_characteristics,
        )


class HarmlessErrorHumorPolicy:
    """Rules for humor during non-serious errors."""

    def __init__(self) -> None:
        self._policy = HumorPolicy()

    def evaluate(
        self,
        *,
        is_harmless: bool,
        user_intervention_required: bool = False,
        critical_uncertainty: bool = False,
    ) -> HumorEligibility:
        """Evaluate whether harmless-error humor is permitted."""

        if not is_harmless:
            return HumorEligibility.SUPPRESSED

        return self._policy.evaluate(
            HumorSituation.HARMLESS_ERROR,
            user_intervention_required=user_intervention_required,
            critical_uncertainty=critical_uncertainty,
        )


class CompletionHumorPolicy:
    """Rules for humor after successful completion."""

    def __init__(self) -> None:
        self._policy = HumorPolicy()

    def evaluate(
        self,
        *,
        completed_successfully: bool,
        user_intervention_required: bool = False,
        critical_uncertainty: bool = False,
    ) -> HumorEligibility:
        """Evaluate whether completion humor is permitted."""

        if not completed_successfully:
            return HumorEligibility.SUPPRESSED

        return self._policy.evaluate(
            HumorSituation.COMPLETION,
            user_intervention_required=user_intervention_required,
            critical_uncertainty=critical_uncertainty,
        )