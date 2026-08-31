from criterivox.application.bloom_integration import (
    BloomCapability,
)
from criterivox.application.contextual_capabilities import (
    ContextualCapabilityProvider,
)


def test_analyze_is_available_by_default() -> None:
    provider = ContextualCapabilityProvider()

    capabilities = provider.get_capabilities()

    assert capabilities[0].capability is BloomCapability.ANALYZE


def test_empty_context_does_not_activate_optional_capabilities() -> None:
    provider = ContextualCapabilityProvider()

    capabilities = provider.get_capabilities()

    assert tuple(
        item.capability
        for item in capabilities
    ) == (
        BloomCapability.ANALYZE,
    )


def test_comparison_becomes_available_from_context() -> None:
    provider = ContextualCapabilityProvider()

    capabilities = provider.get_capabilities(
        context={"comparison_available": True},
    )

    assert BloomCapability.COMPARE in {
        item.capability
        for item in capabilities
    }


def test_insights_becomes_available_from_context() -> None:
    provider = ContextualCapabilityProvider()

    capabilities = provider.get_capabilities(
        context={"insights_available": True},
    )

    assert BloomCapability.INSIGHTS in {
        item.capability
        for item in capabilities
    }


def test_explanation_becomes_available_from_context() -> None:
    provider = ContextualCapabilityProvider()

    capabilities = provider.get_capabilities(
        context={"explanation_available": True},
    )

    assert BloomCapability.EXPLAIN in {
        item.capability
        for item in capabilities
    }


def test_multiple_contextual_capabilities_are_supported() -> None:
    provider = ContextualCapabilityProvider()

    capabilities = provider.get_capabilities(
        context={
            "comparison_available": True,
            "exploration_available": True,
            "planning_available": True,
            "insights_available": True,
            "explanation_available": True,
        },
    )

    assert tuple(
        item.capability
        for item in capabilities
    ) == (
        BloomCapability.ANALYZE,
        BloomCapability.COMPARE,
        BloomCapability.EXPLORE,
        BloomCapability.PLAN,
        BloomCapability.INSIGHTS,
        BloomCapability.EXPLAIN,
    )


def test_contextual_capability_has_reason() -> None:
    provider = ContextualCapabilityProvider()

    capabilities = provider.get_capabilities(
        context={"comparison_available": True},
    )

    comparison = next(
        item
        for item in capabilities
        if item.capability is BloomCapability.COMPARE
    )

    assert comparison.reason