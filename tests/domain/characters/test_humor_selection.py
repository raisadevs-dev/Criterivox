import pytest

from criterivox.domain.characters import get_character
from criterivox.domain.characters.humor import (
    HumorEligibility,
    HumorSituation,
)
from criterivox.domain.characters.humor_selection import (
    CompletionHumorPolicy,
    ContextualHumorSelector,
    HarmlessErrorHumorPolicy,
    HumorCandidate,
)


def test_harmless_error_allows_humor() -> None:
    policy = HarmlessErrorHumorPolicy()

    assert (
        policy.evaluate(is_harmless=True)
        is HumorEligibility.ELIGIBLE
    )


def test_serious_error_suppresses_humor() -> None:
    policy = HarmlessErrorHumorPolicy()

    assert (
        policy.evaluate(is_harmless=False)
        is HumorEligibility.SUPPRESSED
    )


def test_harmless_error_with_user_intervention_suppresses_humor() -> None:
    policy = HarmlessErrorHumorPolicy()

    assert (
        policy.evaluate(
            is_harmless=True,
            user_intervention_required=True,
        )
        is HumorEligibility.SUPPRESSED
    )


def test_harmless_error_with_critical_uncertainty_suppresses_humor() -> None:
    policy = HarmlessErrorHumorPolicy()

    assert (
        policy.evaluate(
            is_harmless=True,
            critical_uncertainty=True,
        )
        is HumorEligibility.SUPPRESSED
    )


def test_successful_completion_allows_humor() -> None:
    policy = CompletionHumorPolicy()

    assert (
        policy.evaluate(completed_successfully=True)
        is HumorEligibility.ELIGIBLE
    )


def test_unsuccessful_completion_suppresses_humor() -> None:
    policy = CompletionHumorPolicy()

    assert (
        policy.evaluate(completed_successfully=False)
        is HumorEligibility.SUPPRESSED
    )


def test_completion_with_user_intervention_suppresses_humor() -> None:
    policy = CompletionHumorPolicy()

    assert (
        policy.evaluate(
            completed_successfully=True,
            user_intervention_required=True,
        )
        is HumorEligibility.SUPPRESSED
    )


def test_selector_returns_deterministic_candidate() -> None:
    selector = ContextualHumorSelector()
    character = get_character("Dharen")

    first = selector.select(
        character,
        HumorSituation.COMPLETION,
    )
    second = selector.select(
        character,
        HumorSituation.COMPLETION,
    )

    assert isinstance(first, HumorCandidate)
    assert first == second


def test_selector_uses_character_humor_characteristics() -> None:
    selector = ContextualHumorSelector()
    character = get_character("Dharen")

    candidate = selector.select(
        character,
        HumorSituation.SUCCESS,
    )

    assert candidate is not None
    assert (
        candidate.characteristics
        == character.behavior.humor_characteristics
    )


def test_selector_suppresses_serious_warning() -> None:
    selector = ContextualHumorSelector()
    character = get_character("Dharen")

    candidate = selector.select(
        character,
        HumorSituation.SERIOUS_WARNING,
    )

    assert candidate is None


def test_selector_suppresses_critical_uncertainty() -> None:
    selector = ContextualHumorSelector()
    character = get_character("Dharen")

    candidate = selector.select(
        character,
        HumorSituation.COMPLETION,
        critical_uncertainty=True,
    )

    assert candidate is None


def test_selector_rejects_invalid_character() -> None:
    selector = ContextualHumorSelector()

    with pytest.raises(
        TypeError,
        match="Character must be a Character",
    ):
        selector.select(
            "Dharen",  # type: ignore[arg-type]
            HumorSituation.SUCCESS,
        )


def test_selector_rejects_invalid_situation() -> None:
    selector = ContextualHumorSelector()
    character = get_character("Dharen")

    with pytest.raises(
        TypeError,
        match="Situation must be a HumorSituation",
    ):
        selector.select(
            character,
            "success",  # type: ignore[arg-type]
        )