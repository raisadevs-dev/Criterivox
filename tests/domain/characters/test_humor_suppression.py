import pytest

from criterivox.domain.characters import get_character
from criterivox.domain.characters.humor import HumorEligibility
from criterivox.domain.characters.humor_suppression import (
    AgentHumorProfile,
    AgentHumorRegistry,
    WaitingHumorPolicy,
    WaitingHumorRules,
)


def test_agent_humor_profile_uses_character_definition() -> None:
    character = get_character("Dharen")

    profile = AgentHumorRegistry().get_profile(character)

    assert isinstance(profile, AgentHumorProfile)
    assert profile.character_id == "Dharen"
    assert (
        profile.characteristics
        == character.behavior.humor_characteristics
    )


def test_all_registered_characters_have_humor_profiles() -> None:
    registry = AgentHumorRegistry()

    character_ids = (
        "Dharen",
        "Vivren",
        "Tarkis",
        "Sandre",
        "Pramon",
        "Syvax",
        "Bodhex",
        "Medrus",
        "Epistre",
        "Manis",
        "Anuka",
        "Veridat",
        "Viveda",
        "Kaelen",
        "Anukor",
    )

    for character_id in character_ids:
        profile = registry.get_profile(
            get_character(character_id)
        )

        assert profile.character_id == character_id
        assert profile.characteristics


def test_waiting_humor_is_suppressed_before_threshold() -> None:
    policy = WaitingHumorPolicy(
        WaitingHumorRules(minimum_waiting_cycles=2)
    )

    assert (
        policy.evaluate(waiting_cycles=0)
        is HumorEligibility.SUPPRESSED
    )

    assert (
        policy.evaluate(waiting_cycles=1)
        is HumorEligibility.SUPPRESSED
    )


def test_waiting_humor_is_allowed_after_threshold() -> None:
    policy = WaitingHumorPolicy(
        WaitingHumorRules(minimum_waiting_cycles=2)
    )

    assert (
        policy.evaluate(waiting_cycles=2)
        is HumorEligibility.ELIGIBLE
    )


def test_waiting_humor_can_be_disabled() -> None:
    policy = WaitingHumorPolicy(
        WaitingHumorRules(
            minimum_waiting_cycles=1,
            enabled=False,
        )
    )

    assert not policy.is_eligible(waiting_cycles=5)


def test_waiting_humor_respects_missing_humor_characteristics() -> None:
    policy = WaitingHumorPolicy()

    assert not policy.is_eligible(
        waiting_cycles=2,
        has_humor_characteristics=False,
    )


def test_waiting_humor_respects_user_intervention() -> None:
    policy = WaitingHumorPolicy()

    assert not policy.is_eligible(
        waiting_cycles=2,
        user_intervention_required=True,
    )


def test_waiting_humor_respects_critical_uncertainty() -> None:
    policy = WaitingHumorPolicy()

    assert not policy.is_eligible(
        waiting_cycles=2,
        critical_uncertainty=True,
    )


def test_waiting_humor_respects_active_recovery() -> None:
    policy = WaitingHumorPolicy()

    assert not policy.is_eligible(
        waiting_cycles=2,
        active_recovery=True,
    )


def test_negative_waiting_cycles_are_rejected() -> None:
    policy = WaitingHumorPolicy()

    with pytest.raises(
        ValueError,
        match="Waiting cycles cannot be negative",
    ):
        policy.evaluate(waiting_cycles=-1)


def test_invalid_character_is_rejected() -> None:
    with pytest.raises(
        TypeError,
        match="Character must be a Character",
    ):
        AgentHumorRegistry().get_profile(
            "Dharen",  # type: ignore[arg-type]
        )


def test_invalid_waiting_threshold_is_rejected() -> None:
    with pytest.raises(
        ValueError,
        match="Minimum waiting cycles",
    ):
        WaitingHumorRules(minimum_waiting_cycles=0)