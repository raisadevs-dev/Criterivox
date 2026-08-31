from criterivox.domain.characters.humor import (
    HumorEligibility,
    HumorPolicy,
    HumorSituation,
)


def test_serious_warning_suppresses_humor() -> None:
    policy = HumorPolicy()

    result = policy.evaluate(
        HumorSituation.SERIOUS_WARNING,
    )

    assert result is HumorEligibility.SUPPRESSED


def test_serious_warning_suppresses_humor_even_with_all_conditions_enabled() -> None:
    policy = HumorPolicy()

    result = policy.evaluate(
        HumorSituation.SERIOUS_WARNING,
        has_humor_characteristics=True,
        user_intervention_required=False,
        critical_uncertainty=False,
        active_recovery=False,
    )

    assert result is HumorEligibility.SUPPRESSED


def test_serious_warning_is_never_humor_eligible() -> None:
    policy = HumorPolicy()

    assert not policy.is_eligible(
        HumorSituation.SERIOUS_WARNING,
    )