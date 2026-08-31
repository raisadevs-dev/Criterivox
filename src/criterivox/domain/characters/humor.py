from enum import Enum


class HumorSituation(str, Enum):
    """Situations in which contextual humor may be considered."""

    WAITING = "waiting"
    HARMLESS_ERROR = "harmless_error"
    SUCCESS = "success"
    COMPLETION = "completion"
    SERIOUS_WARNING = "serious_warning"


class HumorEligibility(str, Enum):
    """Result of humor eligibility evaluation."""

    ELIGIBLE = "eligible"
    SUPPRESSED = "suppressed"


class HumorPolicy:
    """Deterministic domain policy controlling whether humor is permitted."""

    _ALLOWED_SITUATIONS = frozenset(
        {
            HumorSituation.WAITING,
            HumorSituation.HARMLESS_ERROR,
            HumorSituation.SUCCESS,
            HumorSituation.COMPLETION,
        }
    )

    _SUPPRESSION_SITUATIONS = frozenset(
        {
            HumorSituation.SERIOUS_WARNING,
        }
    )

    def evaluate(
        self,
        situation: HumorSituation,
        *,
        has_humor_characteristics: bool = True,
        user_intervention_required: bool = False,
        critical_uncertainty: bool = False,
        active_recovery: bool = False,
    ) -> HumorEligibility:
        """Determine whether humor is permitted in the current situation."""

        if situation in self._SUPPRESSION_SITUATIONS:
            return HumorEligibility.SUPPRESSED

        if situation not in self._ALLOWED_SITUATIONS:
            return HumorEligibility.SUPPRESSED

        if not has_humor_characteristics:
            return HumorEligibility.SUPPRESSED

        if user_intervention_required:
            return HumorEligibility.SUPPRESSED

        if critical_uncertainty:
            return HumorEligibility.SUPPRESSED

        if active_recovery:
            return HumorEligibility.SUPPRESSED

        return HumorEligibility.ELIGIBLE

    def is_eligible(
        self,
        situation: HumorSituation,
        *,
        has_humor_characteristics: bool = True,
        user_intervention_required: bool = False,
        critical_uncertainty: bool = False,
        active_recovery: bool = False,
    ) -> bool:
        """Return True only when humor is permitted."""

        return (
            self.evaluate(
                situation,
                has_humor_characteristics=has_humor_characteristics,
                user_intervention_required=user_intervention_required,
                critical_uncertainty=critical_uncertainty,
                active_recovery=active_recovery,
            )
            is HumorEligibility.ELIGIBLE
        )