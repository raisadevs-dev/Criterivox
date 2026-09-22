import pytest

from criterivox.application.bloom import BloomController
from criterivox.application.bloom_integration import (
    ApplicationAction,
    BloomCapability,
)


def test_bloom_controller_exposes_all_application_capabilities() -> None:
    controller = BloomController()

    assert {
        capability
        for capability in BloomCapability
    } == set(BloomCapability)


@pytest.mark.parametrize(
    ("capability", "route", "home"),
    (
        (BloomCapability.ANALYZE, "workspace", "Home 04"),
        (BloomCapability.DATA_STEWARDSHIP, "stewardship", "Home 01"),
        (BloomCapability.COMPARE, "workspace", "Home 02"),
        (BloomCapability.EXPLORE, "workspace", "Home 04"),
        (BloomCapability.PLAN, "workspace", "Home 05"),
        (BloomCapability.INSIGHTS, "workspace", "Home 04"),
        (BloomCapability.EXPLAIN, "workspace", "Home 03"),
    ),
)
def test_bloom_activation_uses_python_routing_contract(
    capability: BloomCapability,
    route: str,
    home: str,
) -> None:
    controller = BloomController()

    result = controller.activate_capability(
        capability.value,
        task_id="task-1",
        context={"source": "test"},
    )

    assert result["capability"] == capability.value
    assert result["route"] == route
    assert result["destinations"] == [home]
    assert result["action"] == (
        ApplicationAction.OPEN_DATA_STEWARDSHIP.value
        if capability is BloomCapability.DATA_STEWARDSHIP
        else {
            BloomCapability.ANALYZE: ApplicationAction.REQUEST_ANALYSIS.value,
            BloomCapability.COMPARE: ApplicationAction.REQUEST_COMPARISON.value,
            BloomCapability.EXPLORE: ApplicationAction.REQUEST_EXPLORATION.value,
            BloomCapability.PLAN: ApplicationAction.REQUEST_PLAN.value,
            BloomCapability.INSIGHTS: ApplicationAction.REQUEST_INSIGHTS.value,
            BloomCapability.EXPLAIN: ApplicationAction.REQUEST_EXPLANATION.value,
        }[capability]
    )
    assert result["seed"]["payload"]["task_id"] == "task-1"


def test_unknown_bloom_capability_is_rejected() -> None:
    controller = BloomController()

    with pytest.raises(ValueError, match="Unknown Bloom capability"):
        controller.activate_capability("not-a-capability")
