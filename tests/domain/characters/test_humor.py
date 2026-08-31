import pytest

from criterivox.domain.characters.humor import (
    HumorEligibility,
    HumorPolicy,
    HumorSituation,
)


@pytest.fixture
def policy() -> HumorPolicy:
    return HumorPolicy()


@pytest.mark.parametrize(
    "situation",
    (
        HumorSituation.WAITING,
        HumorSituation.HARMLESS_ERROR,
        HumorSituation.SUCCESS,
        HumorSituation.COMPLETION,
    ),
)
def test_allowed_situations_are_eligible(
    policy: HumorPolicy,
    situation: HumorSituation,
) -> None:
    assert policy.evaluate(situation) is HumorEligibility.ELIGIBLE


def test_serious_warning_suppresses_humor(
    policy: HumorPolicy,
) -> None:
    assert (
        policy.evaluate(HumorSituation.SERIOUS_WARNING)
        is HumorEligibility.SUPPRESSED
    )


def test_serious_warning_never_allows_humor(
    policy: HumorPolicy,
) -> None:
    assert not policy.is_eligible(
        HumorSituation.SERIOUS_WARNING,
    )


def test_missing_humor_characteristics_suppresses_humor(
    policy: HumorPolicy,
) -> None:
    assert not policy.is_eligible(
        HumorSituation.WAITING,
        has_humor_characteristics=False,
    )


def test_user_intervention_suppresses_humor(
    policy: HumorPolicy,
) -> None:
    assert not policy.is_eligible(
        HumorSituation.WAITING,
        user_intervention_required=True,
    )


def test_critical_uncertainty_suppresses_humor(
    policy: HumorPolicy,
) -> None:
    assert not policy.is_eligible(
        HumorSituation.SUCCESS,
        critical_uncertainty=True,
    )


def test_active_recovery_suppresses_humor(
    policy: HumorPolicy,
) -> None:
    assert not policy.is_eligible(
        HumorSituation.COMPLETION,
        active_recovery=True,
    )


def test_normal_waiting_allows_humor(
    policy: HumorPolicy,
) -> None:
    assert policy.is_eligible(
        HumorSituation.WAITING,
    )


def test_policy_returns_suppressed_for_unknown_situation_value(
    policy: HumorPolicy,
) -> None:
    with pytest.raises(ValueError):
        HumorSituation("unknown")